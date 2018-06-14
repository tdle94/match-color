 //
//  PlayView.swift
//  MatchColor
//
//  Created by Tuyen Le on 6/7/18.
//  Copyright © 2018 Tuyen Le. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayScreen: SKScene {
    private var snakes = [Snake]()
    private var uneatenSnake = [Snake]()
    private var blocks = [Block]()
    private var mycamera: SKCameraNode = SKCameraNode()
    private var dyValue: CGFloat = 30
    private var dxValue: CGFloat = 0
    private var maxSpeedY: CGFloat = 500
    private var minSpeedY: CGFloat = 25
    private let blocksAcrossScreen: Int = 5
    private var gameOver: Bool = false
    private var score: Int = 0
    private var level: Int = 1
    private var scoreLabel: SKLabelNode = SKLabelNode()
    private var blockCollideIndex: Int = -1
    
    override init(size: CGSize) {
        super.init(size: size)
        let snakeHead = Snake(x: frame.midX, y: frame.minY)
        prolongSnake(newSnake: snakeHead)
        self.addChild(snakeHead.getScoreLabel())
        self.setupScoreLabel()
    }
    
    public func setupScoreLabel() {
        self.removeChildren(in: [scoreLabel])
        let radius = snakes[0].getRadius()
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontColor = SKColor.white
        scoreLabel.fontSize = 20
        scoreLabel.position.y = snakes[0].getPosition().y
        scoreLabel.position.x = snakes[0].getPosition().x + radius * 2
        scoreLabel.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        scoreLabel.physicsBody?.affectedByGravity = false
        scoreLabel.physicsBody?.collisionBitMask = 0
        self.addChild(scoreLabel)
    }
    
    /*
     *   Random snake body scatter the screen.
     *   Have to collide with it to prolong the snake
     */
    public func randomSnakeOnScreen() {
        var min: UInt32
        var max: UInt32
        
        if (blocks.count == 0) {
            max = UInt32(frame.maxY)
        }
        else {
            max = UInt32(blocks[0].getPosition().y - blocks[0].getSide() - snakes[0].getPosition().y)
        }
        min = UInt32(snakes[0].getPosition().y)
        
        // five random snake (equal to blocks across the screen)
        for _ in 0...blocksAcrossScreen {
            let randomX = CGFloat(arc4random_uniform(UInt32(frame.maxX)))
            let randomY = CGFloat(arc4random_uniform(max) + min)
            let newSnake = Snake(x: randomX, y: randomY)
            addUneatenSnake(unEatean: newSnake)
        }
    }
    
    /**
    * Barricade across the screen with 5 blocks
    */
    public func barricade() {
        let side: CGFloat = frame.maxX / CGFloat(blocksAcrossScreen)
        let randomColor = randColorUneatenSnake()
        let randomColorIndex = Int(arc4random_uniform(UInt32(blocksAcrossScreen - 1)))
        let snakeHeadY = snakes[0].getPosition().y
        var newBlock: Block
        
        // Match atleast one color of snake or uneaten snake with the block
        for i in 0...blocksAcrossScreen-1 {
            if (i == 0) {
                if (randomColorIndex == 0) {
                    newBlock = Block(x: frame.minX+side/2, y: frame.maxY * 2  + snakeHeadY, side_: side, color: randomColor)
                }
                else {
                     newBlock = Block(x: frame.minX+side/2, y: frame.maxY * 2  + snakeHeadY, side_: side)
                }
            }
            else {
                if (i == randomColorIndex) {
                    newBlock = Block(x: (blocks.last?.getPosition().x)! + side, y: frame.maxY * 2 + snakeHeadY, side_: side, color: randomColor)
                }
                else {
                    newBlock = Block(x: (blocks.last?.getPosition().x)! + side, y: frame.maxY * 2  + snakeHeadY, side_: side)
                }
            }
            appendNewBlock(newBlock: newBlock)
        }
    }
    
    /**
    * Random color from either snake's body or eneaten snake
    */
    public func randColorUneatenSnake() -> SKColor {
        var snakeLength: Int
        var randSnakeIndex: Int
        if (uneatenSnake.count == 0) {
            snakeLength = snakes.count - 1      // actual snake length
            randSnakeIndex = Int(arc4random_uniform(UInt32(snakeLength)))
            return snakes[randSnakeIndex].getColor()
        }

        snakeLength = uneatenSnake.count - 1        // uneaten snake length
        randSnakeIndex = Int(arc4random_uniform(UInt32(snakeLength)))
        return uneatenSnake[randSnakeIndex].getColor()
    }
    
    /**
    *   Create new block and append to the list
    */
    public func appendNewBlock(newBlock: Block) {
        blocks.append(newBlock)
        self.addChild(newBlock.getBlock())
        self.addChild(newBlock.getScoreLabel())
    }
    
    
    /**
    * Add new snake (just a cirle represent a snake)
    * to the tail
    */
    public func prolongSnake(newSnake: Snake) {
        snakes.append(newSnake)
        self.addChild(newSnake.getSnake())
    }
    
    /**
    *   Add uneaten snake to screen node
    */
    public func addUneatenSnake(unEatean: Snake) {
        uneatenSnake.append(unEatean)
        self.addChild(unEatean.getSnake())
    }
    
   
    /**
    *  Move snake in the y direction forever
    */
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if (gameOver) {
            self.backToStartScreen()
            return
        }

        camera?.position.y = snakes[0].getPosition().y
        camera?.position.x = frame.midX
        dyValue += 0.5
        
        
        snakes[0].translateYForever(points: CGVector(dx: 0, dy: dyValue))
        scoreLabel.physicsBody?.velocity = CGVector(dx: 0, dy: dyValue)
      
        
        self.followSnakeHead()          // Body of the snake follows snake's head to make a swiggly movement
        self.handleBlockCollision()     // Block collision only with the head of the snake. Body of the snake just follow the head
        self.handleSnakeCollision()     // Uneaten snake collision with snake's head
    }
    
    /*
    * Snake's body follow its head
    */
    public func followSnakeHead() {
        if (snakes.count == 1) {
            return
        }
        
        // Have to handle collision with left and right block when wiggle
        for i in 1...snakes.count-1 {
            let snakeAheadX = snakes[i-1].getPosition().x
            let snakeAheadY = snakes[i-1].getPosition().y

            if (blockCollideIndex != -1 && blockCollideIndex > 0 && blockCollideIndex < blocks.count - 1) {
                btwBlockCollision(i: i)
            }
            else if (blockCollideIndex != -1 && blockCollideIndex == 0) {
                rightBlockCollision(i: i)
            }
            else if (blockCollideIndex != -1 && blockCollideIndex == blocks.count - 1) {
                leftBlockCollision(i: i)
            }
            else {
                snakes[i].followSnakeAhead(points: CGPoint(x: snakeAheadX, y: snakeAheadY))
            }
        }
        
    }
    
    /**
    * Handle snake's body collision between two blocks
    */
    private func btwBlockCollision(i: Int) {
        let snakeAheadX = snakes[i-1].getPosition().x
        let snakeAheadY = snakes[i-1].getPosition().y
        let blockLeft = blocks[blockCollideIndex-1]
        let blockRight = blocks[blockCollideIndex]
        let snakePosition = snakes[i].getPosition()
        if (blockLeft.getBlock().contains(snakePosition) || blockRight.getBlock().contains(snakePosition)) {
            snakes[i].followSnakeAhead(points: CGPoint(x: snakePosition.x, y: snakeAheadY))
        }
        else {
            snakes[i].followSnakeAhead(points: CGPoint(x: snakeAheadX, y: snakeAheadY))
        }
    }
    
    /**
    * Handle snake's body collision with left block
    */
    private func leftBlockCollision(i: Int) {
        let snakeAheadX = snakes[i-1].getPosition().x
        let snakeAheadY = snakes[i-1].getPosition().y
        let blockLeft = blocks[blockCollideIndex-1]
        let snakePosition = snakes[i].getPosition()
        if (blockLeft.getBlock().contains(snakePosition)) {
            snakes[i].followSnakeAhead(points: CGPoint(x: snakePosition.x, y: snakeAheadY))
        }
        else {
            snakes[i].followSnakeAhead(points: CGPoint(x: snakeAheadX, y: snakeAheadY))
        }
    }
    
    /*
    * Handle snake's body collision with right block
    */
    private func rightBlockCollision(i: Int) {
        let snakeAheadX = snakes[i-1].getPosition().x
        let snakeAheadY = snakes[i-1].getPosition().y
        let blockRight = blocks[blockCollideIndex]
        let snakePosition = snakes[i].getPosition()
        if (blockRight.getBlock().contains(snakePosition)) {
            snakes[i].followSnakeAhead(points: CGPoint(x: snakePosition.x, y: snakeAheadY))
        }
        else {
            snakes[i].followSnakeAhead(points: CGPoint(x: snakeAheadX, y: snakeAheadY))
        }
    }
    
    /**
    * End Game
    */
    private func backToStartScreen() {
        self.removeAllChildren()
        self.removeChildren(in: [camera!])
        self.removeAllActions()
        let startScreen = StartScreen(size: size, playerScore_: score)
        let transition = SKTransition.fade(withDuration: 1)
        self.view?.presentScene(startScreen, transition: transition)
    }
    
    /*
    * Check for snake'head collision with blocks
    */
    public func handleBlockCollision() {
     
        if (blocks.count == 0 || blockCollideIndex != -1) {
            return
        }
        // Go through blocks array
        for (i, _) in blocks.enumerated().reversed() {
            let block = blocks[i].getBlock()

            let snakeHead = snakes[0].getSnake()        // get snake property
    
            if (block.contains(snakeHead.position) && snakeHead.fillColor != block.fillColor) { // only snake's head left and color mismatch
                self.snakeHeadMismatch()
            }
            else if (snakes.count > 1 && block.contains(snakeHead.position) && snakeHead.fillColor == block.fillColor) { // colors match remove block and snake's head
                self.snakeHeadMismatchBody(i: i)
            }
            else if (snakes.count == 1 && block.contains(snakeHead.position) && snakeHead.fillColor == block.fillColor) {   // only snake's head left and colors match
                self.snakeHeadMatch(i: i)
            }
            
            let isIndexValid = snakes.indices.contains(0)
            if (!isIndexValid) {
                gameOver = true
                break
            }
        }
    }
    
    /*
    * Snake's head color mismatch. No body left
    */
    private func snakeHeadMismatch() {
        let snakeHead = snakes[0].getSnake()        // get snake property
        snakes[0].explode(playScreen: self)
        self.removeChildren(in: [snakeHead])
        snakes.removeFirst()
        dyValue -= minSpeedY
    }
    
    /*
    *   Snake's head color mismatch. Still body left
    */
    private func snakeHeadMismatchBody(i: Int) {
        let block = blocks[i].getBlock()
        let blockScoreLabel = blocks[i].getScoreLabel()
        let playerScoreLabel = snakes[0].getScoreLabel()
        let snakeHead = snakes[0].getSnake()        // get snake property
        updateScore(blockScore: blocks[i].getScore())
        snakes[0].explode(playScreen: self)
        self.removeChildren(in: [blockScoreLabel, playerScoreLabel, block, snakeHead])
        blocks.remove(at: i)
        snakes.removeFirst()
        setupScoreLabel()
        blockCollideIndex = i
    }
    
    /*
    *   Snake's head color match. No body left
    */
    private func snakeHeadMatch(i: Int) {
        let block = blocks[i].getBlock()
        let blockScoreLabel = blocks[i].getScoreLabel()
        updateScore(blockScore: blocks[i].getScore())
        snakes[0].explode(playScreen: self)
        self.removeChildren(in: [blockScoreLabel, block])
        blocks.remove(at: i)
        blockCollideIndex = i
    }
    
    
    /*
     * Update player score at the head of the snake
     */
    public func updateScore(blockScore: Int)  {
        score += blockScore
        scoreLabel.text = "\(score)"
    }
    
    /*
     * Update Score label position according to player's movement
     */
    public func updateScoreLabelPosition(points: CGPoint) {
        let distX: CGFloat = points.x - scoreLabel.position.x
        let radius = snakes[0].getRadius()
        scoreLabel.position.x += distX + radius * 2
    }
    
    
    /*
    *   Check for collision of snake head with scatter (eneaten) snakes
    */
    public func handleSnakeCollision() {

        if (uneatenSnake.count == 0 || gameOver) {
            return
        }

        let headSnake = snakes[0]
        
        for (i, _) in uneatenSnake.enumerated().reversed() {
            let uneaten = uneatenSnake[i].getSnake()
            let tail = snakes[snakes.count-1]
            
            if (uneaten.contains(headSnake.getPosition()) || headSnake.isCollided(snake: uneatenSnake[i])) {
                let newSnake = Snake(x: tail.getPosition().x, y: tail.getPosition().y - tail.getRadius()*2, color: uneaten.fillColor)
                self.prolongSnake(newSnake: newSnake)
                self.removeChildren(in: [uneaten ])
                uneatenSnake.remove(at: i)
            }
        }
        
    }
    
    /*
    *   Dynamically barricade the screen
    */
    override func didSimulatePhysics() {

        if (gameOver) {
            return
        }
        
       
        if (dyValue > maxSpeedY) {
            level += 1
            maxSpeedY *= CGFloat(level)     // increase difficulty
        }
        else if (dyValue < 0) {
            dyValue = minSpeedY
        }

        // Remove blocks and uneaten snakes once snake has passed them
        if (blocks.count > 0 && snakes[0].getPosition().y - blocks[0].getPosition().y > 300) {
            blockCollideIndex = -1
            self.removeAllChildren()
            self.barricade()                // create barricade
            self.randomSnakeOnScreen()
        }
        else if (blocks.count == 0) {
            self.randomSnakeOnScreen()
            self.barricade()
        }
        
    }
    
    /*
    * Remove everything else except snake and scoreLabel
    */
    override func removeAllChildren() {
        if (gameOver) {
            return
        }
       
        super.removeAllChildren()
        blocks.removeAll()
        uneatenSnake.removeAll()
        
        // Preserve snake and score label
        self.addChild(scoreLabel)
        for i in 0...snakes.count-1 {
            self.addChild(snakes[i].getSnake())
        }

    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (gameOver) {
            return
        }
        let touch: UITouch = touches.first!
        let positionInScene = touch.location(in: self)
        
        for i in 0...blocks.count-1 {
            if (blocks[i].getBlock().contains(snakes[0].getPosition())) {
                return
            }
        }
        snakes[0].updatePosition(points: CGPoint(x: positionInScene.x, y: positionInScene.y))
        self.updateScoreLabelPosition(points: CGPoint(x: positionInScene.x, y: positionInScene.y))
    }
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        camera = mycamera
        self.addChild(camera!)
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{print("PlayScreen deinited")} 
    
}
