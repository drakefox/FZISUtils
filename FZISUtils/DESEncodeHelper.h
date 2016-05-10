//
//  DESEncodeHelper.h
//  FZISMap
//
//  Created by fzis299 on 13-7-17.
//  Copyright (c) 2013年 FZIS. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kEncryKey @"fzis2012"

@interface DESEncodeHelper : NSObject

+ (NSString *)encryptWithText:(NSString *)sText;//加密
+ (NSString *)decryptWithText:(NSString *)sText;//解密

@end
