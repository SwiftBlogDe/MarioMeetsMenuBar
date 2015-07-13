//
//  MenuBarPrefController.m
//  MarioMeetsMenuBar
//
//  Created by Stefan Popp on 13.07.15.
//  Copyright (c) 2015 SwiftBlog. All rights reserved.
//

#import "MarioPrefController.h"
#import <AppKit/AppKit.h>

@interface MarioPrefController ()

@property NSUserDefaults *defaults;
@property (weak) IBOutlet NSButton *launchSwitch;

@end

@implementation MarioPrefController

#pragma mark - Settings and view configuration
- (void)configurePreview {
    [self readSettings];
    [_launchSwitch setState:[_defaults boolForKey:@"launchOnStart"]];
}

- (void)readSettings {
    _defaults = [[NSUserDefaults alloc] initWithSuiteName:@"de.swift-blog.mariomeetsmenubar"];
    [_defaults synchronize];
}

#pragma mark - Application helper

- (BOOL)appIsRunning {
    NSArray *apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"de.SwiftBlog.MarioMeetsMenuBar"];
    return (apps.count > 0);
}


- (void)terminateMarioMenuApp {
    
    if (! [self appIsRunning]) {
        return;
    }
    
    NSArray *apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"de.SwiftBlog.MarioMeetsMenuBar"];
    NSRunningApplication *app = apps[0];
    [app forceTerminate];
}

#pragma mark - Login launch helper

- (void)setLaunchOnLogin:(BOOL)launchOnLogin
{
    NSURL *bundleURL = [NSURL fileURLWithPath:@"/Applications/MarioMeetsMenuBar.app"];
    LSSharedFileListRef loginItemsListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (launchOnLogin) {
        NSDictionary *properties;
        properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"com.apple.loginitem.HideOnLaunch"];
        LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsListRef, kLSSharedFileListItemLast, NULL, NULL, (__bridge CFURLRef)bundleURL, (__bridge CFDictionaryRef)properties,NULL);
        if (itemRef) {
            CFRelease(itemRef);
        }
    } else {
        LSSharedFileListRef loginItemsListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        CFArrayRef snapshotRef = LSSharedFileListCopySnapshot(loginItemsListRef, NULL);
        NSArray* loginItems = (__bridge_transfer id)(snapshotRef);
        
        for (id item in loginItems) {
            LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
            CFURLRef itemURLRef;
            if (LSSharedFileListItemResolve(itemRef, 0, &itemURLRef, NULL) == noErr) {
                NSURL *itemURL = (__bridge_transfer id)(itemURLRef);
                if ([itemURL isEqual:bundleURL]) {
                    LSSharedFileListItemRemove(loginItemsListRef, itemRef);
                }
            }
        }
    }
}

#pragma mark - Actions

- (IBAction)uninstallApplicationClicked:(NSButton *)sender {
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"Uninstall"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Are you sure to uninstall the Mario menu bar?"];
    [alert setInformativeText:@"Uninstall MarioMeetsMenuBar"];
    [alert setAlertStyle:NSCriticalAlertStyle];
    
    NSWindow *window = [NSApplication sharedApplication].keyWindow;
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        
    }];
    return;
}

- (IBAction)quitApplicationClicked:(NSButton *)sender {
    if (! [self appIsRunning]) {
        NSAlert *alert = [NSAlert new];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"MarioMeetsMenuBar is not running"];
        [alert setInformativeText:@"MarioMeetsMenuBar"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert runModal];
        return;
    }
    
    [self terminateMarioMenuApp];
}

- (IBAction)openSwiftBlogClicked:(NSButton *)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.swift-blog.de/"]];
}

- (IBAction)launchOnStartClicked:(NSButton *)sender {
    [_defaults setBool:sender.state forKey:@"launchOnStart"];
    [self setLaunchOnLogin:sender.state];
}

@end
