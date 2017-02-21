//
//  UUIDUtils.m
//  FZISUtils
//
//  Created by fzis299 on 2017/2/21.
//  Copyright © 2017年 FZIS. All rights reserved.
//

#import "UUIDUtils.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>

@implementation UUIDUtils

+(void)saveUUIDToKeyChain:(NSString *)uuid
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithAccount:@"com.FZIS.YDGX" service:@"YDGX" accessGroup:nil];
//    NSString *string = [keychainItem objectForKey: (__bridge id)kSecAttrGeneric];
//    if([string isEqualToString:@""] || !string){
//        [keychainItem setObject:[self getUUIDString] forKey:(__bridge id)kSecAttrGeneric];
//    }
    [keychainItem setObject:uuid forKey:(__bridge id)kSecAttrGeneric];
}

+(NSString *)readUUIDFromKeyChain
{
    KeychainItemWrapper *keychainItemm = [[KeychainItemWrapper alloc] initWithAccount:@"com.FZIS.YDGX" service:@"YDGX" accessGroup:nil];
    NSString *UUID = [keychainItemm objectForKey: (__bridge id)kSecAttrGeneric];
    return UUID;
}

+ (NSString *)getUUIDString
{
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault , uuidRef);
    NSString *uuidString = [(__bridge NSString*)strRef stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(strRef);
    CFRelease(uuidRef);
    return uuidString;
}

@end
