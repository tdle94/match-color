//
//  GameScene.swift
//  MatchColor
//
//  Created by Tuyen Le on 6/7/18.
//  Copyright © 2018 Tuyen Le. All rights reserved.
//

import SpriteKit
import GameplayKit

class StartScreen: SKScene {
    private var playLabel: SKLabelNode = SKLabelNode()
    private var circleLabel: SKShapeNode = SKShapeNode(circleOfRadius: 10)
    private var playScreen: PlayScreen?
    
    override init(size: CGSize) {
        super.init(size: size)
        playScreen = PlayScreen(size: size)
        setupPlayLabel()
        setupCircleLabel()
    }
    
    private func setupPlayLabel() {
        playLabel.text = "Tap To Play"
        playLabel.name = "Play"
        playLabel.fontSize = 60
        playLabel.fontName = "AvenirNext-Bold"
        playLabel.fontColor = SKColor.green
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        playLabel.isUserInteractionEnabled = false
        playLabel.run(blinkAnimation())
    }
    
    private func setupCircleLabel() {
        circleLabel.position = CGPoint(x: frame.midX, y: frame.minY + frame.maxY/4)
        circleLabel.strokeColor = SKColor.black
        circleLabel.glowWidth = 1.0
        circleLabel.fillColor = SKColor.gray
        circleLabel.run(animateCircle())
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    override func didMove(to view: SKView) {
        addChild(playLabel)
        addChild(circleLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _: AnyObject in touches {
            let transition: SKTransition = SKTransition.fade(withDuration: 1)
            self.view?.presentScene(playScreen!, transition: transition)
        }
    }
    
    private func animateCircle() -> SKAction {
        let duration: TimeInterval = 1.0
        let moveTo = CGPoint(x: frame.midX + frame.maxX/4, y: frame.minY + frame.maxY/4)
        let moveBack = CGPoint(x: frame.midX - frame.maxX/4, y: frame.minY + frame.maxY/4)
        let moveRight = SKAction.move(to: moveTo, duration: duration)
        let moveLeft = SKAction.move(to: moveBack, duration: duration)
        let move = SKAction.sequence([moveRight, moveLeft])
        
        return SKAction.repeatForever(move)
    }
    
    private func blinkAnimation() -> SKAction {
        let duration: TimeInterval = 1.0
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: duration)
        let fadeIn = SKAction.fadeAlpha(to: 0.5, duration: duration)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        
        return SKAction.repeatForever(blink)
    }
}
