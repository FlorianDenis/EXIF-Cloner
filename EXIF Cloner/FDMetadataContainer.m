//
//  FDMetadataContainer.m
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

#import "FDMetadataContainer.h"

@interface FDMetadataContainer (){
    Exiv2::ExifData _exifData;
    Exiv2::IptcData _iptcData;
    Exiv2::XmpData _xmpData;
}
@end


@implementation FDMetadataContainer

#pragma mark - Getting metadata

+(FDMetadataContainer*)metadataForImageAtPath:(NSString*)path{
    
    FDMetadataContainer *container = nil;
    
    // Exceptions can be raised both by fileSystemRepresentation and Exiv2::ImageFactory::open
    // if the path or the file it points to are not valid
    @try {
        
        std::string file([path fileSystemRepresentation]);
        
        Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(file);
        image->readMetadata();
        
        container = [[[FDMetadataContainer alloc] init] autorelease];
        container->_exifData     = image->exifData();
        container->_iptcData     = image->iptcData();
        container->_xmpData      = image->xmpData();

    } @catch (...) {}
    
    return container;
}

#pragma mark - Saving metadata

-(BOOL)saveMetadataToFileAtPath:(NSString*)path{
    
    BOOL success = NO;
    
    // Exceptions can be raised both by fileSystemRepresentation and Exiv2::ImageFactory::open
    // if the path or the file it points to are not valid
    @try{
        
        std::string file([path fileSystemRepresentation]);
        
        Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(file);
        
        // Copy the current data
        Exiv2::ExifData newExifData = _exifData;
        Exiv2::IptcData newIptcData = _iptcData;
        Exiv2::XmpData newXmpData   = _xmpData;
        
        // Remove the thumbnail from the new Exif data, we probably don't want to copy that over!
        Exiv2::ExifThumb exifThumb(newExifData);
        exifThumb.erase();
        
        if (!newExifData.empty())  image->setExifData(newExifData);
        if (!newIptcData.empty())  image->setIptcData(newIptcData);
        if (!newXmpData.empty())   image->setXmpData(newXmpData);
        
        image->writeMetadata();
        
        success = YES;
        
    } @catch (...) {}
    
    return success;
}

#pragma mark - Getting values out

-(NSArray*)allKeys{
    
    NSMutableArray *allKeys = [NSMutableArray array];
    
    //TODO: Support for various encodings
    NSStringEncoding encoding = NSUTF8StringEncoding;
    
    {   // EXIF
        Exiv2::ExifData::const_iterator end = _exifData.end();
        for (Exiv2::ExifData::const_iterator i = _exifData.begin(); i != end; ++i)
            [allKeys addObject:[NSString stringWithCString:i->key().c_str() encoding:encoding]];
    }
    
    {   // IPTC
        Exiv2::IptcData::const_iterator end = _iptcData.end();
        for (Exiv2::IptcData::const_iterator i = _iptcData.begin(); i != end; ++i)
            [allKeys addObject:[NSString stringWithCString:i->key().c_str() encoding:encoding]];
    }
    
    {   // XMP
        Exiv2::XmpData::const_iterator end = _xmpData.end();
        for (Exiv2::XmpData::const_iterator i = _xmpData.begin(); i != end; ++i)
            [allKeys addObject:[NSString stringWithCString:i->key().c_str() encoding:encoding]];
    }

    return allKeys;
}


-(id)valueForKey:(NSString*)key{
    
    // Key must not be nil
    if (!key)
        @throw ([NSException exceptionWithName:NSInvalidArgumentException reason:@"nil key argument" userInfo:nil]);
    
    const std::string keyString([key cStringUsingEncoding:NSUTF8StringEncoding]);

    // Find the correct bit of data
    const Exiv2::Metadatum *metadatum = NULL;
    
    // Exiv2 raises an exception if key is not a valid tag name
    @try {
        if ([key rangeOfString:@"Exif" options:NSAnchoredSearch].location != NSNotFound)
            metadatum = &_exifData[keyString];
        else if ([key rangeOfString:@"Iptc" options:NSAnchoredSearch].location != NSNotFound)
            metadatum = &_iptcData[keyString];
        else if ([key rangeOfString:@"Xmp" options:NSAnchoredSearch].location != NSNotFound)
            metadatum = &_xmpData[keyString];
    } @catch (...) {}
    
    // Is this thing present and valid ?
    if (!metadatum || metadatum->typeId()==Exiv2::invalidTypeId) return nil;
    
    return [FDDataBit dataBitWithDatum:metadatum];
    
}

-(id)objectForKeyedSubscript:(NSString*)key{
    return [self valueForKey:key];
}

-(NSDictionary*)dictionary{

    NSArray *keys = [self allKeys];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:keys.count];
    for (NSString *key in keys)
        dictionary[key] = self[key];
    
    return dictionary;
    
}


@end
