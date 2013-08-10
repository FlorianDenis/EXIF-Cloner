//
//  FDMainViewController.m
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

#import "FDMainViewController.h"
#import "FDMetadataContainer.h"
#import "NSString+Utilities.h"

static NSArray *metadataDisplayPriority = @[
    @"Exif.Image.Model",
    @"Exif.Image.DateTime",
    @"Exif.Photo.LensModel",
    @"Exif.Image.Artist",
];

@interface FDMainViewController ()
@property (nonatomic,retain) NSURL *fileURL;
@property (nonatomic,retain) FDMetadataContainer *metadata;
@end

@implementation FDMainViewController

-(void)awakeFromNib{
    [super awakeFromNib];
    [self resetView];
    
    _dropView.allowedFileTypes = @[(NSString*)kUTTypeImage];
}

- (void)dealloc{
    self.fileURL = nil;
    self.metadata = nil;
    [super dealloc];
}

#pragma mark - Change interface state

-(void)resetView{
    [self _setImageSelected:NO animated:NO];
    
    _thumbnailView.image = nil;
    
    _filenameLabel.stringValue =  @"";
    _filesizeLabel.stringValue = @"";
    _info1Label.stringValue = @"";
    _info2Label.stringValue = @"";
    _info3Label.stringValue = @"";

    
    [_mapView hideMap:NO];

}

-(void)_setImageSelected:(BOOL)selected animated:(BOOL)animated{
    
    if (animated){
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:.3f];
        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        if (selected){
            [_noImageView.animator setAlphaValue:0];
            [_metadataView.animator setAlphaValue:1];
        } else {
            [_noImageView.animator setAlphaValue:1];
            [_metadataView.animator setAlphaValue:0];
        }
        
        [NSAnimationContext endGrouping];

    } else {
        if (selected){
            [_noImageView setAlphaValue:0];
            [_metadataView setAlphaValue:1];
        } else {
            [_noImageView setAlphaValue:1];
            [_metadataView setAlphaValue:0];
        }
    }
    
}

#pragma mark - Getting and presenting metadata

// Returns YES if success, NO on error
-(BOOL)_openMetadataForFile:(NSURL*)fileUrl{
    
    self.metadata = [FDMetadataContainer metadataForImageAtPath:fileUrl.path];
    if (!_metadata) return NO;
    
    self.fileURL = fileUrl;
    
    [self _presentThumbnail];
    [self _presentFileInfo];
    [self _presentCurrentMetadata];
    [self _presentGPSInfo];
    return YES;
}

-(void)_presentThumbnail{
    
    // Present the file icon for now
    NSImage *thumb = [[NSWorkspace sharedWorkspace] iconForFile:_fileURL.path];
    thumb.size = NSMakeSize(128, 128);
    _thumbnailView.image = thumb;
    
}

// Fill in the name and size labels
-(void)_presentFileInfo{
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_fileURL.path error:nil];
    NSUInteger size = [[attributes objectForKey:NSFileSize] unsignedIntegerValue];

    _filenameLabel.stringValue =  [_fileURL.path lastPathComponent];
    _filesizeLabel.stringValue = [NSString sizeStringWithBytes:size];

    
}

// Fill in the 3 info label: ideally, camera model, time of shooting and shot information
// An ordered list of tag name defines the priority in case some of the data is not avalaible
-(void)_presentCurrentMetadata{
    
    _info1Label.stringValue = @"";
    _info2Label.stringValue = @"";
    _info3Label.stringValue = @"";
    
    NSUInteger i = 1;
    
    for (NSString *exifTag in metadataDisplayPriority){
        if (_metadata[exifTag]){
            // _metadata[exifTag] is some subclass of FDDataBit, calling description will pretty-print the values
            NSTextField *label = nil;
            if (i==1) label = _info1Label; else
            if (i==2) label = _info2Label; 
            
            label.stringValue = [NSString stringWithFormat:@"%@",_metadata[exifTag]];

            if (++i>2) break;
            
        }
    }
    
    // If we don't have the first complete 2 information, just bail out
    if (i<=2) return;
    
    // We have filled the first 2 strings
    // I'm sure we can find enough information for the rest
    
    NSString *compositeString = @"";
    
    if (_metadata[@"Exif.Photo.FNumber"])
        compositeString = [compositeString stringByAppendingFormat:@"f/%@",_metadata[@"Exif.Photo.FNumber"]];
    if (_metadata[@"Exif.Photo.FocalLength"])
        compositeString = [compositeString stringByAppendingFormat:@", %@mm",_metadata[@"Exif.Photo.FocalLength"]];
    if (_metadata[@"Exif.Photo.ISOSpeedRatings"])
        compositeString = [compositeString stringByAppendingFormat:@", ISO%@",_metadata[@"Exif.Photo.ISOSpeedRatings"]];
    
    if (compositeString.length==0) return;
    
    _info3Label.stringValue = compositeString;

    
}

-(void)_presentGPSInfo{
    
    FDNumberDataBit *lat = (FDNumberDataBit*)_metadata[@"Exif.GPSInfo.GPSLatitude"];
    FDNumberDataBit *lon = (FDNumberDataBit*)_metadata[@"Exif.GPSInfo.GPSLongitude"];
    
    FDStringDataBit *latRef = (FDStringDataBit*)_metadata[@"Exif.GPSInfo.GPSLatitudeRef"];
    FDStringDataBit *lonRef = (FDStringDataBit*)_metadata[@"Exif.GPSInfo.GPSLongitudeRef"];

    if (!lat || !lon || !latRef || !lonRef || lat.values.count != 3 || lon.values.count != 3){
        
        [_mapView setHidden:YES];
        return;
    }
    
    [_mapView setHidden:NO];

    
    CGFloat latitude = [lat.values[0] floatValue]+[lat.values[1] floatValue]/60+[lat.values[2] floatValue]/3600;
    CGFloat longitude = [lon.values[0] floatValue]+[lon.values[1] floatValue]/60+[lon.values[2] floatValue]/3600;
    
    if ([latRef.string isEqualToString:@"S"]) latitude = -latitude;
    if ([lonRef.string isEqualToString:@"W"]) longitude = -longitude;
    
    CGPoint center = CGPointMake(latitude, longitude);
    
    [_mapView setMapViewCenter:center animated:YES];
    
}

#pragma mark - Selecting files

// Present open panel for source image
-(IBAction)presentOpenPanel:(id)sender{
 
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    // Allow selection into iPhoto/Aperture libraries
    [panel setTreatsFilePackagesAsDirectories:YES];
    
    // Only one photo at a time for now
    [panel setAllowsMultipleSelection:NO];
    
    // Present panel to user
    NSInteger result = [panel runModal];
        
    if (result == NSFileHandlingPanelCancelButton) return;
    
    // Get the chosen file metadata, hide choosing view on success
    if ([self _openMetadataForFile:panel.URL]){
        [self _setImageSelected:YES animated:YES];
    } else {
        // Reading metadata failed, present the user with an alert
        NSAlert *alert = [NSAlert alertWithMessageText:@"Could not read metadata"
                                         defaultButton:@"Dismiss"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"Either the file is corrupted or does not contain any supported metadata format."];
        [alert beginSheetModalForWindow:_window
                          modalDelegate:nil
                         didEndSelector:nil
                            contextInfo:NULL];
    }
    
}

#pragma mark - FDDropViewDelegate implementation

-(void)dropView:(FDDropView *)view dropPerformed:(NSArray *)files{
    
    BOOL errors = NO;
    
    // Files were just dropped, we need to copy metadata to them
    for (NSString *file in files){
        
        // First off, make sure we are not copying to ourself
        if ([[NSFileManager defaultManager] contentsEqualAtPath:file andPath:_fileURL.path])
            continue;
        
        // Then copy from source to destination
        if (![_metadata saveMetadataToFileAtPath:file]) errors = YES;
        
    }
    
    // Create a notificatio to display to the user
    NSUserNotification *notification = [[[NSUserNotification alloc] init] autorelease];
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    // Check if everything went fine:
    if (errors){
        notification.title = @"Errors";
        notification.informativeText = @"Some error occured when attempting to clone metadata";
    } else {
        notification.title = @"Metadata cloned";
        notification.informativeText = [NSString stringWithFormat:@"The metadata was succesuflly cloned to %ld file%@",(unsigned long)files.count,(files.count>1?@"s":@"")];
        
    }
    
    // Display it
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end
