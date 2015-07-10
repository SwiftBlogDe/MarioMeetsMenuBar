//
//  AppDelegate.swift
//  MarioMeetsStatusBar
//
//  Created by Stefan Popp on 08.07.15.
//  Copyright (c) 2015 SwiftBlog. All rights reserved.
//
/*
Todo:

Screen change
Screen resolution change
Animationsperformance optimieren

Nice to have:
Animation ein wenig verspielter machen
*/

import Cocoa

class MarioWindow: NSWindow {
    override func constrainFrameRect(frameRect: NSRect, toScreen screen: NSScreen?) -> NSRect {
        return frameRect
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: MarioWindow!
    var marioController: MarioWindowController!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Verhindere die Anzeige der Applikation im Dock
        NSApp.setActivationPolicy(NSApplicationActivationPolicy.Accessory)
        
        // Erstelle das Anwendungsfenster und zeige es an
        createApplicationWindow()

        // Mario controller erstellen und loslaufen lasse
        addMarioController()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func addMarioController() {
        // Erstelle Mario und lass ihn laufen
        marioController = MarioWindowController(marioWindow: window)
        marioController.start()
    }
    
    func createApplicationWindow() {
        // Erstelle Mario Fenster und platziere es ueber alle anderen Fenster
        window = MarioWindow(
            contentRect: windowContentRect(), // Fensterposition
            styleMask: NSBorderlessWindowMask, // Keine Titlebar und Rand
            backing: NSBackingStoreType.Buffered,
            defer: true
        )
        window.hasShadow = false
        window.level = Int(CGWindowLevelForKey(Int32(kCGMainMenuWindowLevelKey)))
        window.opaque = false
        window.backgroundColor = NSColor(
            calibratedHue: 0,
            saturation: 1.0,
            brightness: 0,
            alpha: 0.0
        )
        
        // Jegliche Maus-Events unterdruecken
        window.ignoresMouseEvents = true
        
        // Applikationsfenster nach vorne holen, dabei den Fokus anderer 
        // Applikationen unangetastet lassen
        window.orderFrontRegardless()
        
        // Erstellen eines Platzhalter Views und Zuweisung an das Window
        let contentView = NSView(frame: window.frame)
        window.contentView = contentView
    }
    
    func windowContentRect() -> CGRect {
        // Aufloesung abfragen
        let screenFrame = NSScreen.mainScreen()!.frame
        
        // Marios Dimensionen ermitteln
        let marioFrame = MarioWindowController.marioFrame
        
        // Bereich zum zeichnen festlegen
        let contentRect = CGRect(
            x: 0,
            y: screenFrame.height-marioFrame.height,
            width: screenFrame.size.width,
            height: marioFrame.height
        )
        return contentRect
    }
    
    func applicationDidChangeScreenParameters(notification: NSNotification) {
        // Auf Display Veraenderungen reagieren
        
        // Fenster neu positionieren
        window.setFrame(windowContentRect(), display: true)
        println(window.contentView)
        
        // Marios animationen neu berechnen
        marioController.didChangeScreenParameters()
    }
}

