import SpriteKit

class gameOverScene: SKScene {
    
//    let backgroundMusic = SKAction.playSoundFileNamed("audio3.wav", waitForCompletion: false)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self);
            
            if atPoint(location).name == "playButton" {
                if let scene = GameScene(fileNamed: "GameScene") {
                    scene.scaleMode = .aspectFill
                    view!.presentScene(scene, transition: SKTransition.flipVertical(withDuration: 1))
                }
            }
            
        }
    }
    override func didMove(to view: SKView) {
//        self.run(backgroundMusic)
        
        
    }
}
