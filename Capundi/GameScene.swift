//
//  GameScene.swift
//  Capundi
//
//  Created by Adhella Subalie on 29/04/21.
//


import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    var cup_back :SKSpriteNode!
    var cup_front :SKSpriteNode!
    var spoon :SKSpriteNode!
    var coffee :SKSpriteNode!
    var spoonStir:SKSpriteNode!
    var stirringSound:SKAudioNode!
    var muteButton:SKSpriteNode!
    
    
    var spinningTexture:[SKTexture] = []
    var currCoffeeIndex = 0
    var initialSpoonPosition:CGPoint?
    var initialSpoonAngle:CGFloat?
    var initialSpoonStirPosition: CGPoint?
    var initialSpoonStirAngle:CGFloat?
    var movableSpoon :SKSpriteNode?
    var isSpinning = false
    var isMuted = false
    
    
    override func didMove(to view: SKView) {
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        let delay3s = SKAction.wait(forDuration: 3)
        let delay3point5s = SKAction.wait(forDuration: 3.5)
        spinCoffeeTexture()
        
        if let cb = self.childNode(withName: "cup_back") as? SKSpriteNode{
            cup_back = cb
            cup_back.alpha = 0
        }
        if let cf = self.childNode(withName: "cup_front") as? SKSpriteNode{
            cup_front = cf
//            cup_front.physicsBody = SKPhysicsBody(texture: cup_front.texture!, size: cup_front.texture!.size())
//            cup_front.position = CGPoint(x: -3.847, y: -177.781)
//            cup_front.physicsBody?.isDynamic = true
//            cup_front.physicsBody?.affectedByGravity = false
//            cup_front.physicsBody?.pinned = true
            cup_front.alpha = 0
        }
        
        if let s = self.childNode(withName: "spoon") as? SKSpriteNode{
            spoon = s
//            spoon.physicsBody = SKPhysicsBody(texture: spoon.texture!, size: spoon.texture!.size())
            spoon.alpha = 0
            initialSpoonPosition = spoon.position
            initialSpoonAngle = spoon.zRotation
//            let texture =  SKTexture(imageNamed: "spoon.png")
//            print("spoon size \(spoon.size)")
//            spoon.physicsBody?.usesPreciseCollisionDetection = true
        }
        if let mb = self.childNode(withName: "muteButton") as? SKSpriteNode{
            muteButton = mb
            muteButton.alpha = 0
        }
        
        if let ss = self.childNode(withName: "spoonStir") as? SKSpriteNode{
            spoonStir = ss
            spoonStir.alpha = 0
            initialSpoonStirPosition = spoonStir.position
            initialSpoonStirAngle = spoonStir.zRotation
        }
        

        if let c = self.childNode(withName: "coffee") as? SKSpriteNode{
            coffee = c
        }
        
        
        let spoonSequence = SKAction.sequence([delay3s,appear])
        let muteButtonSequence = SKAction.sequence([delay3point5s,appear])
        
        cup_back.run(appear)
        cup_front.run(appear)
        coffeePour()
        spoon.run(spoonSequence)
        muteButton.run(muteButtonSequence)
        
    }
    
    func mute() {
        let muteTexture = SKTexture(imageNamed: "mute")
        let unmuteTexture = SKTexture(imageNamed: "unmute")
        
        if isMuted{
            muteButton.texture = muteTexture
            isMuted = false
        }else{
            muteButton.texture = unmuteTexture
            isMuted = true
        }
    }
    
    func soundFlag(sound: SKAction)->SKAction{
        if isMuted{
            return SKAction.changeVolume(to: 0, duration: 0)
        }else{
            return sound
        }
    }
    
    func coffeePour(){
        let targetPosition = coffee.position
        coffee.position = CGPoint(x: targetPosition.x, y: targetPosition.y-200)
        let delay = SKAction.wait(forDuration: 0.8)
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        let up = SKAction.move(to: targetPosition, duration: 2)
        let pourSound = SKAction.playSoundFileNamed("pouring.mp3", waitForCompletion: false)
        let pouring = SKAction.sequence([delay,appear,pourSound,up])
        
        coffee.run(pouring)
    }
    
    func taptap(){
        let tap2 = SKAction.playSoundFileNamed("tap2", waitForCompletion: true)
        let sound = tap2
        
        run(soundFlag(sound: sound))
    }
    
    
    func loadStirringSound(){
        if let musicURL = Bundle.main.url(forResource: "stirring", withExtension: "mp3") {
            stirringSound = SKAudioNode(url: musicURL)
            self.addChild(stirringSound)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func spinCoffeeTexture(){
        let coffeeAnimatedAtlas = SKTextureAtlas(named: "coffee_spin")
        var coffeeTexture: [SKTexture] = []
        
        let numImages = coffeeAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let temp = "\(i)"
            coffeeTexture.append(coffeeAnimatedAtlas.textureNamed(temp))
        }
        spinningTexture = coffeeTexture
        
    }
    
    func spinCoffee(){
        let spinning = SKAction.animate(with: spinningTexture, timePerFrame: 0.1, resize: true, restore: true)
        isSpinning = true
        if !isMuted{
            loadStirringSound()
        }
        coffee.run(SKAction.repeatForever(spinning))
//                   , withKey:"walkingInPlaceBear")

    }
    
    
    func stirSpoon(){
        let circlepath = UIBezierPath(arcCenter: CGPoint(x: coffee.position.x , y: coffee.position.y - 30), radius: 70, startAngle: -90, endAngle: -89.999, clockwise: false)
        let action = SKAction.follow(circlepath.cgPath, asOffset: false, orientToPath: false, duration: 2)
        if spoonStir.alpha == 1{
            spoonStir.zRotation = 1.5
            spoonStir.run(SKAction.repeatForever(action))
        }
    }
    
}

extension GameScene{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchPosition = touch.location(in: self)
        let touchedNodes = nodes(at: touchPosition)
        for node in touchedNodes {
            if let nodeTouched = node as? SKSpriteNode {
                if nodeTouched == coffee{
                    if spoonStir.alpha == 1{
                        spinCoffee()
                        stirSpoon()
                    }
                    else if spoonStir.alpha == 0 && movableSpoon == nil{
                        spinCoffee()
                    }
                }else if nodeTouched == cup_front{
                    taptap()
                }
                else if nodeTouched == spoon{
                    if spoon.contains(touchPosition) {
                        movableSpoon = spoon
                        movableSpoon?.zRotation += 0.7
                        movableSpoon!.position = touchPosition
                    }
                }else if nodeTouched == spoonStir{
                    spoonStir.alpha = 0
                    movableSpoon?.alpha = 1
                }else if nodeTouched == muteButton{
                    mute()
                    
                }
            }
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, movableSpoon != nil {
            movableSpoon!.position = touch.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, movableSpoon != nil {
            let touchPosition = touch.location(in: self)
            
            if coffee.contains(touchPosition){
                spoonStir.alpha = 1
                movableSpoon?.alpha = 0
            }else if spoonStir.alpha != 1 {
                var putDownSound = SKAction.playSoundFileNamed("putspoondown.mp3", waitForCompletion: false)
                putDownSound = soundFlag(sound: putDownSound)
                let toInit = SKAction.move(to: self.initialSpoonPosition!, duration: 0.3)
                let toInitRotation = SKAction.rotate(byAngle: -0.7, duration: 0.1)
                let sequence = SKAction.sequence([toInit,putDownSound,toInitRotation])
                
                self.movableSpoon?.run(sequence)
                self.movableSpoon = nil
            }
        }
        if isSpinning{
            coffee.removeAllActions()
            spoonStir.removeAllActions()
            spoonStir.zRotation = initialSpoonStirAngle!
            spoonStir.position = initialSpoonStirPosition!
            if !isMuted{
                stirringSound.removeFromParent()
//                stirringSound.run(SKAction.stop())
            }
            isSpinning = false
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            movableSpoon = nil
        }
        
    }
}
