//
//  ObstacleNode.swiftt.swift
//  AstroRun
//
//  Created by Mehul Arora on 12/10/20.
//  Copyright © 2020 Mehul Arora. All rights reserved.
//

import SpriteKit

class ObstacleNode: SKSpriteNode{
    
    let speedMultiplier: Double
    let baseSpeed : Double = 250
    
    init(speedMultiplier: Double, startPosition: CGPoint){
        
        let texture = SKTexture(imageNamed: "obstacle")
        self.speedMultiplier = speedMultiplier
        
        super.init(texture: texture, color: .white, size: CGSize(width: 80, height: 80))
        
        
        physicsBody = SKPhysicsBody(texture: texture, size: CGSize(width: 80, height: 80))
        
        physicsBody?.categoryBitMask = Collisions.obstacle.rawValue
        physicsBody?.collisionBitMask = Collisions.player.rawValue
        physicsBody?.contactTestBitMask = Collisions.player.rawValue
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        
        name = "obstacle"
        
        position = startPosition
        
        movement()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func movement(){
        let path = UIBezierPath()
        path.move(to: .zero)
        
        path.addLine(to: CGPoint(x: -10000, y: 0))
        
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: false, speed: CGFloat(baseSpeed * speedMultiplier))
//        let sequence = SKAction.sequence([movement, .removeFromParent()])
//        let sequence = completion
        run(movement, completion: {
            self.removeFromParent()
        })
    }
}
