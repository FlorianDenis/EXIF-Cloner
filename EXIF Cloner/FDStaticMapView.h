//
//  FDStaticMapView.h
//  EXIF Cloner
//
//  Created by Florian Denis on 8/11/13.
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

/**
 *	A simple NSView that leverages the google static map API
 */
@interface FDStaticMapView : NSView

/**
 *	Center the static map to a specific location
 *
 *	@param	location	A CGPoint with latitude and longitude of the new center of the map
 *	@param	animated	A BOOL indicating whether or not a fade in/out should occur
 */
-(void)setMapViewCenter:(CGPoint)location animated:(BOOL)animated;


/**
 *	Used to hide the current map
 *
 *	@param	animated	a flag determining whether or not the transition should be animated 
 */
-(void)hideMap:(BOOL)animated;


@end
