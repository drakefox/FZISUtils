//
//  MDFiveDigestHelper.m
//  HttpServerHelper
//
//  Created by Eri on 13-3-13.
//  Copyright (c) 2013年 Eri. All rights reserved.
//

#import "MDFiveDigestHelper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MDFiveDigestHelper

+ (NSString *)md5HexDigest:(NSString *)originalString
{
    const char *original_str = [originalString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [hash appendFormat:@"%02X", result[i]];
    }
    
    NSString *md5String = [hash lowercaseString];
    
//    NSLog(@"%@ --> %@", originalString, md5String);
    
    return md5String;
}

@end
