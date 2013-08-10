//
//  FDDropView.h
//  EXIF Cloner
//
//  Created by Florian Denis on 8/13/13.
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

@class FDDropView;

/**
 *	FDDropViewDelegate protocol for interacting with FDDropView
 */
@protocol FDDropViewDelegate <NSObject>

@optional

-(void)dropView:(FDDropView*)view dragDidEnter:(NSArray*)files;
-(void)dropView:(FDDropView*)view dragDidCancel:(NSArray*)files;
-(void)dropView:(FDDropView*)view dropPerformed:(NSArray*)files;

@end


@interface FDDropView : NSView
@property (nonatomic, retain) NSArray* allowedFileTypes;
@property (nonatomic, assign) IBOutlet id<FDDropViewDelegate> delegate;
@property (nonatomic, assign) BOOL multipleFilesAllowed;
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
@end
