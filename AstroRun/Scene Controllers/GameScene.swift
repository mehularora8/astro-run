//
//  GameScene.swift
//  AstroRun
//
//  Created by Mehul Arora on 12/8/20.
//  Copyright © 2020 Mehul Arora. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "run2")
    var playerLives = 1
    
    /* Configuration variables */
    var isPlayerAlive = true
    var score = 0
    var level = 0
    var speedMultiplier = 1.0
    var isPlayerInvincible = false
    var lastInvincibleTimestamp : TimeInterval = 0
    
    /* Helper variables */
    var lastCreatedTimestamp : TimeInterval? = nil
    var scoreCount = 0
    
    var scoreLabel = SKLabelNode()
    
    override func update(_ currentTime: TimeInterval) {
        
        guard isPlayerAlive else { return }
        
        if player.frame.maxY < frame.minY {
            gameOver()
            return
        }
        
        if player.position.y > frame.maxY - 20 {
            player.position.y = frame.maxY - 20
        }
        
        for child in children{
            if child.frame.maxX < frame.minX {
                if !frame.intersects(child.frame){
                    child.removeFromParent()
                }
            }
        }
        
        scoreCount += 1
        
        if scoreCount % 4 == 0{
            score += 1
            scoreLabel.text = "Score: \(score)"
        }
        
        scoreCount = scoreCount % 60
        
        if score > level * 400 {
            self.backgroundColor = colors[level % colors.count]
            level += 1
        }
        
        let activeObstacles = children.compactMap( { $0 as? ObstacleNode })
        
        var delta = Double(0)
        
        if let _ = lastCreatedTimestamp {
            delta = currentTime - lastCreatedTimestamp!
        } else{
            delta = 1
            lastCreatedTimestamp = currentTime
        }
        
        if activeObstacles.count == 0 && delta >= 1 {
            speedMultiplier *= 1.05
            lastCreatedTimestamp = currentTime
            
            createObstacles()
        }
    }
    
    override func didMove(to view: SKView) {
        
        scoreLabel.position = CGPoint(x: frame.maxX - 180, y: frame.maxY - 50)
        scoreLabel.fontName = "AvenirNext-Bold"
        
        addChild(scoreLabel)
        
        
        self.backgroundColor = SKColor(red: 10/255, green: 21/255, blue: 41/255, alpha: 1)
        
        physicsWorld.contactDelegate = self
        
        if let particles = SKEmitterNode(fileNamed: "rainparticles.sks"){
            particles.position = CGPoint(x: 450, y: 600)
            particles.advanceSimulationTime(120)
            particles.zPosition = -5
            addChild(particles)
        }
        
        player.name = "playerNode"
        player.position.x = frame.minX + 75
        player.position.y = frame.maxY - 150
        player.zPosition = 1
        player.size = CGSize(width: 80, height: 80)
        
        addChild(player)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = Collisions.player.rawValue
        player.physicsBody?.collisionBitMask = Collisions.obstacle.rawValue
        player.physicsBody?.contactTestBitMask = Collisions.obstacle.rawValue
        player.physicsBody?.isDynamic = true
        player.physicsBody?.mass = 1.0
        player.physicsBody?.affectedByGravity = true
    }
    
    func createObstacles() {
        guard isPlayerAlive else { return }
        
        for _ in 0 ..< 10 {
                
            let obstacleStartY = CGFloat.random(in: `self`.frame.minY ..< `self`.frame.maxY)
            let obstacleStartX = CGFloat(1050) + CGFloat.random(in: 0 ..< 1000)
            
            let newObstacle = ObstacleNode(speedMultiplier: `self`.speedMultiplier, startPosition: CGPoint(x: obstacleStartX, y: obstacleStartY))
            
            self.addChild(newObstacle)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isPlayerAlive {
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 400))
        } else {
            for touch in touches {
                let location = touch.location(in: self)
                let touchedNode = atPoint(location)
                
                if touchedNode.name == "HomeButton" {
                    goToHome()
                } else {
                    play()
                }
            }
        }
    }
    
    func goToHome(){
        if let originalScene = SKScene(fileNamed: "MenuScene"){
            originalScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1)
            view?.presentScene(originalScene, transition: transition)
        }
    }
    
    func play() {
        let game = GameScene(size:self.size)
        let transition = SKTransition.fade(withDuration: 1)
        self.view?.presentScene(game, transition: transition)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let _ = contact.bodyA.node else { return }
        guard let _ = contact.bodyB.node else { return }
        
        guard isPlayerAlive else { return }
        
        playerLives -= 1
        
        if playerLives == 0 {
            gameOver()
        }
    }
    
    func gameOver(){
        self.isPlayerAlive = false
        
        let over = SKSpriteNode(imageNamed: "gameOver")
        over.position = CGPoint(x: self.size.width / 2, y: 3 * self.size.height / 4)
        addChild(over)
        
        scoreLabel.position = CGPoint(x: self.size.width / 2, y : self.size.height / 3)
        scoreLabel.text = "Score: \(self.score)"
        
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "HighScore")
            let highScoreLabel = SKLabelNode(text: "New High Score!")
            highScoreLabel.zRotation = -CGFloat.pi / 4
            highScoreLabel.position = CGPoint(x: scoreLabel.position.x + scoreLabel.frame.width / 2 + 20, y: scoreLabel.position.y + scoreLabel.frame.height / 2 + 20)
            
            addChild(highScoreLabel)
        }
        
        let replay = SKLabelNode(text: "Tap anywhere to play again")
        replay.position = CGPoint(x: self.size.width / 2, y: self.size.height / 7)
        replay.name = "ReplayButton"
        addChild(replay)
        replay.zPosition = 1
        
        let home = SKSpriteNode(imageNamed: "home")
        home.position = CGPoint(x: self.size.width - 60, y: self.size.height - 60)
        home.size = CGSize(width: 50, height: 50)
        home.name = "HomeButton"
        addChild(home)
        home.zPosition = 1
    }
}
