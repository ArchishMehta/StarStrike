//
//  GameViewController.swift
//  StarStrike
//
//  Created by Archish Mehta on 2024-12-28.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // load the SKScene from 'GameScene.sks'
            let scene = GameScene(size: CGSize(width: 1536, height: 2048))
            
            // set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
