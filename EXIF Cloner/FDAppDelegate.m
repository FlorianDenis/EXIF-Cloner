//
//  FDAppDelegate.m
//  EXIF Cloner
//
//  Created by Florian Denis on 8/9/13.
//  Copyright (c) 2013 Florian Denis. All rights reserved.
//
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

#import "FDAppDelegate.h"

@implementation FDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    [_mainViewController presentOpenPanel:self];
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)hasVisibleWindows{
    if (!hasVisibleWindows) [_mainViewController resetView];
    [_window makeKeyAndOrderFront:self];
    return YES;
}

-(BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

@end
