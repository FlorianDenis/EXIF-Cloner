//
//  EXIF_Cloner_Test_Suite.m
//  EXIF Cloner Test Suite
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

#import "EXIF_Cloner_Test_Suite.h"
#import "FDMetadataContainer.h"

@implementation EXIF_Cloner_Test_Suite{
    NSDictionary *tests;
}

-(void)setUp{
    
    // Some know values for test images
    // I should dump them into a .plist and verify the whole thing instead of a subset...
    tests = @{@"Crater Lake":@{
                  @"Exif.Image.ImageWidth": @3840,
                  @"Exif.Image.ImageLength": @2400,
                  @"Exif.Image.Model": @"Canon EOS 5D Mark III",
                  @"Exif.Photo.ExposureTime": @0.02,
                  @"Iptc.Application2.RecordVersion": @97,
                  @"Xmp.crs.RawFileName": @"132.CR2",
                  @"Xmp.crs.Sharpness": @"65",
                  },
              @"Mt Hood":@{
                  @"Exif.Image.ImageWidth": @5472,
                  @"Exif.Image.ImageLength": @3420,
                  @"Exif.Image.Model": @"Canon EOS 6D",
                  @"Exif.Photo.ExposureTime": @0.0025,
                  @"Iptc.Application2.RecordVersion": @4,
                  @"Xmp.crs.LensProfileSetup": @"LensDefaults",
                  @"Xmp.crs.Sharpness": @"0",
              }};

}

#pragma mark - Test reading metadata

// Testing that reading data from a known set of jpg picture works
-(void)testReadingFileCorrect{
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSArray *testFilenames = tests.allKeys;
    
    for (NSString *filename in testFilenames){
        
        NSString *filepath = [bundle pathForResource:filename ofType:@"jpg"];
        
        FDMetadataContainer *container = [FDMetadataContainer metadataForImageAtPath:filepath];
        STAssertNotNil(container, @"Nil metadata from valid file");

        NSDictionary *truth = tests[filename];
        NSArray *keys = [truth allKeys];
        
        // Check that those values are matching
        for (NSString *key in keys){
            id known = truth[key];
            id read = container[key];
            STAssertTrue([[read description] isEqualToString:[known description]], @"Wrong value reading on %@: %@ '%@' != '%@'",filename,key,known,read);
            
        }
        
    }

}

// Testing that reading from non-existent file fails
-(void)testReadingNonexistentFile{
    
    // Generate a unique filename, so that this particular file does not exist
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *filename = [guid stringByAppendingPathExtension:@"jpg"];
    NSString *filepath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    
    // Try to read metadata from that unexistent file, expect nil
    STAssertNil([FDMetadataContainer metadataForImageAtPath:filepath], @"Non nil value for reading from unexistent file %@",filepath);
    
}

// Testing that reading from invalid file fails
-(void)testReadingInvalidFile{
    
    // Generate a unique filename, so that this particular file does not exist
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *filename = [guid stringByAppendingPathExtension:@"jpg"];
    NSString *filepath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    
    // Copy an invalid file (our binary...) to that path
    NSString *invalidOriginalFile = [[NSBundle bundleForClass:[self class]] pathForAuxiliaryExecutable:@"EXIF Cloner Test Suite"];
    [[NSFileManager defaultManager] copyItemAtPath:invalidOriginalFile toPath:filepath error:NULL];
    
    // Try to read metadata from that unvalid file, expect nil
    STAssertNil([FDMetadataContainer metadataForImageAtPath:filepath], @"Non nil value for reading from invalid file %@",filepath);
    
}

#pragma mark - Test writing metadata

// Testing that writing succeeds
-(void)testWritingFile{
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    // Generate a unique filename, so that this particular file does not exist
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *dstfilename = [guid stringByAppendingPathExtension:@"jpg"];
    NSString *dstfilepath = [NSTemporaryDirectory() stringByAppendingPathComponent:dstfilename];

    // Copy a blank file to that path
    NSString *blankOriginalFile = [bundle pathForResource:@"blank" ofType:@"jpg"];
    [[NSFileManager defaultManager] copyItemAtPath:blankOriginalFile toPath:dstfilepath error:NULL];
    
    // Now test copying metadata 
    NSArray *testFilenames = tests.allKeys;
    
    for (NSString *filename in testFilenames){
        
        NSString *filepath = [bundle pathForResource:filename ofType:@"jpg"];
        
        // Read metadata from source file
        FDMetadataContainer *container = [FDMetadataContainer metadataForImageAtPath:filepath];
        STAssertNotNil(container, @"Nil metadata from valid file");
        
        // Copy that to the dst, make sure it succeeds
        STAssertTrue([container saveMetadataToFileAtPath:dstfilepath], @"Nil metadata from valid file");
        
        // Read data from the dst
        FDMetadataContainer *dstcontainer = [FDMetadataContainer metadataForImageAtPath:dstfilepath];
        STAssertNotNil(dstcontainer, @"Nil metadata from valid file");
        
        // And make sure the data in the destination matches the one we know is true
        NSDictionary *truth = tests[filename];
        NSArray *keys = [truth allKeys];
        for (NSString *key in keys){
            id known = truth[key];
            id read = dstcontainer[key];
            
            STAssertTrue([[read description] isEqualToString:[known description]], @"Wrong value reading on %@: %@ '%@' != '%@'",filename,key,known,read);
            
        }


    }

    
}


// Test that writing to an inexistent file fails
-(void)testWritingNonexistentFile{
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    // Generate a unique filename, so that this particular file does not exist
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *filename = [guid stringByAppendingPathExtension:@"jpg"];
    NSString *filepath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
        
    // Retrieve a known valid file
    NSString *validfilename = tests.allKeys[0];
    NSString *validfilepath = [bundle pathForResource:validfilename ofType:@"jpg"];
    
    // Read metadata from source file
    FDMetadataContainer *container = [FDMetadataContainer metadataForImageAtPath:validfilepath];
    STAssertNotNil(container, @"Nil metadata from valid file");
    
    // Check that writing failed
    STAssertFalse([container saveMetadataToFileAtPath:filepath], @"Writing succeeded on non-existent file");
    
}


// Test that writing to an invalid file fails
-(void)testWritingInvalidFile{
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    // Generate a unique filename, so that this particular file does not exist
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *filename = [guid stringByAppendingPathExtension:@"jpg"];
    NSString *filepath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    
    // Copy an invalid file (our binary...) to that path
    NSString *invalidOriginalFile = [[NSBundle bundleForClass:[self class]] pathForAuxiliaryExecutable:@"EXIF Cloner Test Suite"];
    [[NSFileManager defaultManager] copyItemAtPath:invalidOriginalFile toPath:filepath error:NULL];
    
    // Retrieve a known valid file
    NSString *validfilename = tests.allKeys[0];
    NSString *validfilepath = [bundle pathForResource:validfilename ofType:@"jpg"];
        
    // Read metadata from source file
    FDMetadataContainer *container = [FDMetadataContainer metadataForImageAtPath:validfilepath];
    STAssertNotNil(container, @"Nil metadata from valid file");

    // Check that writing failed
    STAssertFalse([container saveMetadataToFileAtPath:filepath], @"Writing succeeded on invalid file");
    
}


@end
