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
    private var score: UInt32
    private var radius: CGFloat = 10
    
    init(x: CGFloat, y: CGFloat) {
        score = 0
       
        circle = SKShapeNode(circleOfRadius: radius)
        circle.name = "snake"
        circle.position = CGPoint(x: x, y: y)
        circle.strokeColor = SKColor.black
        circle.glowWidth = 1.0
        circle.fillColor = randomColor()
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        circle.physicsBody?.affectedByGravity = false
        circle.physicsBody?.collisionBitMask = 0
    }
    
    init(x: CGFloat, y: CGFloat, color: SKColor) {
        score = 0

        circle = SKShapeNode(circleOfRadius: 10)
        circle.name = "snake"
        circle.position = CGPoint(x: x, y: y)
        circle.strokeColor = SKColor.black
        circle.glowWidth = 1.0
        circle.fillColor = color
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        circle.physicsBody?.affectedByGravity = false
        circle.physicsBody?.collisionBitMask = 0
    }
    
    public func getRadius() -> CGFloat {
        return radius
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
    
    public func setScore(newScore: UInt32) {
        score = newScore
    }
    
    public func getScore() -> UInt32 {
        return score
    }
    
    public func getSnake() -> SKShapeNode {
        return circle
    }
    
    public func getColor() -> SKColor {
        return circle.fillColor
    }
    
    public func updatePosition(points: CGPoint) {
        let duration: TimeInterval = 0.5
        let distX: CGFloat = points.x - circle.position.x
        let action = SKAction.moveTo(x: circle.position.x + distX, duration: duration)
       
        circle.run(action)


    }
    
    
    public func translateYForever(points: CGVector) {
        
       circle.physicsBody?.velocity = CGVector(dx: points.dx, dy: points.dy)
    }
    
    public func isCollided(snake: Snake) -> Bool {
 
        let adjacent = abs(snake.getPosition().x - self.circle.position.x)
        let opposite = abs(snake.getPosition().y - self.circle.position.y)
        let hypotenuse = Int(sqrt(adjacent*adjacent + opposite*opposite))
        let radiusOfTwoSnake = Int(self.radius * 2)
        
        return hypotenuse <= radiusOfTwoSnake
    }
   
}
