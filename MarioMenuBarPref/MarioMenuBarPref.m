//
//  MarioMenuBarPref.m
//  MarioMenuBarPref
//
//  Created by Stefan Popp on 13.07.15.
//  Copyright (c) 2015 SwiftBlog. All rights reserved.
//

#import "MarioMenuBarPref.h"

#import "MarioPrefController.h"

@interface MarioMenuBarPref ()
@property (strong) IBOutlet MarioPrefController *marioPrefController;
@end

@implementation MarioMenuBarPref

- (void)mainViewDidLoad
{
    [_marioPrefController configurePreview];
}

@end
