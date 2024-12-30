//
//  GameScene.swift
//  StarStrike
//
//  Created by Archish Mehta on 2024-12-29.
//

import SpriteKit
import GameplayKit

// will keep track of the score(var is used when a variable value changes and let is used when value never changes)
// make it public so every other scene can use it

var gameScore = 0
class GameScene: SKScene, SKPhysicsContactDelegate {
   
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    // number of lives you start with
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    // will keep track of the level user is on
    var levelNumber = 0
    
    // declare it up here to make it a global var
    let player = SKSpriteNode(imageNamed: "playerShip")
    // declare the sound gloablay to avoid lag
    let bulletSound = SKAction.playSoundFileNamed("laser-shot-ingame-230500", waitForCompletion: false)
    // delare the sound globally to avoid lag
    let explosionSound = SKAction.playSoundFileNamed("break-boom-fx-240235", waitForCompletion: false)
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    // set up a data type to find what state of the game it's at(before,during, or end)
    enum gameState {
        // when the game state is before the start if the game
        case preGame
        // when the game state is during the game
        case inGame
        // when the game state is after the game
        case afterGame
    }
    
    // storing the state of the game
    var currentGameState = gameState.preGame
    
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
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        // manual background change
        // run the code from 0 upto and including 1
        for i in 0...1 {
            // create background
            // create variable "background" which holds the node(image called background)
            let background = SKSpriteNode(imageNamed: "background")
            // set the size of the background to match the scene(self in this case)
            // set background to be same size as scene
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            // position it to the center of the scene
            background.position = CGPoint(x: self.size.width/2, y: self.size.height * CGFloat(i))
            // the layering of "background" and you want it to be furthest back
            // lower the number = further back
            background.zPosition = 0
            background.name = "Background"
            // make the background with all these attributes
            self.addChild(background)
        }
        
        
        
        // create player(global)
        // create variable "player" which holds the node(image called playerShip)
        
        // set the size of the ship
        // if you want it to be bigger make the number bigger
        player.setScale(1)
        // the position is halfway in the x and at the bottom 20%
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
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
        
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "LIVES: 3"
        livesLabel.fontSize = 50
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + scoreLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        tapToStartLabel.text = "TAP TO BEGIN"
        tapToStartLabel.fontSize = 75
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.zPosition = 1
        // relates to the transparency
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)

    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    // move down 600 each sec
    let amountToMovePerSecond: CGFloat = 600.0
    // function to update the background
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        } else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background") {
            background, stop in
            if self.currentGameState == gameState.inGame {
                background.position.y -= amountToMoveBackground
            }
            
            if background.position.y < -self.size.height {
                background.position.y += self.size.height*2
            }
        }
    }
    
    
    // function to move pregame state to ingame
    func startGame() {
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
    }
    
    // function to lose a life
    func loseALife() {
        // decrease the life by one and use an fstring to show it
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp,scaleDown])
        livesLabel.run(scaleSequence)
        
        // if you reach 0 lives
        if livesNumber == 0 {
            // gameover
            runGameOver()
        }
    }
    
    
    // function to add the score
    func addScore() {
        // add 1 to score
        gameScore += 1
        // fstring
        scoreLabel.text = "Score: \(gameScore)"
        
        // if score is 10 ,25, or 50 push to the next level
        if gameScore == 10 || gameScore == 25 || gameScore == 50 {
            startNewLevel()
        }
    }
    
    
    
    // function to run when the game ends
    func runGameOver() {
        // when the game is over go to the end state
        currentGameState = gameState.afterGame
        
        // when should this function run(added to didbegincontact and losealife)
        // have to stop all actions before we can show the score
        // stop spawning enemies
        self.removeAllActions()
        // stop spawning bullets
        // generates a list of all actions with bullet on the scene
        self.enumerateChildNodes(withName: "Bullet") {
            // cycle through the list one at a time
            bullet, stop in
            // remove that action
            bullet.removeAllActions()
        }
        
        // stop spawning enemies
        // generates a list of all actions with enemies on the scene
        self.enumerateChildNodes(withName: "Enemy") {
            // cycle through the list one at a time
            enemy, stop in
            // remove that action
            enemy.removeAllActions()
        }
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
    }
    
    // function to change to gameoverScene
    func changeScene() {
        // move to the gameoverScene and the size should be the size of the current scene
        let sceneToMoveTo = GameOverScene(size: self.size)
        // should also have the same scale
        sceneToMoveTo.scaleMode = self.scaleMode
        // transition into the new scene with fade of 0.5s
        let myTransition = SKTransition.fade(withDuration: 0.5)
        // take the current view and get rid of it and use the transition
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
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
            
            //game over
            runGameOver()
        }
        if body2.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < self.size.height {
            // add 1 to the score
            addScore()
            
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
        // give a referance name to call it outside without making it a global variable
        bullet.name = "Bullet"
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
        enemy.name = "Enemy"
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
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        // saftey
        if currentGameState == gameState.inGame {
            // run it
            enemy.run(enemySequence)
        }
        
        // delta x and y
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        // math to find the amount to rotate
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    
    // function to keep spawning enemies
    func startNewLevel() {
        // increment the level
        levelNumber += 1
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.4
            print("Cannot find level info")
        }
        
        
        let spawn = SKAction.run(spawnEnemy)
        // how long it should wait before spawning a new enemy (wait one second before spawning)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        // sequence to run it by(spawn a enemy and than wait)
        let spawnSequence = SKAction.sequence([spawn,waitToSpawn])
        // do it forever
        let spawnForever = SKAction.repeatForever(spawnSequence)
        // put that on the scene
        self.run(spawnForever, withKey: "spawningEnemies")
        
    }
 
    
    
    // function whenever screen is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //if the current game start is before the game than trigger start of the game
        if currentGameState == gameState.preGame {
            startGame()
        }
        // only fire a bullet when the game is active
        else if currentGameState == gameState.inGame {
            // when screen is touched fire a bullet
            fireBullet()
            spawnEnemy()
        }
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
            // only if the game is active and being played
            if currentGameState == gameState.inGame {
                // move player by the amount dragged
                player.position.x += amountDragged
            }
            
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
