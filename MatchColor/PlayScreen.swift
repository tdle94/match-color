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
    private var barricaded = false
    private let blocksAcrossScreen: Int = 5
    private var score: Int = 0
    private var scoreLabel: SKLabelNode = SKLabelNode()
    
    override init(size: CGSize) {
        super.init(size: size)
        let snakeHead = Snake(x: frame.midX, y: frame.minY)
        prolongSnake(newSnake: snakeHead)
        self.addChild(scoreLabel)
    }
    
    /**
    * Barricade across the screen with 5 blocks
    */
    public func barricade() {
        let side: CGFloat = frame.maxX / CGFloat(blocksAcrossScreen)
        let snakeHeadColor = snakes[0].getColor()
        var newBlock = Block(x: frame.minX+side/2, y: frame.maxY * 2  + snakes[0].getPosition().y, side_: side, color:snakeHeadColor)
        appendNewBlock(newBlock: newBlock)
        for _ in 0...3 {
            newBlock = Block(x: (blocks.last?.getPosition().x)! + side, y: frame.maxY * 2 + snakes[0].getPosition().y, side_: side, color:snakeHeadColor)
            appendNewBlock(newBlock: newBlock)
        }
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

        camera?.position.y = snakes[0].getPosition().y
        camera?.position.x = frame.midX
        dyValue += 0.5
        
        scoreLabel.physicsBody?.velocity = CGVector(dx: 0, dy: dyValue)
        
        for i in 0...snakes.count-1 {
            snakes[i].translateYForever(points: CGVector(dx: 0, dy: dyValue))
        }
        
        if (blocks.count > 0) {
            self.handleBlockCollision()
        }
        self.handleSnakeCollision()
        self.removeBarricade()
        self.removeUneatenSnake()
        
    }
    
    /**
    * Remove barricade
    */
    private func removeBarricade() {
        for (i, _) in blocks.enumerated().reversed() {
            if (blocks[i].getPosition().y < snakes[0].getPosition().y) {
                blocks.remove(at: i)
            }
        }
    }
    
    /**
    * Remove uneaten snake
    */
    private func removeUneatenSnake() {
        for (i, _) in uneatenSnake.enumerated().reversed() {
            if (uneatenSnake[i].getPosition().y + frame.midY/2 < snakes[0].getPosition().y) {
                self.removeChildren(in: [uneatenSnake[i].getSnake()])
                uneatenSnake.remove(at: i)
            }
        }
    }
    
    /*
    * Check for collision with blocks
    */
    public func handleBlockCollision() {
        for (i, _) in blocks.enumerated().reversed() {
            let block = blocks[i].getBlock()
            let scoreLabel = blocks[i].getScoreLabel()
            let snakeHead = snakes[0].getSnake()
            
            if (block.contains(snakeHead.position) && snakeHead.fillColor != block.fillColor) {     // keep removing snake's head until colors match
                self.removeChildren(in: [snakeHead])
                snakes.removeFirst()                    // remove snakes head
                dyValue = minSpeedY
            }
            else if (block.contains(snakeHead.position) && snakeHead.fillColor == block.fillColor) {        // colors match remove block
                updateScore(textScore: blocks[i].getScoreLabel().text!)
                self.removeChildren(in: [scoreLabel, block, snakeHead])
                blocks.remove(at: i)        // remove block
                snakes.removeFirst()        // remove snakes head
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
        scoreLabel.text = textScore
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 30
        scoreLabel.position = CGPoint(x: frame.maxX - 20, y: snakes[0].getPosition().y + frame.midY)
        self.addChild(scoreLabel)
    }
    
    /*
    *   Check for collision with scatter snakes
    */
    public func handleSnakeCollision() {

        if (uneatenSnake.count == 0) {
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
        let snakeHeadY = Int(snakes[0].getPosition().y)
       
        if (dyValue > maxSpeedY) {
            dyValue = minSpeedY
        }
       
        
        
        if (!barricaded) {
            barricade()
            matchSnakeWithBlock()
            randomSnakeOnScreen()
            barricaded = true
        }
        else if (snakeHeadY > 0 &&  blocks.count == 0) {
            barricaded = false
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
        for _ in 0...blockNum+1 {
            let min = UInt32(snakes[0].getPosition().y)
            let max = UInt32(blocks[0].getPosition().y - blocks[0].getHeight())
            let randomX = CGFloat(arc4random_uniform(UInt32(frame.maxX)))
            let randomY = CGFloat(arc4random_uniform(max) + min)
            let newSnake = Snake(x: randomX, y: randomY)
            addUneatenSnake(unEatean: newSnake)
        }
    }
    
    
    /**
    * Match random created snake with atleast one
    * block.
    */
    public func matchSnakeWithBlock() {
        let min = UInt32(snakes[0].getPosition().y)
        let max = UInt32(blocks[0].getPosition().y)
        let randomX = CGFloat(arc4random_uniform(UInt32(frame.maxX)))
        let randomY = CGFloat(arc4random_uniform(max) + min)
        let newSnake = Snake(x: randomX, y: randomY, color: blocks[0].getColor())
        addUneatenSnake(unEatean: newSnake)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        var positionInScene = touch.location(in: self)
        
        snakes[0].updatePosition(points: CGPoint(x: positionInScene.x, y: positionInScene.y))
        if (snakes.count == 1) {
            return
        }

        for i in 1...snakes.count-1 {
            positionInScene = CGPoint(x: positionInScene.x,  y: positionInScene.y-10)
            snakes[i].updatePosition(points: positionInScene)
        }
       
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
