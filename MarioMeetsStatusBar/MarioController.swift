//
//  MarioController.swift
//  MarioMeetsStatusBar
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
    
    // Marios Frame in dem wir zeichnen
    static let marioFrame = CGRect(
        x: -kMarioOffscreenOffset,
        y: 0.0,
        width: 22.0,
        height: 22.0
    )
    
    // Marios Image View
    let marioImageView: MarioImageView!
    
    // Erstellen des Image views und erzeugen von Layern zur animierung
    init(marioWindow: MarioWindow) {
        self.marioWindow = marioWindow
        marioImageView = MarioImageView(frame: MarioWindowController.marioFrame)
        marioImageView.layer = CALayer()
        marioImageView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawPolicy.OnSetNeedsDisplay;
        marioImageView.wantsLayer = true
    }
    
    func start() {
        // Mario Image View hinzufuegen
        addMario()
        
        // Mario animation starten
        animateMario()
    }

    func animateMario() {
        // Target X Koordinate errechnen
        let targetX = self.marioImageView.superview!.frame.width + kMarioOffscreenOffset;
        
        // Laufanimation hinzufuegen (Sprites)
        marioImageView.layer?.addAnimation(marioWalkSpriteAnimation(), forKey: "marioWalk")
        
        // Animation fuer die Verschiebung des Frames hinzufuegen
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
            
            // 23 - https://de.wikipedia.org/wiki/Dreiundzwanzig
            context.duration = 23.0;
            
            // Linearer Zeitverlauf fuer die Animation
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            
            // Zielkoordinate festlegen
            self.marioImageView.animator().frame = CGRectOffset(self.marioImageView.frame, targetX, 0);
            }, completionHandler: { // Aufruf nach Beendigung der Animation
                // Original Frame wiederherstellen
                self.marioImageView.frame = MarioWindowController.marioFrame
                
                // Animation nach 4 Sekunden erneut starten
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(4 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.animateMario()
                }
        })
    }
    
    func marioWalkSpriteAnimation() -> CAKeyframeAnimation {

        // Keypath fuer den Austausch ist bei Image Views "contents"
        let animation = CAKeyframeAnimation(keyPath: "contents")
        
        // Sprites als Einzelbilder
        animation.values = [
            NSImage(named: "mario1")!,
            NSImage(named: "mario3")!,
        ]
        
        // 500ms fuer einen Durchlauf der Animation
        animation.duration = 0.5
        
        // Diskreter Zeitverlauf, linear uberblendet die Bilder
        animation.calculationMode = kCAAnimationDiscrete
        
        // Wir wiederholen die Animation bis zum Sant Nimmermehrstag
        // https://de.wikipedia.org/wiki/Sankt_Nimmerlein
        animation.repeatCount = HUGE
        
        // Rueckgabe der erzeugten Animation
        return animation
    }
    
    func addMario() {
        // Add mario image view to the main window
        marioWindow.contentView.addSubview(marioImageView)
    }
}

