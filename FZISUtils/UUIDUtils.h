//
//  UUIDUtils.h
//  FZISUtils
//
//  Created by fzis299 on 2017/2/21.
//  Copyright © 2017年 FZIS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UUIDUtils : NSObject

+ (void)saveUUIDToKeyChain:(NSString *)uuid;

+ (NSString *)readUUIDFromKeyChain;

+ (NSString *)getUUIDString;

@end
