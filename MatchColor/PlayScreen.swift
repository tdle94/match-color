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
    private var dyValue: CGFloat = 5
    private var dxValue: CGFloat = 0
    private var maxSpeedY: CGFloat = 500
    private var minSpeedY: CGFloat = 25
    private let blocksAcrossScreen: Int = 5
    private var gameOver: Bool = false
    private var score: Int = 0
    private var scoreLabel: SKLabelNode = SKLabelNode()
    
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
    
    /**
    * Barricade across the screen with 5 blocks
    */
    public func barricade() {
        let side: CGFloat = frame.maxX / CGFloat(blocksAcrossScreen)
        let randomColor = randColorSnakeBody()
        let randomIndex = Int(arc4random_uniform(4))
        let snakeHeadY = snakes[0].getPosition().y
        var newBlock: Block
        
        for i in 0...4 {
            if (i == 0) {
                if (randomIndex == 0) {
                    newBlock = Block(x: frame.minX+side/2, y: frame.maxY * 2  + snakeHeadY, side_: side, color: randomColor)
                }
                else {
                     newBlock = Block(x: frame.minX+side/2, y: frame.maxY * 2  + snakeHeadY, side_: side)
                }
            }
            else {
                if (i == randomIndex) {
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
    * Random color from snake's body
    */
    public func randColorSnakeBody() -> SKColor {
        let snakeLength = UInt32(snakes.count)
        let randomBodyPart = Int(arc4random_uniform(snakeLength))
        return snakes[randomBodyPart].getColor()
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
        
        scoreLabel.physicsBody?.velocity = CGVector(dx: 0, dy: dyValue)
        snakes[0].translateYForever(points: CGVector(dx: 0, dy: dyValue))
      
        // Body of the snake follows snake's head to make a swiggly movement
        if (snakes.count > 1) {
            for i in 1...snakes.count-1 {
                let snakeAheadX = snakes[i-1].getPosition().x
                let snakeAheadY = snakes[i-1].getPosition().y
                snakes[i].followSnakeAhead(points: CGPoint(x: snakeAheadX, y: snakeAheadY))
            }
        }
        
   
        self.handleBlockCollision()
        self.handleSnakeCollision()
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
     
        if (blocks.count == 0) {
            return
        }
        // Go through blocks array
        for (i, _) in blocks.enumerated().reversed() {
            let block = blocks[i].getBlock()
            let blockScoreLabel = blocks[i].getScoreLabel()
            let playerScoreLabel = snakes[0].getScoreLabel()
            let snakeHead = snakes[0].getSnake()        // get snake property
    
            if (block.contains(snakeHead.position) && snakeHead.fillColor != block.fillColor) { // only snake's head left and color mismatch
                snakes[0].explode(playScreen: self)
                self.removeChildren(in: [snakeHead])
                snakes.removeFirst()
                dyValue -= minSpeedY
            }
            else if (snakes.count > 1 && block.contains(snakeHead.position) && snakeHead.fillColor == block.fillColor) { // colors match remove block and snake's head
                updateScore(blockScore: blocks[i].getScore())
                snakes[0].explode(playScreen: self)
                self.removeChildren(in: [blockScoreLabel, playerScoreLabel, block, snakeHead])
                blocks.remove(at: i)
                snakes.removeFirst()
                setupScoreLabel()
            }
            else if (snakes.count == 1 && block.contains(snakeHead.position) && snakeHead.fillColor == block.fillColor) {   // only snake's head left and colors match
                updateScore(blockScore: blocks[i].getScore())
                snakes[0].explode(playScreen: self)
                self.removeChildren(in: [blockScoreLabel, block])
                blocks.remove(at: i)
            }
            
            let isIndexValid = snakes.indices.contains(0)
            if (!isIndexValid) {
                gameOver = true
                break
            }
        }
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
        
       
        if (dyValue > maxSpeedY || dyValue < 0) {
            dyValue = minSpeedY
        }

        // Remove blocks and uneaten snakes once snake has passed them
        if (blocks.count > 0 && snakes[0].getPosition().y - blocks[0].getPosition().y > 300) {
            self.removeAllChildren()
            self.barricade()                // create barricade
            self.randomSnakeOnScreen()
        }
        else if (blocks.count == 0){
            self.barricade()
            self.randomSnakeOnScreen()
        }
        
    }
    
    /*
    * Remove everything else except snake and scoreLabel
    */
    override func removeAllChildren() {
        if (gameOver) {
            return
        }
        let uneatenSnakeCp = uneatenSnake
        super.removeAllChildren()
        blocks.removeAll()
        uneatenSnake.removeAll()
        
        // Preserve snake and score label
        self.addChild(scoreLabel)
        for i in 0...snakes.count-1 {
            self.addChild(snakes[i].getSnake())
        }
        
        if (uneatenSnakeCp.count == 0) {
            return
        }

        // Preserve uneaten snake in front of snake
        for i in 0...uneatenSnakeCp.count-1 {
            if (uneatenSnakeCp[i].getPosition().y > snakes[0].getPosition().y) {
                self.addChild(uneatenSnakeCp[i].getSnake())
                uneatenSnake.append(uneatenSnakeCp[i])
            }
        }
        
    }
    
    /*
    *   Random snake body scatter the screen.
    *   Have to collide with it to prolong the snake
    */
    public func randomSnakeOnScreen() {
        
        // five random snake (equal to blocks across the screen)
        for _ in 0...blocks.count+1 {
            let min = UInt32(snakes[0].getPosition().y)
            let max = UInt32(blocks[0].getPosition().y - blocks[0].getHeight()*2)
            let randomX = CGFloat(arc4random_uniform(UInt32(frame.maxX)))
            let randomY = CGFloat(arc4random_uniform(max) + min)
            let newSnake = Snake(x: randomX, y: randomY)
            addUneatenSnake(unEatean: newSnake)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (gameOver) {
            return
        }
        let touch: UITouch = touches.first!
        let positionInScene = touch.location(in: self)

        
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
