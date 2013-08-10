//
//  FDDataBit.h
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

#import <Foundation/Foundation.h>
#import <exiv2/exiv2.hpp>

/**
 *	A general subclass for an EXIF,IPTC or XMP value
 */
@interface FDDataBit : NSObject

/**
 *	Get an FDDataBit. This method should not be called by the consumers of the API.
 *
 *  @param  datum   A const pointer to a valid Exiv2::Metadatum
 *
 *	@return An autoreleased FDDataBit of the right subclass containing the data stored into datum.
 */
+(FDDataBit*)dataBitWithDatum:(const Exiv2::Metadatum*)datum;

@end

/**
 *	Subclass that holds string values
 */
@interface FDStringDataBit : FDDataBit
@property (nonatomic, readonly) NSString *string;
@end

/**
 *	Subclass that holds rationnal values
 */
@interface FDRationalDataBit : FDDataBit
@property (nonatomic, readonly) NSNumber *num;
@property (nonatomic, readonly) NSNumber *denum;
@end


/**
 *	Subclass that holds data comprised of an arbitrary number of scalar values (NSNumber)
 */
@interface FDNumberDataBit : FDDataBit
@property (nonatomic, readonly) NSArray *values;
@end
