//
//  GameScene.swift
//  iOS_Quiz
//
//  Created by Owner on 3/10/17.
//  Copyright © 2017 Owner. All rights reserved.
//

import SpriteKit
import GameplayKit
import AudioToolbox
import AVFoundation


class GameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate {
    
    var playerTruck: SKSpriteNode = SKSpriteNode()
    let background1 = SKSpriteNode(imageNamed: "bg1")
    let barrelCategory:UInt32 = 0x1 << 1
    let civCategory:UInt32 = 0x1 << 2
    let catCategory:UInt32 = 0x1 << 3
    let carCategory:UInt32 = 0x1 << 0
    let failed = SKAction.playSoundFileNamed("fail.mp3", waitForCompletion: false)
    let blarg = SKAction.playSoundFileNamed("blarg.mp3", waitForCompletion: false)
    let meow = SKAction.playSoundFileNamed("meow.wav", waitForCompletion: false)
    let pain1 = SKAction.playSoundFileNamed("civ_pain1.wav", waitForCompletion: false)
    let thud = SKAction.playSoundFileNamed("thud.mp3", waitForCompletion: false)
    let bgm = SKAction.repeatForever(SKAction.playSoundFileNamed("bgm.wav", waitForCompletion: true))
    let siren = SKAction.repeatForever(SKAction.playSoundFileNamed("siren.wav", waitForCompletion: true))

    private var score = 0;
    private var scoreLabel: SKLabelNode?;
    private var casualty = 3;
    private var casualtyLabel: SKLabelNode?;
    
    var bgmEffect: AVAudioPlayer!
    var sirenEffect: AVAudioPlayer!
    
    
    override func didMove(to view: SKView) {
        
        let path = Bundle.main.path(forResource: "bgm.wav", ofType:nil)!
        let path2 = Bundle.main.path(forResource: "siren.wav", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        let url2 = URL(fileURLWithPath: path2)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            let sound2 = try AVAudioPlayer(contentsOf: url2)
            bgmEffect = sound
            sirenEffect = sound2
            sound.numberOfLoops = -1
            sound2.numberOfLoops = -1
            sound.play()
            sound2.play()
        } catch {
            // couldn't load file :(
        }
        
//        self.run(bgm, withKey: "bgm")
//        self.run(siren)
        
        if let someTruck:SKSpriteNode = self.childNode(withName: "ambulance") as? SKSpriteNode {
            playerTruck = someTruck
            playerTruck.physicsBody = SKPhysicsBody(circleOfRadius: max(playerTruck.size.width / 4, playerTruck.size.height / 2))
            playerTruck.physicsBody?.isDynamic = true
            playerTruck.physicsBody?.categoryBitMask = carCategory
            playerTruck.physicsBody?.contactTestBitMask = barrelCategory | civCategory
            playerTruck.physicsBody?.collisionBitMask = barrelCategory | civCategory
        }
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5) // car spawn point
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        Timer.scheduledTimer(timeInterval: 1.9, target: self, selector: Selector("addBarrel"), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 3.3, target: self, selector: Selector("addCiv"), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 4.2, target: self, selector: Selector("addCat"), userInfo: nil, repeats: true)
        background1.anchorPoint = CGPoint(x: 0.5,y :0.25)
        background1.size = CGSize(width: 800, height: 3000)
        background1.zPosition = -15
        self.addChild(background1)
        
        scoreLabel = childNode(withName: "Score") as? SKLabelNode!;
        scoreLabel?.text = "0"
        casualtyLabel = childNode(withName: "Casualty") as? SKLabelNode!;
        casualtyLabel?.text = "3"
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        background1.position = CGPoint(x: background1.position.x, y: background1.position.y - 30)
        if(background1.position.y < -1500)
        {
            background1.position = CGPoint(x: 0.5,y :0.25)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if (firstBody.categoryBitMask & carCategory) != 0 && (secondBody.categoryBitMask & barrelCategory) != 0 {
            collided(carNode: firstBody.node as! SKSpriteNode, barrelNode: secondBody.node as! SKSpriteNode)
        }
        else if (firstBody.categoryBitMask & carCategory) != 0 && (secondBody.categoryBitMask & civCategory) != 0 {
            collided2(carNode: firstBody.node as! SKSpriteNode, civNode: secondBody.node as! SKSpriteNode)
        }
        else if (firstBody.categoryBitMask & carCategory) != 0 && (secondBody.categoryBitMask & catCategory) != 0 {
            collided3(carNode: firstBody.node as! SKSpriteNode, catNode: secondBody.node as! SKSpriteNode)
        }
        else {}
    }
    func collided(carNode:SKSpriteNode, barrelNode:SKSpriteNode){
        barrelNode.removeFromParent()
        self.run(thud)
        self.run(blarg)
        score += 100
        scoreLabel?.text = String(score);
        
//         animation for car recoil when colliding with things
        let recoil:SKAction = SKAction.moveBy(x:0, y:-70, duration: 0.1)
        let vait = SKAction.wait(forDuration: 0.1)
        let recoil2:SKAction = SKAction.moveBy(x:0, y:70, duration: 0.3)
        let actionGroup = SKAction.group([recoil, vait])
        playerTruck.run(actionGroup, completion:{self.playerTruck.run(recoil2)})
    }
    func collided2(carNode:SKSpriteNode, civNode:SKSpriteNode){
        civNode.removeFromParent()
        self.run(pain1)
        self.run(thud)
        casualty -= 1
        casualtyLabel?.text = String(casualty);
        
//         animation for car recoil when colliding with things
        let recoil:SKAction = SKAction.moveBy(x:0, y:-70, duration: 0.1)
        let vait = SKAction.wait(forDuration: 0.1)
        let recoil2:SKAction = SKAction.moveBy(x:0, y:70, duration: 0.3)
        let actionGroup = SKAction.group([recoil, vait])
        playerTruck.run(actionGroup, completion:{self.playerTruck.run(recoil2)})
        
        if self.casualty == 0 {
            self.run(failed)
            if bgmEffect != nil {
                bgmEffect.stop()
                sirenEffect.stop()
                bgmEffect = nil
                sirenEffect = nil
            }
            gameOver()
        }
    }
    func collided3(carNode:SKSpriteNode, catNode:SKSpriteNode){
        catNode.removeFromParent()
        self.run(meow)
        self.run(thud)
        score -= 50
        scoreLabel?.text = String(score);
        
        //         animation for car recoil when colliding with things
        let recoil:SKAction = SKAction.moveBy(x:0, y:-70, duration: 0.1)
        let vait = SKAction.wait(forDuration: 0.1)
        let recoil2:SKAction = SKAction.moveBy(x:0, y:70, duration: 0.3)
        let actionGroup = SKAction.group([recoil, vait])
        playerTruck.run(actionGroup, completion:{self.playerTruck.run(recoil2)})
    }
    
    func addBarrel(){
        let barrel = SKSpriteNode(imageNamed: "z1")
        barrel.size.width =  130
        barrel.size.height = 170
        
        let randPos = 400 - Double(arc4random_uniform(UInt32(800)))
        barrel.position = CGPoint (x: CGFloat(randPos), y: self.size.height)
        
        barrel.physicsBody = SKPhysicsBody(circleOfRadius: max(barrel.size.width / 4, barrel.size.height / 4))
        barrel.physicsBody?.isDynamic = true
        
        barrel.physicsBody?.categoryBitMask = barrelCategory
        barrel.physicsBody?.contactTestBitMask = carCategory
        barrel.physicsBody?.collisionBitMask = carCategory
//        playerTruck.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(barrel)
        
        let animationDuration: TimeInterval = 1.4
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: barrel.position.x, y: -(barrel.size.height+600)), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        barrel.run(SKAction.sequence(actionArray))
    }
    func addCiv(){
        let civ = SKSpriteNode(imageNamed: "c1")
        civ.size.width =  90
        civ.size.height = 150
        
        let randPos = 400 - Double(arc4random_uniform(UInt32(800)))
        civ.position = CGPoint (x: CGFloat(randPos), y: self.size.height)
        
        civ.physicsBody = SKPhysicsBody(circleOfRadius: max(civ.size.width / 6, civ.size.height / 6))
        civ.physicsBody?.isDynamic = true
        
        civ.physicsBody?.categoryBitMask = civCategory
        civ.physicsBody?.contactTestBitMask = carCategory
        civ.physicsBody?.collisionBitMask = carCategory
            
        self.addChild(civ)
        
        let animationDuration: TimeInterval = 1.4
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: civ.position.x, y: -(civ.size.height+600)), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        civ.run(SKAction.sequence(actionArray))
    }
    func addCat(){
        let civ = SKSpriteNode(imageNamed: "cat")
        civ.size.width =  110
        civ.size.height = 70
        
        let randPos = 450 - Double(arc4random_uniform(UInt32(700)))
        civ.position = CGPoint (x: CGFloat(randPos), y: self.size.height)
        
        civ.physicsBody = SKPhysicsBody(circleOfRadius: max(civ.size.width / 6, civ.size.height / 6))
        civ.physicsBody?.isDynamic = true
        
        civ.physicsBody?.categoryBitMask = catCategory
        civ.physicsBody?.contactTestBitMask = carCategory
        civ.physicsBody?.collisionBitMask = carCategory
        
        self.addChild(civ)
        
        let animationDuration: TimeInterval = 1.4
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: civ.position.x, y: -(civ.size.height+600)), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        civ.run(SKAction.sequence(actionArray))
    }

    
    func moveLeft(){
        let moveAction:SKAction = SKAction.moveBy(x:150, y:0, duration: 0.3)
        
        let rot1 = SKAction.rotate(byAngle: -0.2, duration: 0.1)
        let vait = SKAction.wait(forDuration: 0.1)
        let rot2 = SKAction.rotate(byAngle: 0.2, duration: 0.1)
        let actionGroup = SKAction.group([moveAction, rot1, vait])
//        playerTruck.run(moveAction)
        playerTruck.run(actionGroup, completion:{self.playerTruck.run(rot2)})
    }

    func moveRight(){
        
        let moveAction:SKAction = SKAction.moveBy(x:-150, y:0, duration: 0.3)
        let rot1 = SKAction.rotate(byAngle: 0.2, duration: 0.1)
//        playerTruck.run(moveAction)
        let vait = SKAction.wait(forDuration: 0.1)
        let rot2 = SKAction.rotate(byAngle: -0.2, duration: 0.1)
        let actionGroup = SKAction.group([moveAction, rot1, vait])
        
        playerTruck.run(actionGroup, completion:{self.playerTruck.run(rot2)})
    }
    
    func touchDown(atPoint pos : CGPoint) {
//        print("Tapped at: \(pos.x), \(pos.y)")
//        print("Car at: \(playerTruck.position.x)")
        if (pos.x > playerTruck.position.x && playerTruck.position.x < 250){
            moveLeft()
        } else if (pos.x < playerTruck.position.x && playerTruck.position.x > -250) {
            moveRight()
        }
    }
    
    func gameOver(){
        self.removeAllChildren()
        self.removeAllActions()
        self.scene?.removeFromParent()
        let gameOver = gameOverScene(fileNamed: "gameOverScene")
        self.view?.presentScene(gameOver!, transition: SKTransition.fade(withDuration: 0.5))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchDown(atPoint: t.location(in:self))
            break
        }
    }
    
    //    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    }
}
