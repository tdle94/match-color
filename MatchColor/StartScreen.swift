//
//  GameScene.swift
//  MatchColor
//
//  Created by Tuyen Le on 6/7/18.
//  Copyright © 2018 Tuyen Le. All rights reserved.
//

import SpriteKit
import GameplayKit

class MenuView: SKScene {
    private var playLabel: SKLabelNode = SKLabelNode()
    
    override init(size: CGSize) {
        super.init(size: size)
        playLabel.text = "Play"
        playLabel.fontSize = 65
        playLabel.fontName = "AvenirNext-Bold"
        playLabel.fontColor = SKColor.green
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        playLabel.isUserInteractionEnabled = true
        playLabel.run(blinkAnimation())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    override func didMove(to view: SKView) {
        addChild(playLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let point = touch.location(in: self)
            let nodeUserTapped = atPoint(point)
            if (nodeUserTapped.name == "Play") {
                print("WTF")
            }
            else {print("WTF")}
        }
    }
    
    private func blinkAnimation() -> SKAction {
        let duration:TimeInterval = 1.0
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: duration)
        let fadeIn = SKAction.fadeAlpha(to: 0.5, duration: duration)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        return SKAction.repeatForever(blink)
    }
}
