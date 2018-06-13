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
    private var minSpeedY: CGFloat = 50
    private var barricaded = false
    private let blocksAcrossScreen: Int = 5
    private var score: Int = 0
    private var scoreLabel: SKLabelNode = SKLabelNode()
    private var gameOverScene: GameOverScene?
    private var gameOver: Bool = false
    
    override init(size: CGSize) {
        super.init(size: size)
        gameOverScene = GameOverScene(size: size)
        let snakeHead = Snake(x: frame.midX, y: frame.minY)
        prolongSnake(newSnake: snakeHead)
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
            self.scene?.removeFromParent()
            let transition: SKTransition = SKTransition.fade(withDuration: 1)
            self.view?.presentScene(gameOverScene!, transition: transition)
            return
        }

        camera?.position.y = snakes[0].getPosition().y
        camera?.position.x = frame.midX
        dyValue += 0.5
        scoreLabel.physicsBody?.velocity = CGVector(dx: 0, dy: dyValue)
        
        for i in 0...snakes.count - 1 {
            snakes[i].translateYForever(points: CGVector(dx: 0, dy: dyValue))
        }
        
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
        //self.removeBarricade()              // remove blocks when snake already passed them
       // self.removeUneatenSnake()           // remove uneaten snake when snake already passed them
        
    }
    
    /**
    * Remove barricade. A barricade consist of 5 blocks
    */
    private func removeBarricade() {
        
        if (gameOver) {
            return
        }
        for (i, _) in blocks.enumerated().reversed() {
            let block = blocks[i]
            if (block.getPosition().y < snakes[0].getPosition().y) {
                self.removeChildren(in: [block.getBlock(), block.getScoreLabel()])
                blocks.remove(at: i)
            }
        }
    }
    
    /**
    * Remove uneaten snake
    */
    private func removeUneatenSnake() {

        if (gameOver) {
          return
        }
        for (i, _) in uneatenSnake.enumerated().reversed() {
            if (uneatenSnake[i].getPosition().y + frame.midY/2 < snakes[0].getPosition().y) {
                self.removeChildren(in: [uneatenSnake[i].getSnake()])
                uneatenSnake.remove(at: i)
            }
        }
    }
    
    /*
    * Check for snake'head collision with blocks
    */
    public func handleBlockCollision() {
     
        if (blocks.count == 0) {
            return
        }

        for (i, _) in blocks.enumerated().reversed() {
            let block = blocks[i].getBlock()
            let scoreLabel = blocks[i].getScoreLabel()
            let snakeHead = snakes[0].getSnake()        // get snake property
            
            // keep removing snake's head until color of a block match with color of snake's body
            if (block.contains(snakeHead.position) && snakeHead.fillColor != block.fillColor) {
                snakes[0].explode(playScreen: self)
                self.removeChildren(in: [snakeHead])
                snakes.removeFirst()
                dyValue -= minSpeedY
            }
            else if (snakes.count > 1 && block.contains(snakeHead.position) && snakeHead.fillColor == block.fillColor) {    // colors match remove block
                updateScore(textScore: blocks[i].getScoreLabel().text!)
                snakes[0].explode(playScreen: self)
                self.removeChildren(in: [scoreLabel, block, snakeHead])
                blocks.remove(at: i)
                snakes.removeFirst()
            }
            else if (snakes.count == 1 && block.contains(snakeHead.position) && snakeHead.fillColor == block.fillColor) {   // only snake's head left
                updateScore(textScore: blocks[i].getScoreLabel().text!)
                snakes[0].explode(playScreen: self)
                self.removeChildren(in: [scoreLabel, block])
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
    * Update player score
    */
    public func updateScore(textScore: String) {
        self.removeChildren(in: [scoreLabel])
        
        scoreLabel = SKLabelNode()
        scoreLabel.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        scoreLabel.physicsBody?.affectedByGravity = false
        scoreLabel.physicsBody?.collisionBitMask = 0
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 30
        scoreLabel.position = CGPoint(x: frame.maxX - 30, y: snakes[0].getPosition().y + frame.maxY/3)
        if (scoreLabel.text != nil) {
            let score = Int(scoreLabel.text!)! + Int(textScore)!
            scoreLabel.text = String(score)
        }
        else {
            scoreLabel.text = textScore
        }
        self.addChild(scoreLabel)
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
            dyValue = minSpeedY
        }
       
        if (blocks.count > 0 && snakes[0].getPosition().y - blocks[0].getPosition().y > 200) {
            self.removeAllChildren()
            randomSnakeOnScreen()
            barricade()
        }
        else if (blocks.count == 0 && !barricaded){
            barricade()
            randomSnakeOnScreen()
        }
        
    }
    
    override func removeAllChildren() {
        let snakesCopy = snakes
        super.removeAllChildren()
        blocks.removeAll()
        print("remove all: \(blocks.count) ")
        uneatenSnake.removeAll()
        for i in 0...snakesCopy.count-1 {
            self.addChild(snakesCopy[i].getSnake())
        }
    }
    
    /*
    *   Random snake body scatter the screen.
    *   Have to collide with it to prolong the snake
    */
    public func randomSnakeOnScreen() {
        var blockNum = blocks.count
        if (blockNum == 0) {
            return
        }
        else {
            blockNum -= 2
        }
        
        
        // five random snake (equal to blocks across the screen)
        for _ in 0...blockNum+1 {
            let min = UInt32(snakes[0].getPosition().y)
            let max = UInt32(blocks[0].getPosition().y)
            let randomX = CGFloat(arc4random_uniform(UInt32(frame.maxX)))
            let randomY = CGFloat(arc4random_uniform(max) + min)
            let newSnake = Snake(x: randomX, y: randomY)
            addUneatenSnake(unEatean: newSnake)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        let positionInScene = touch.location(in: self)

       
        snakes[0].updatePosition(points: CGPoint(x: positionInScene.x, y: positionInScene.y))       
    }
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        camera = mycamera
        self.addChild(camera!)
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
