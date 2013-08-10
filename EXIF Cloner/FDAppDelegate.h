//
//  FDAppDelegate.h
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

#import <Cocoa/Cocoa.h>
#import "FDMainViewController.h"

@interface FDAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet FDMainViewController *mainViewController;

@end
