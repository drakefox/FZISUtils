//
//  MDFiveDigestHelper.h
//  HttpServerHelper
//
//  Created by Eri on 13-3-13.
//  Copyright (c) 2013年 Eri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDFiveDigestHelper : NSObject

+ (NSString *)md5HexDigest:(NSString *)originalString;

@end
