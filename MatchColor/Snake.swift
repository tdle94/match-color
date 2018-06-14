//
//  Snake.swift
//  MatchColor
//
//  Created by Tuyen Le on 6/7/18.
//  Copyright © 2018 Tuyen Le. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class Snake {
    private var circle: SKShapeNode     // snake represent as circle
    private var radius: CGFloat = 12
    private var score: Int = 0
    private var scoreLabel: SKLabelNode = SKLabelNode()
    private var explosion: [Explosion]
    
    init(x: CGFloat, y: CGFloat) {

        // set up explosion
        explosion = [Explosion(), Explosion(), Explosion(), Explosion(), Explosion(), Explosion()]
        
        // set up snake
        circle = SKShapeNode(circleOfRadius: radius)
        circle.name = "snake"
        circle.position = CGPoint(x: x, y: y)
        circle.strokeColor = SKColor.black
        circle.glowWidth = 1.0
        circle.fillColor = randomColor()
        circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        circle.physicsBody?.affectedByGravity = false
        circle.physicsBody?.collisionBitMask = 0

    }
    
    init(x: CGFloat, y: CGFloat, color: SKColor) {

        // Set up explosion
        explosion = [Explosion(), Explosion(), Explosion(), Explosion(), Explosion(), Explosion()]
        
        // Set up snake
        circle = SKShapeNode(circleOfRadius: radius)
        circle.name = "snake"
        circle.position = CGPoint(x: x, y: y)
        circle.strokeColor = SKColor.black
        circle.glowWidth = 1.0
        circle.fillColor = color
        circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        circle.physicsBody?.affectedByGravity = false
        circle.physicsBody?.collisionBitMask = 0
        
    }
    
    
    public func explode(playScreen: PlayScreen) {
        let x = circle.position.x
        let y = circle.position.y
        let color = circle.fillColor
        explosion[0].explodeAt(x: x, y: y, color: color, impulse: CGVector(dx: 2, dy: 2), playScreen: playScreen)
        explosion[1].explodeAt(x: x, y: y, color: color, impulse: CGVector(dx: -2, dy: 2), playScreen: playScreen)
        explosion[2].explodeAt(x: x, y: y, color: color, impulse: CGVector(dx: 2, dy: -2), playScreen: playScreen)
        explosion[3].explodeAt(x: x, y: y, color: color, impulse: CGVector(dx: -2, dy: -2), playScreen: playScreen)
        explosion[4].explodeAt(x: x, y: y, color: color, impulse: CGVector(dx: 1, dy: 1), playScreen: playScreen)
        explosion[5].explodeAt(x: x, y: y, color: color, impulse: CGVector(dx: -1, dy: -1), playScreen: playScreen)
    }
    
    public func getRadius() -> CGFloat {
        return radius
    }
    
    public func getScore() -> Int {
        return score
    }
    
    public func getScoreLabel() -> SKLabelNode {
        return scoreLabel
    }
    
    public func setScore(newScore: Int) {
        score = newScore
        scoreLabel.text = "\(score)"
    }
    
    public func randomColor() -> SKColor {
        let random = arc4random_uniform(10);
        var randomColor: SKColor
        switch random {
        case 1:
            randomColor = SKColor.gray
            break;
        case 2:
            randomColor = SKColor.blue
            break;
        case 3:
            randomColor = SKColor.brown
            break;
        case 4:
            randomColor = SKColor.orange
            break;
        case 5:
            randomColor = SKColor.cyan
            break;
        case 6:
            randomColor = SKColor.magenta
            break;
        case 7:
            randomColor = SKColor.darkText
            break;
        case 8:
            randomColor = SKColor.red
            break;
        case 9:
            randomColor = SKColor.purple
            break;
        default:
            randomColor = SKColor.darkGray
            break;
        }
        
        return randomColor
    }
    
    public func getPosition() -> CGPoint {
        return circle.position
    }
    
   
    
    public func getSnake() -> SKShapeNode {
        return circle
    }
    
    public func getColor() -> SKColor {
        return circle.fillColor
    }
    
    /*
    * User swipe left and right
    */
    public func updatePosition(points: CGPoint) {

        let distX: CGFloat = points.x - circle.position.x

        circle.position.x += distX
        scoreLabel.position.x += distX
    }
    
    /*
    * Follow snake ahead
    */
    public func followSnakeAhead(points: CGPoint) {
        let distX: CGFloat = points.x - circle.position.x
        let distY: CGFloat = points.y - circle.position.y
        circle.position.x += distX/3
        circle.position.y += distY - radius * 2
    }
    
    /*
    * Going up forever
    */
    public func translateYForever(points: CGVector) {
        
        circle.physicsBody?.velocity = CGVector(dx: points.dx, dy: points.dy)
        
    }
    
    /*
    *  Check for collision with uneaten snake
    */
    public func isCollided(snake: Snake) -> Bool {
 
        let adjacent = abs(snake.getPosition().x - self.circle.position.x)
        let opposite = abs(snake.getPosition().y - self.circle.position.y)
        let hypotenuse = Int(sqrt(adjacent*adjacent + opposite*opposite))
        let radiusOfTwoSnake = Int(self.radius * 2)
        
        return hypotenuse <= radiusOfTwoSnake
    }
   
}
