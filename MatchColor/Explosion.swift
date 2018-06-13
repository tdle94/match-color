//
//  Explosion.swift
//  MatchColor
//
//  Created by Tuyen Le on 6/12/18.
//  Copyright © 2018 Tuyen Le. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class Explosion {
    private let radius: CGFloat = 5
    private let sharpenal: SKShapeNode
    
    init() {
        sharpenal = SKShapeNode(circleOfRadius: radius)
        sharpenal.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        sharpenal.physicsBody?.affectedByGravity = true
    }
    
    public func explodeAt(x: CGFloat, y: CGFloat, color: SKColor, impulse: CGVector, playScreen: PlayScreen) {
        sharpenal.position.x = x
        sharpenal.position.y = y
        sharpenal.fillColor = color
        sharpenal.strokeColor = color
        playScreen.addChild(sharpenal)
        sharpenal.physicsBody?.applyImpulse(CGVector(dx: impulse.dx, dy: impulse.dy))
    }
    
    public func getSharpenal() -> SKShapeNode {
        return sharpenal
    }
    
}
