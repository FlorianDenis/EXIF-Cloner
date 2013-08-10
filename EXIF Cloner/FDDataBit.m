//
//  FDDataBit.m
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

#import "FDDataBit.h"

#pragma mark - General data bits
@implementation FDDataBit

+(FDDataBit*)dataBitWithDatum:(const Exiv2::Metadatum*)datum{
    
    // This value should already be filtered out
    assert(datum->typeId()!=Exiv2::invalidTypeId);
    
    // What we return depends on what type this is
    switch (datum->typeId()) {
        case Exiv2::asciiString:
        case Exiv2::string:
        case Exiv2::comment:
        case Exiv2::directory:
        case Exiv2::langAlt:
        case Exiv2::xmpText:
        case Exiv2::xmpAlt:
        case Exiv2::xmpBag:
        case Exiv2::date:   // TODO: Create a specific FDDateDataBit
            return [FDStringDataBit dataBitWithDatum:datum];
        case Exiv2::signedRational:
        case Exiv2::unsignedRational:
            return [FDRationalDataBit dataBitWithDatum:datum];
        default:
            return [FDNumberDataBit dataBitWithDatum:datum];
    }

}

@end

#pragma mark - Strings
@implementation FDStringDataBit

#pragma mark - Alloc/dealloc

+(FDDataBit*)dataBitWithDatum:(const Exiv2::Metadatum*)datum{
    
    // TODO: Support encoding
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString *string = [NSString stringWithCString:(datum->toString()).c_str() encoding:encoding];
    
    return [[[FDStringDataBit alloc] initWithString:string] autorelease];
    
}

-(id)initWithString:(NSString*)string{
    if ((self = [super init])){
        _string = [string retain];
    }
    return self;
}

- (void)dealloc{
    [_string release];
    [super dealloc];
}

-(BOOL)isEqual:(id)object{
    
    if (![object isKindOfClass:[FDStringDataBit class]]) return NO;
    
    FDStringDataBit *other = (FDStringDataBit*)object;
    
    return [other.string isEqualToString:_string];
    
}

-(NSString*)description{
    return _string;
}

@end


#pragma mark - Rationals
@implementation FDRationalDataBit

+(FDDataBit*)dataBitWithDatum:(const Exiv2::Metadatum*)datum{
    
    if (datum->count()!=2){
        return [FDNumberDataBit dataBitWithDatum:datum];
    }
    
    NSNumber *num = [NSNumber numberWithFloat:datum->toFloat(0)];
    NSNumber *denum = [NSNumber numberWithFloat:datum->toFloat(1)];
     
    return [[[FDRationalDataBit alloc] initWithNum:num denum:denum] autorelease];
    
}

-(id)initWithNum:(NSNumber*)num denum:(NSNumber*)denum{
    if ((self = [super init])){
        _num    = [num retain];
        _denum  = [denum retain];
    }
    return self;
}

- (void)dealloc{
    [_num release];
    [_denum release];
    [super dealloc];
}

-(BOOL)isEqual:(id)object{
    
    if (![object isKindOfClass:[FDRationalDataBit class]]) return NO;
    
    FDRationalDataBit *other = (FDRationalDataBit*)object;
    
    return ([other.num floatValue] == [_num floatValue]) && ([other.denum floatValue] == [_denum floatValue]);
    
}

-(NSString*)description{
    
    return [NSString stringWithFormat:@"%@/%@",_num,_denum];
    
}

@end


#pragma mark - Numbers
@implementation FDNumberDataBit

+(FDDataBit*)dataBitWithDatum:(const Exiv2::Metadatum*)datum{
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:datum->count()];
    for (int i = 0; i < datum->count(); ++i){
        [values addObject:[NSNumber numberWithFloat:datum->toFloat(i)]];
    }
    
    return [[[FDNumberDataBit alloc] initWithValues:values] autorelease];
    
}

-(id)initWithValues:(NSArray*)values{
    if ((self = [super init])){
        _values = [values retain];
    }
    return self;
}

- (void)dealloc{
    [_values release];
    [super dealloc];
}

-(BOOL)isEqual:(id)object{
    
    if (![object isKindOfClass:[FDNumberDataBit class]]) return NO;
    
    FDNumberDataBit *other = (FDNumberDataBit*)object;
    
    if (other.values.count != _values.count) return NO;
    
    for (int i = 0; i < _values.count; ++i){
        if ([other.values[i] floatValue] != [_values[i] floatValue]) return NO;
    }
    
    return YES;
    
}

-(NSString*)description{
    
    NSMutableString *desc = [[[NSMutableString alloc] init] autorelease];
    
    [desc appendFormat:@"%@",_values[0]];
    
    for (int i = 1; i < _values.count; ++i){
        [desc appendFormat:@" %@",_values[i]];
    }
    
    return desc;
}


@end