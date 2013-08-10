//
//  FDDropView.m
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

#import "FDDropView.h"

@implementation FDDropView

#pragma mark - Basic class implementation

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {

        [self registerForDraggedTypes:[NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
        _enabled = YES;
        _multipleFilesAllowed = YES;
                
    }
    
    return self;
}

#pragma mark - Drag implementaiton

/**
 *	Determine if the drag is allowed given our preferences and the allowed file types
 */
- (BOOL)_isDragAllowed:(NSArray*)files {
	
    // Are we enabled
    if (!_enabled) return NO;
    
    // Multiple file at once preference
    if (files.count > 1 && !_multipleFilesAllowed) return NO;
    
    // Prefered file types not specified ?
    if (!_allowedFileTypes) return YES;

    // Check those file types for each file
    for (NSString *file in files){
        
        CFStringRef fileExtension = (CFStringRef)[file pathExtension];
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        BOOL fileConforms = NO;
        
        for (NSString *fileType in _allowedFileTypes){
            fileConforms = fileConforms || UTTypeConformsTo(fileUTI, (CFStringRef)fileType);
        }
        
        CFRelease(fileUTI);
        
        if (!fileConforms) return NO;
    }
    
    return YES;
}

// Entering drag operation
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    
    NSArray *files = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    
    // Can we go on given our preferences ?
    if (![self _isDragAllowed:files])
        return NSDragOperationNone;
    
    // Notify delegate if needs be
    if ([_delegate respondsToSelector:@selector(dropView:dragDidEnter:)])
        [_delegate dropView:self dragDidEnter:files];
    
    return NSDragOperationCopy;
}

// Updating
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    return [self _isDragAllowed:[pboard propertyListForType:NSFilenamesPboardType]] ? NSDragOperationCopy : NSDragOperationNone;
}

// Canceling
-(void)draggingExited:(id<NSDraggingInfo>)sender{
    
    NSArray *files = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    
    if ([_delegate respondsToSelector:@selector(dropView:dragDidCancel:)])
        [_delegate dropView:self dragDidCancel:files];
}

// PErforming
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        
        if ([_delegate respondsToSelector:@selector(dropView:dropPerformed:)])
            [_delegate dropView:self dropPerformed:files];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect{
    
    //// Color Declarations
    NSColor* strokeColor = [NSColor colorWithCalibratedRed: 0.806 green: 0.806 blue: 0.806 alpha: 1];
    NSColor* insetColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.625];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: insetColor];
    [shadow setShadowOffset: NSMakeSize(0, 1)];
    [shadow setShadowBlurRadius: 0];
    
    //// Abstracted Attributes
    CGFloat size = 150;
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    NSRect roundedRectangleRect =  CGRectMake(center.x-size/2, center.y-size/2, size, size);
    CGFloat roundedRectangleStrokeWidth = 7;
    
    CGFloat scale = .7;
    
    NSRect textRect = CGRectMake(center.x-100, center.y-size/2-50, 200, 40);;
    NSString* textContent = @"Drop some images to clone metadata";
    
    //// Rounded Rectangle Drawing
    NSBezierPath* roundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect: roundedRectangleRect xRadius: 20 yRadius: 20];
    [NSGraphicsContext saveGraphicsState];
    [shadow set];
    [strokeColor setStroke];
    [roundedRectanglePath setLineWidth: roundedRectangleStrokeWidth];
    CGFloat roundedRectanglePattern[] = {15, 15, 15, 15};
    [roundedRectanglePath setLineDash: roundedRectanglePattern count: 4 phase: 0.5];
    [roundedRectanglePath stroke];
    [NSGraphicsContext restoreGraphicsState];
    
    
    //// Arrow Drawing
    NSBezierPath* arrowPath = [NSBezierPath bezierPath];
    [arrowPath moveToPoint: NSMakePoint(center.x+13*scale,       center.y-3*scale)];
    [arrowPath lineToPoint: NSMakePoint(center.x+41*scale,       center.y-3*scale)];
    [arrowPath lineToPoint: NSMakePoint(center.x+00*scale,       center.y-56*scale)];
    [arrowPath lineToPoint: NSMakePoint(center.x-41*scale,       center.y-3*scale)];
    [arrowPath lineToPoint: NSMakePoint(center.x-13*scale,       center.y-3*scale)];
    [arrowPath lineToPoint: NSMakePoint(center.x-13*scale,       center.y+56*scale)];
    [arrowPath lineToPoint: NSMakePoint(center.x+13*scale,       center.y+56*scale)];
    [arrowPath lineToPoint: NSMakePoint(center.x+13*scale,       center.y-3*scale)];
    [arrowPath closePath];
    [NSGraphicsContext saveGraphicsState];
    [shadow set];
    [strokeColor setFill];
    [arrowPath fill];
    [NSGraphicsContext restoreGraphicsState];
    
    
    
    //// Text Drawing
    
    [NSGraphicsContext saveGraphicsState];
    [shadow set];
    NSMutableParagraphStyle* textStyle = [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [textStyle setAlignment: NSCenterTextAlignment];
    
    NSDictionary* textFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSFont fontWithName: @"Helvetica-Bold" size: 12], NSFontAttributeName,
                                        strokeColor, NSForegroundColorAttributeName,
                                        textStyle, NSParagraphStyleAttributeName, nil];
    
    [textContent drawInRect: textRect withAttributes: textFontAttributes];
    [NSGraphicsContext restoreGraphicsState];
    
    

    //// Cleanup
    [shadow release];
    
    
    [super drawRect:dirtyRect];
    

}

@end
