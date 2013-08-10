//
//  FDMetadataContainer.h
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

#import <Foundation/Foundation.h>
#import "FDDataBit.h"

/**
 *	FDMetadataContainer is a container class encapsulating the fonctionnalities of exiv2
 */
@interface FDMetadataContainer : NSObject


/**
 *	Getting a metadata container for a picture
 *
 *	@param	path	A string representing the path to an existing file of the supported file type
 *
 *	@return	An autoreleased FDMetadataContainer instance representing the metadata contained in the file, or nil if an error occured
 */
+(FDMetadataContainer*)metadataForImageAtPath:(NSString*)path;


/**
 *	Export metadata to a file
 *
 *	@param	path	A string representing the path to an existing file of the supported file type
 *
 *	@return	YES if operation completed successuly, NO on error
 */
-(BOOL)saveMetadataToFileAtPath:(NSString*)path;


/**
 *	Get all the metadata keys
 *
 *	@return	An autoreleased NSArray of NSStrings containing all the metadata keys
 */
-(NSArray*)allKeys;


/**
 *	Get the value for a specific key
 *
 *	@param	key     a non-nil NSString representing the key
 *
 *	@return	An autoreleased FDDataBit containing the value for the requested key, or nil if no such values exists in the receiver
 */
-(FDDataBit*)valueForKey:(NSString*)key;
-(FDDataBit*)objectForKeyedSubscript:(NSString*)key;  // Subscripting version


/**
 *	Return a NSDictionnary representation of the receiver
 *
 *	@return	An autoreleased NSDictionary containing all keys and values in the receiver
 */
-(NSDictionary*)dictionary;

@end
