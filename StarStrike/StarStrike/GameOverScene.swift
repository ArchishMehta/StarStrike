//
//  GameOverScene.swift
//  StarStrike
//
//  Created by Archish Mehta on 2024-12-30.
//

import Foundation
import SpriteKit

// make this into a scene and name it
class GameOverScene: SKScene {
    let restartLabel = SKLabelNode(fontNamed: "The Bold Font")
    // as soon as we move to this scene
    override func didMove(to view: SKView) {
        // same as gamescene
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(text: "The Bold Font")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 2150
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        scoreLabel.text = "SCORE: \(gameScore)"
        scoreLabel.fontColor = SKColor.white
        scoreLabel.fontSize = 100
        scoreLabel.position = CGPoint(x: self.size.width / 2 , y: self.size.height * 0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        // getting the high score
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        // if your game score is more than previous high score
        if gameScore > highScoreNumber {
            // update it so now thats your latest high score
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        highScoreLabel.text = "HIGHSCORE: \(highScoreNumber)"
        highScoreLabel.fontSize = 100
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.45)
        self.addChild(highScoreLabel)
        
       
        restartLabel.text = "RESTART"
        restartLabel.fontSize = 60
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.3)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // for all the touches made
        for touch: AnyObject in touches {
            // finding out if restart button is hit
            // set the info of touch = pointoftouch
            let pointOfTouch = touch.location(in: self)
            // going to compare if pointOfTouch is equal to the restart button
            // if the restart label has the point of touch
            if restartLabel.contains(pointOfTouch) {
                //the size of the scene should be the size of the current scene
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                // transition to game screen
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
                
            }
        }
    }
    
}
