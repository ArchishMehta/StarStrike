//
//  GameScene.swift
//  StarStrike
//
//  Created by Archish Mehta on 2024-12-29.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // declare it up here to make it a global var
    let player = SKSpriteNode(imageNamed: "playerShip")
    // declare the sound gloablay to avoid lag
    let bulletSound = SKAction.playSoundFileNamed("laser-shot-ingame-230500", waitForCompletion: false)
    
    // runs as soon as the scene loads up
    override func didMove(to view: SKView) {
        // create background
        // create variable "background" which holds the node(image called background)
        let background = SKSpriteNode(imageNamed: "background")
        // set the size of the background to match the scene(self in this case)
        // set background to be same size as scene
        background.size = self.size
        // position it to the center of the scene
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        // the layering of "background" and you want it to be furthest back
        // lower the number = further back
        background.zPosition = 0
        // make the background with all these attributes
        self.addChild(background)
        
        
        // create player
        // create variable "player" which holds the node(image called playerShip)
        
        // set the size of the ship
        // if you want it to be bigger make the number bigger
        player.setScale(1)
        // the position is halfway in the x and at the bottom 20%
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        // want this at 2 and not 1 because the bullet will be coming from under the spaceship
        player.zPosition = 2
        // make the player with all these attributes
        self.addChild(player)

    }
    
    // function to spawn and fire a bullet
    func fireBullet() {
        // create variable "bullet" which holds the node(image called bullet)
        let bullet = SKSpriteNode(imageNamed: "bullet")
        // set the size of the bullet
        bullet.setScale(1)
        // make the bullet spawn where ever the ship is (change player to a global variable)
        bullet.position = player.position
        // make the bullet spawn from under the space ship
        bullet.zPosition = 1
        // make the bullet with these attributes
        self.addChild(bullet)
        
        // move to the end of the screen in one second
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        // delete the bullet
        let deleteBullet = SKAction.removeFromParent()
        // run these actions in order using an array
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        // do it
        bullet.run(bulletSequence)
    }
    
    // function whenever screen is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // when screen is touched fire a bullet
        fireBullet()
    }
    
    
    // function to move ship
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            // coordinate of where screen is touched right now
            let pointOfTouch = touch.location(in: self)
            // coordinate of where screen was previously touched
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            // amount that you moved
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            // move player by the amount dragged
            player.position.x += amountDragged
        }
    }
    
}
