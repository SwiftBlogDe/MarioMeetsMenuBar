//
//  MarioController.swift
//  MarioMeetsMenuBar
//
//  Created by Stefan Popp on 08.07.15.
//  Copyright (c) 2015 SwiftBlog. All rights reserved.
//

import Cocoa

// Versatz den Mario ausserhalb des Bildschirms noch links und rechts laeuft
let kMarioOffscreenOffset: CGFloat = 128.0

// Subclass wenn mal etwas Fanciness dazu kommen soll =)
class MarioImageView: NSImageView {
    
}

class MarioWindowController {
    
    // Hauptfenster
    let marioWindow: MarioWindow!
    let marioContentView: NSView!
    var marioLayer: CALayer!
    
    // Marios Frame in dem wir zeichnen
    static let marioFrame = CGRect(
        x: 0.0,
        y: 0.0,
        width: 22.0,
        height: 22.0
    )
    
    // Erstellen des Image views und erzeugen von Layern zur animierung
    init(marioWindow: MarioWindow) {
        self.marioWindow = marioWindow
        marioContentView = marioWindow.contentView as! NSView
        marioContentView.layer = CALayer()
        marioContentView.wantsLayer = true
        marioContentView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawPolicy.Never
    }
    
    func start() {
        // Mario Image View hinzufuegen
        addMario()
        
        // Mario animation starten
        animateMario()
    }

    func animateMario() {
        // Target X Koordinate errechnen
        let targetX = self.marioContentView.frame.width + kMarioOffscreenOffset;
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in

        }

        /**
        *  Lauf Animation mit Sprites
        */
        // Keypath fuer den Austausch ist bei Image Views "contents"
        let spriteAnimation = CAKeyframeAnimation(keyPath: "contents")
        
        // Sprites als Einzelbilder
        spriteAnimation.values = [
            NSImage(named: "mario1")!,
            NSImage(named: "mario3")!,
        ]
        
        // 500ms fuer einen Durchlauf der Animation
        spriteAnimation.duration = 0.5
        
        // Diskreter Zeitverlauf, linear uberblendet die Bilder
        spriteAnimation.calculationMode = kCAAnimationDiscrete
        
        // Wir wiederholen die Animation bis zum Sant Nimmermehrstag
        // https://de.wikipedia.org/wiki/Sankt_Nimmerlein
        spriteAnimation.repeatCount = HUGE
        
        
        /**
        *  Mario auf der X Koordinate bewegen
        */
        let translateAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        let targetFrame = CGRectOffset(marioContentView.frame, targetX, 0);
        var sourcePoint = CGPoint(x: 0-kMarioOffscreenOffset, y: 0)
        translateAnimation.toValue = NSValue(point: targetFrame.origin)
        translateAnimation.fromValue = NSValue(point: sourcePoint)

        // To Value und From Value verdrehen gibt tollen
        translateAnimation.removedOnCompletion = false
        translateAnimation.fillMode = kCAFillModeForwards
        
        // 23 - https://de.wikipedia.org/wiki/Dreiundzwanzig
        translateAnimation.duration = 23.0
        translateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        translateAnimation.repeatCount = HUGE
        
        /**
        *  Animationen hinzufuegen
        */
        marioLayer.addAnimation(spriteAnimation, forKey: "marioWalk")
        marioLayer.addAnimation(translateAnimation, forKey: "marioTranslate")
        CATransaction.commit()
    }
    
    func addMario() {
        // Mario Frame
        let frame = self.dynamicType.marioFrame
        
        // Mario Bild Layer erzeugen
        marioLayer = CALayer()
        marioLayer.name = "mario1"
        marioLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: frame.height,
            height: frame.width
        )
        marioLayer.contents = NSImage(named: "mario1")
        marioContentView.layer?.addSublayer(marioLayer)
    }
    
    func didChangeScreenParameters() {
        marioLayer.removeAllAnimations()
        animateMario()
    }
}

