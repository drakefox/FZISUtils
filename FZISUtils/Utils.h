//
//  Utils.h
//  FZISMap
//
//  Created by fzis299 on 13-7-17.
//  Copyright (c) 2013年 FZIS. All rights reserved.
//

#import "GDataXMLNode.h"

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>

#define kSurfix @"9527"
#define kImageSizeWidth  (1024/7)
#define kImageSizeHeigh  (748/7)

#define kNativeMapConfig    @"NativeMapConfig"
#define kTileOrigX          @"TileOrigX"
#define kTileOrigY          @"TileOrigY"
#define kMapOrigX           @"MapExtX"
#define kMapOrigY           @"MapExtY"
#define kInitRes            @"InitRes"
#define kCoordType          @"CoordType"
#define kTileUrl            @"tileUrl"
#define kDLGLayer           @"DLGLayer"
#define kDOMLayer           @"DOMLayer"

@interface Utils : NSObject

+ (NSString *)wifiMacAddress;
+ (NSString *)deviceSeries;
+ (BOOL)authorizateKey:(NSString *)activeCode bySeriesNo:(NSString *)seriesNo;


+ (BOOL)hasExperience;
+ (void)setHasExperience:(BOOL)experience;

+ (NSString *)expireTime;
+ (void)setExpireTime:(NSString *)expireTime;

+ (NSString *)usedTimes;
+ (void)setUsedTimes:(NSString *)usedTimes;

+ (NSString *)projType;
+ (void)setProjType:(NSString *)projType;

+ (BOOL)deviceAuthed;
+ (void)setDeviceAuthed:(BOOL)authed;

+ (id)getObjectFromFileForKey:(NSString *)key;
+ (void)setToFileObject:(id)obj ForKey:(NSString *)key;

+ (NSString *)mapIpAddress;
+ (void)setMapIpAddress:(NSString *)ipAddr;

+ (NSString *)mapPortNumber;
+ (void)setMapPortNumber:(NSString *)portNumber;

+ (NSString *)mapSuffixString;
+ (void)setMapSuffixString:(NSString *)suffix;

+ (NSString *)auFilePath;
+ (void)setAUFilePath:(NSString *)path;

+ (NSArray *)mapCachePrefixes;
+ (void)setMapCachePrefixes:(NSArray *)prefixes;

+ (NSString *)isCacheNeeded;
+ (void)setIsCacheNeeded:(NSString *)isCacheNeeded;

+ (NSString *)isEncodeNeeded;
+ (void)setIsEncodeNeeded:(NSString *)isCacheNeeded;

+ (NSDictionary *)businessViewInfo;
+ (NSDictionary *)mainMenuInfo;
+ (NSDictionary *)listViewInfo;
+ (NSDictionary *)detailsViewInfo;
+ (NSDictionary *)mapViewInfo;
+ (NSDictionary *)nativeMapConfig;
+ (NSDictionary *)mapServerInfo;


+ (NSDictionary *)getConfigurationsForLayer:(NSString *)layer;
+ (NSMutableDictionary *)getGroupInfoForLayers;


+ (NSDictionary *)getFolderSize:(NSString *)path;
+ (long long)folderSizeAtPath:(NSString *)folderPath;


@end
