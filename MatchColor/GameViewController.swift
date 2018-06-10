//
//  GameViewController.swift
//  MatchColor
//
//  Created by Tuyen Le on 6/7/18.
//  Copyright © 2018 Tuyen Le. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        let startScreen = StartScreen(size: view.frame.size)
        let skView = view as! SKView
        skView.presentScene(startScreen)
    }
}
