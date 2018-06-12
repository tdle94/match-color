//
//  Block.swift
//  MatchColor
//
//  Created by Tuyen Le on 6/7/18.
//  Copyright © 2018 Tuyen Le. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class Block {
    private var square: SKShapeNode
    private var width: CGFloat = 50
    private var height: CGFloat = 50
    private var side: CGFloat
    private var score: Int
    private var scoreLabel: SKLabelNode = SKLabelNode()
    private var maxScore: Int = 10

    
    init(x: CGFloat, y: CGFloat, side_: CGFloat) {
        
        side = side_

        // random score
        score = Int(arc4random_uniform(UInt32(maxScore)))
    
        // initialize square
        square = SKShapeNode(rectOf: CGSize(width: side, height: side))
        square.name = "square"
        square.position = CGPoint(x: x, y: y)
        square.fillColor = randomColor()

    

        // initialize text score inside square
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 20
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: square.frame.midX, y: square.frame.midY)
    }
    
    init(x: CGFloat, y: CGFloat, side_: CGFloat, color: SKColor) {
        
        side = side_

        // random score
        score = Int(arc4random_uniform(UInt32(maxScore)))
        
        // initialize square
        square = SKShapeNode(rectOf: CGSize(width: side, height: side))
        square.name = "square"
        square.position = CGPoint(x: x, y: y)
        square.fillColor = color
        
        
        // initialize text score inside square
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 20
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: square.frame.midX, y: square.frame.midY)
    }
    
    public func getScoreLabel() -> SKLabelNode {
        return scoreLabel
    }
    
    public func getWidth() -> CGFloat {
        return width
    }
    
    public func getHeight() -> CGFloat {
        return height
    }
    
    public func getScore() -> Int {
        return score
    }
    
    public func getPosition() -> CGPoint {
        return square.position
    }
    
    public func getColor() -> SKColor {
        return square.fillColor
    }
    
    public func getBlock() -> SKShapeNode {
        return square
    }
    
    public func randomColor(matchColor: SKColor) -> SKColor {
        let random = arc4random_uniform(6);
        var randomColor: SKColor
        switch random {
        case 1:
            randomColor = self.randomColor()
            break;
        case 2:
            randomColor = self.randomColor()
            break;
        case 3:
             randomColor = matchColor
            break;
        case 4:
            randomColor = self.randomColor()
            break;
        case 5:
            randomColor = self.randomColor()
            break;
        default:
            randomColor = self.randomColor()
            break;
        }
        
        return randomColor
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
            randomColor = SKColor.yellow
            break;
        default:
            randomColor = SKColor.darkGray
            break;
        }
        
        return randomColor
    }
    
}
