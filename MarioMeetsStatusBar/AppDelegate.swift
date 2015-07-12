//
//  AppDelegate.swift
//  MarioMeetsStatusBar
//
//  Created by Stefan Popp on 08.07.15.
//  Copyright (c) 2015 SwiftBlog. All rights reserved.
//
/*
Todo:

Multi Monitor Mario?

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
        
        // Notifications ueber Desktop wechsel erhalten
        let workspaceNC = NSWorkspace.sharedWorkspace().notificationCenter
        workspaceNC.addObserver(
            self,
            selector: "didChangeWorkspace",
            name:NSWorkspaceActiveSpaceDidChangeNotification,
            object: NSWorkspace.sharedWorkspace()
        )
        
        // Erstelle das Anwendungsfenster und zeige es an
        createApplicationWindow()

        // Mario controller erstellen und loslaufen lasse
        addMarioController()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func addMarioController() {
        window.level = Int(CGWindowLevelForKey(Int32(kCGMainMenuWindowLevelKey)))
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
        window.level = Int(CGWindowLevelForKey(Int32(kCGMainMenuWindowLevelKey)))
        window.hasShadow = false
        window.opaque = false
        window.backgroundColor = NSColor(
            calibratedHue: 0,
            saturation: 1.0,
            brightness: 0,
            alpha: 0.0
        )
        
        // App kann auf allen Spaces gelaunched und angezeigt werden
        window.collectionBehavior = NSWindowCollectionBehavior.MoveToActiveSpace
        
        // Jegliche Maus-Events unterdruecken
        window.ignoresMouseEvents = true
        
        // Applikationsfenster nach vorne holen
        window.makeKeyAndOrderFront(nil)
        
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
        updateWindowFrame()
    }
    
    func updateWindowFrame() {
        window.level = Int(CGWindowLevelForKey(Int32(kCGMainMenuWindowLevelKey)+1))
        
        // Fenster neu positionieren
        window.setFrame(windowContentRect(), display: true)
        
        // Marios animationen neu berechnen
        marioController.didChangeScreenParameters()
    }

    func didChangeWorkspace() {
        self.updateWindowFrame()
        window.orderFrontRegardless()
    }
}

