//
//  GameScene.swift
//  StarStrike
//
//  Created by Archish Mehta on 2024-12-29.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    
    // declare it up here to make it a global var
    let player = SKSpriteNode(imageNamed: "playerShip")
    // declare the sound gloablay to avoid lag
    let bulletSound = SKAction.playSoundFileNamed("laser-shot-ingame-230500", waitForCompletion: false)
    // delare the sound globally to avoid lag
    let explosionSound = SKAction.playSoundFileNamed("break-boom-fx-240235", waitForCompletion: false)
    
    // structure for the different physics body
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1
        static let Bullet: UInt32 = 0b10
        static let Enemy : UInt32 = 0b100
    }
    
    // utility functions
    // generate a random CGFloat between 0.0 and 1.0
    func random() -> CGFloat {
        return CGFloat.random(in: 0...1)
    }

    // generate a random CGFloat between a specified range
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random(in: min...max)
    }
    
    
    // creating the game area(the screen of an ipad is bigger than an iphone so some parts of the game may get cut off) to avoid that create a rectangle that will be the parameter of the ships to move and spawn
    // do it globaly
    var gameArea: CGRect
    // scene initialzier
    override init (size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size:size)
        
    }
    // given by compiler
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // runs as soon as the scene loads up
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
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
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        // gravity wont effect the playership
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        // make the player with all these attributes
        self.addChild(player)

    }
    // function when two physic body make contact
    func didBegin(_ contact: SKPhysicsContact) {
        // variables needed to see how the contact between the bodies occurs
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            // if the player has hit the enemy
            // delete player and enemey
            // call the spawn explosion function
            if body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        if body2.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < self.size.height {
            // if the bullet hit the enemy
            // delete the bullet and enemy
            // call the spawn explosion function and explode enemy ship
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
    }
    
    // function deals with the explosion
    func spawnExplosion(spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        // making the explosion look cooler
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
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
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
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
    
    //function to spawn enemy
    func spawnEnemy() {
        // enemy gets spawned at a random x coordinate and ends at a random x coordinate
        let randomXStart = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        let randomXEnd = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        
        // where the enemy starts (random start and the y will be the top of the screen)
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        // where the enemy ends
        let endPoint = CGPoint (x: randomXEnd, y: -self.size.height * 0.2)
        
        // creating the enemy
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        // create the movement sequence
        // move to the endpoint in 1.5 seconds
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        // delete the enemy when it reaches the end point
        let deleteEnemy = SKAction.removeFromParent()
        // the sequence for which it should follow
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        // run it
        enemy.run(enemySequence)
        
        // delta x and y
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        // math to find the amount to rotate
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    
    // function to keep spawning enemies
    func startNewLevel() {
        let spawn = SKAction.run(spawnEnemy)
        // how long it should wait before spawning a new enemy (wait one second before spawning)
        let waitToSpawn = SKAction.wait(forDuration: 1)
        // sequence to run it by(spawn a enemy and than wait)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        // do it forever
        let spawnForever = SKAction.repeatForever(spawnSequence)
        // put that on the scene
        self.run(spawnForever)
        
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
            
            // make sure the ship stays in game area by asking question
            // gone too far to the right (if the player's x direction goes further than that of the game area)
            if player.position.x > CGRectGetMaxX(gameArea) - player.size.width / 2 {
                // push the player back to the game area max
                player.position.x = CGRectGetMaxX(gameArea) - player.size.width / 2
            }
            // gone too far to the left
            if player.position.x < CGRectGetMinX(gameArea) + player.size.width / 2  {
                // push the player back to the game area min
                player.position.x = CGRectGetMinX(gameArea) + player.size.width / 2
            }
        }
    }
    
}
