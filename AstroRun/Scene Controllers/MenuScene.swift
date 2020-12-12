//
//  MenuScene.swift
//  ShadowRun
//
//  Created by Mehul Arora on 12/11/20.
//  Copyright © 2020 Mehul Arora. All rights reserved.
//

import SpriteKit
import Foundation

class MenuScene: SKScene {
 
    override func didMove(to toView: SKView) {
        
        self.backgroundColor = SKColor(red: 10/255, green: 21/255, blue: 41/255, alpha: 1)
        
        if let particles = SKEmitterNode(fileNamed: "rainparticles.sks"){
            particles.position = CGPoint(x: 50, y: 600)
            particles.advanceSimulationTime(120)
            particles.zPosition = -5
            addChild(particles)
        }
        
        let title = SKLabelNode(text: "ASTRO RUN")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 120
        title.position = CGPoint(x: 0, y: self.size.height / 5)
        addChild(title)


        let playButton = SKLabelNode(text: "Tap anywhere to Play")
        playButton.name = "PlayButton"
        addChild(playButton)
        playButton.position = CGPoint(x: 0, y: -self.size.height / 6)
        playButton.zPosition = 1
        
        let scoreInfo = UserDefaults.standard.integer(forKey: "HighScore")
        let score = SKLabelNode(text: "High Score: \(scoreInfo)")
        score.fontName = "AvenirNext-Medium"
        score.position = CGPoint(x: 0, y: -self.size.height / 3)
        addChild(score)
        
        scene?.scaleMode = .fill
    }

    func play() {
        let game = GameScene(size:self.size)
//        game.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 1)
        self.view?.presentScene(game, transition: transition)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches{
            // To expand functionality, if needed.
//            let location = touch.location(in: self)
//            let touchedNode = atPoint(location)
//
//            if touchedNode.name == "PlayButton" {
//                 play()
//            }
            
            play()
        }
    }
}
