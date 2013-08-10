//
//  FDStaticMapView.m
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

#import "FDStaticMapView.h"

@interface FDStaticMapView (){
    NSImageView *_imageView;
}

@end

@implementation FDStaticMapView

-(void)awakeFromNib{
    
    // Setting the image view with rounded rect
    _imageView = [[NSImageView alloc] initWithFrame:self.bounds];
    _imageView.autoresizingMask = NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin;
    _imageView.wantsLayer = YES;
    _imageView.layer.cornerRadius = 5;
    _imageView.layer.masksToBounds = YES;
    [self addSubview:_imageView];
}

- (void)dealloc{
    [_imageView release];
    [super dealloc];
}

-(void)setMapViewCenter:(CGPoint)location animated:(BOOL)animated{
    
    if (animated){
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:.2f];
        [_imageView.animator setAlphaValue:0];
        [NSAnimationContext endGrouping];
    }

    
    // Do that on background thread because of loading 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        // Get point location
        float lat = location.x;
        float lon = location.y;
        
        // Are we a retina mac ?
        int scale = (int)round([[NSScreen mainScreen] backingScaleFactor]);
        
        // What is the size of the picture we wanna get ?
        int h = self.frame.size.height;
        int w = self.frame.size.width;
        
        // Formulate the URL
        NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=10&size=%dx%D&scale=%d&sensor=false&visual_refresh=true&markers=%f,%f",lat,lon,w,h,scale,lat,lon];
        
        
        NSImage *image = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:url]] autorelease];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            _imageView.image = image;
            if (animated){
                [NSAnimationContext beginGrouping];
                [[NSAnimationContext currentContext] setDuration:.4f];
                [_imageView.animator setAlphaValue:1];
                [NSAnimationContext endGrouping];
            }
            
        });
        
    });
    
    
}

-(void)hideMap:(BOOL)animated{
    if (animated){
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            _imageView.alphaValue = 0;
        } completionHandler:^{
            _imageView.image = nil;
            _imageView.alphaValue = 1;
        }];
    } else {
        _imageView.image = nil;
    }
}

-(void)drawRect:(NSRect)dirtyRect{

    /**
     *	Drawing the map silhouette
     */
    
    // Color Declarations
    NSColor* insetColor     = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.727];
    NSColor* strokeColor    = [NSColor colorWithCalibratedRed: 0.806 green: 0.806 blue: 0.806 alpha: 1];
    NSColor* fillColor      = [NSColor colorWithCalibratedRed: 0.931 green: 0.931 blue: 0.931 alpha: 1];
    
    // Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: insetColor];
    [shadow setShadowOffset: NSMakeSize(0, 1)];
    [shadow setShadowBlurRadius: 0];
    
    // Map Silhouette Drawing
    NSBezierPath* mapSilhouettePath = [NSBezierPath bezierPath];
    [mapSilhouettePath moveToPoint: NSMakePoint(143.5, 128.5)];
    [mapSilhouettePath lineToPoint: NSMakePoint(143.5, 41.5)];
    [mapSilhouettePath lineToPoint: NSMakePoint(179.5, 58.5)];
    [mapSilhouettePath lineToPoint: NSMakePoint(179.5, 144.5)];
    [mapSilhouettePath lineToPoint: NSMakePoint(143.5, 128.5)];
    [mapSilhouettePath closePath];
    [mapSilhouettePath moveToPoint: NSMakePoint(74.5, 135.5)];
    [mapSilhouettePath lineToPoint: NSMakePoint(75.5, 48.5)];
    [mapSilhouettePath lineToPoint: NSMakePoint(111.5, 65.5)];
    [mapSilhouettePath lineToPoint: NSMakePoint(111.5, 155.5)];
    [mapSilhouettePath lineToPoint: NSMakePoint(74.5, 135.5)];
    [mapSilhouettePath closePath];
    [mapSilhouettePath moveToPoint: NSMakePoint(111.5, 155.5)];
    [mapSilhouettePath lineToPoint: NSMakePoint(111.5, 65.5)];
    [mapSilhouettePath lineToPoint: NSMakePoint(143.5, 41.5)];
    [mapSilhouettePath lineToPoint: NSMakePoint(143.5, 128.5)];
    [mapSilhouettePath lineToPoint: NSMakePoint(111.5, 155.5)];
    [mapSilhouettePath closePath];
    [mapSilhouettePath setLineJoinStyle: NSRoundLineJoinStyle];
    [fillColor setFill];
    [mapSilhouettePath fill];
    [NSGraphicsContext saveGraphicsState];
    
    [shadow set];
    [strokeColor setStroke];
    [mapSilhouettePath setLineWidth: 5];
    [mapSilhouettePath stroke];
    [NSGraphicsContext restoreGraphicsState];
    
    
    //// Cleanup
    [shadow release];

    /**
     *	Calling super
     */
    
    [super drawRect:dirtyRect];
}


@end
