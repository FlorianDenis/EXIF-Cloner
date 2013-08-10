//
//  NSString+Utilities.m
//  EXIF Cloner
//
//  Created by Florian Denis on 8/9/13.
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

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

+(NSString*)sizeStringWithBytes:(NSInteger)bytes{
    
    if (bytes<(1<<10)){
        return [NSString stringWithFormat:@"%ld B",bytes];
    }
    if (bytes<(1<<20)){
        return [NSString stringWithFormat:@"%ld kB",bytes>>10];
    }
    if (bytes<(1<<30)){
        return [NSString stringWithFormat:@"%.1f MB",(double)bytes/(1<<20)];
    }
    
    return [NSString stringWithFormat:@"%.1f GB",(double)bytes/(1<<30)];
    
}

@end
