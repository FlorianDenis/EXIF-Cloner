//
//  FDMainViewController.h
//  EXIF Cloner
//
//  Created by Florian Denis on 8/10/13.
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
#import "FDStaticMapView.h"
#import "FDDropView.h"

@interface FDMainViewController : NSViewController <FDDropViewDelegate>
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *noImageView;
@property (assign) IBOutlet NSView *metadataView;

@property (assign) IBOutlet NSImageView *thumbnailView;
@property (assign) IBOutlet NSTextField *filenameLabel;
@property (assign) IBOutlet NSTextField *filesizeLabel;
@property (assign) IBOutlet NSTextField *info1Label;
@property (assign) IBOutlet NSTextField *info2Label;
@property (assign) IBOutlet NSTextField *info3Label;
@property (assign) IBOutlet FDStaticMapView *mapView;
@property (assign) IBOutlet FDDropView *dropView;

// Present open panel for source image
-(IBAction)presentOpenPanel:(id)sender;


// Reset the view to its default state
-(void)resetView;

@end
