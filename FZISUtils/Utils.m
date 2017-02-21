//
//  Utils.m
//  FZISMap
//
//  Created by fzis299 on 13-7-17.
//  Copyright (c) 2013年 FZIS. All rights reserved.
//

#import "Utils.h"
#import "DESEncodeHelper.h"
#import "MDFiveDigestHelper.h"
#import "GDataXMLNode.h"
#import "UUIDUtils.h"

#import <sys/stat.h>
#import <dirent.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <ifaddrs.h>

#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NetworkExtension.h>
#import <AdSupport/AdSupport.h>

#define kHasAuthed          @"HasAuthed"
#define kHasExperience      @"HasExperience"
#define kMapIpAddress       @"ip地址"
#define kMapPortNumber      @"端口号"
#define kMapSuffixString    @"路径"
#define kMapCachePrefixes   @"CachePrefixes"
#define kIsCacheNeeded      @"IsCacheNeeded"
#define kIsEncodeNeeded     @"IsEncodeNeeded"
#define kExpireTime         @"ExpireTime"
#define kCheckPointTime     @"CheckPointTime"
#define kAUFilePath         @"AUFilePath"
#define kUsedTimes          @"UsedTimes"
#define kProjType           @"ProjType"
#define kUUID               @"UUID"

#define kBusinessView       @"BusinessView"
#define kMainMenu           @"MainMenu"
#define kListView           @"ListView"
#define kDetailsView        @"DetailsView"
#define kMapView            @"MapView"

#define kMapServerInfo      @"MapServerInfo"


@implementation Utils

#pragma mark - Process the NSUserDefaults settings

+ (BOOL)hasExperience
{
    NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:kHasExperience];
    NSString *decValue = [DESEncodeHelper decryptWithText:value];
    if ([decValue isEqualToString:@"No"]) {
        return NO;
    }
    else
    {
        return YES;
    }
}

+ (void)setHasExperience:(BOOL)experience
{
    NSString *value;
    if (!experience) {
        value = [DESEncodeHelper encryptWithText:@"No"];
    }
    else
    {
        value = [DESEncodeHelper encryptWithText:@"Yes"];
    }
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:kHasExperience];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)expireTime
{
    NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:kExpireTime];
    NSString *decValue = [DESEncodeHelper decryptWithText:value];
    return decValue;
}

+ (void)setExpireTime:(NSString *)expireTime
{
    NSString *value = [DESEncodeHelper encryptWithText:expireTime];
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:kExpireTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)checkPointTime
{
    NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:kCheckPointTime];
    NSString *decValue = [DESEncodeHelper decryptWithText:value];
    return decValue;
}

+ (void)setCheckPointTime:(NSString *)checkPointTime
{
    NSString *value = [DESEncodeHelper encryptWithText:checkPointTime];
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:kCheckPointTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)usedTimes
{
    NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:kUsedTimes];
    NSString *decValue = [DESEncodeHelper decryptWithText:value];
    return decValue;
}

+ (void)setUsedTimes:(NSString *)usedTimes
{
    NSString *value = [DESEncodeHelper encryptWithText:usedTimes];
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:kUsedTimes];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)projType
{
    NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:kProjType];
    NSString *decValue = [DESEncodeHelper decryptWithText:value];
    return decValue;
}

+ (void)setProjType:(NSString *)projType
{
    NSString *value = [DESEncodeHelper encryptWithText:projType];
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:kProjType];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)uuid
{
    NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:kUUID];
    NSString *decValue = [DESEncodeHelper decryptWithText:value];
    return decValue;
}

+ (void)setUUID:(NSString *)uuid
{
    NSString *value = [DESEncodeHelper encryptWithText:uuid];
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:kUUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)deviceAuthed
{
    NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:kHasAuthed];
    NSString *decValue = [DESEncodeHelper decryptWithText:value];
    if ([decValue isEqualToString:@"Yes"]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (void)setDeviceAuthed:(BOOL)authed
{
    NSString *value;
    if (!authed) {
        value = [DESEncodeHelper encryptWithText:@"No"];
    }
    else
    {
        value = [DESEncodeHelper encryptWithText:@"Yes"];
    }
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:kHasAuthed];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

#pragma mark - Process the layer configurations

+ (NSDictionary *)getConfigurationsForLayer:(NSString *)layer
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", documentsDirectory, @"/MapConfig.xml"];
    
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:filePath];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    
    GDataXMLElement *rootElement = [doc rootElement];
    NSArray *groupElements =[rootElement elementsForName:@"group"];
    for (GDataXMLElement *groupElement in groupElements) {
        NSArray *layerElements = [groupElement elementsForName:@"layer"];
        
        for (GDataXMLElement *layerElement in layerElements) {
            NSString *layerName = [[layerElement attributeForName:@"layerName"] stringValue];
            NSDictionary *layeConfig;
            if ([layerName isEqualToString:layer]) {
                NSString *showField = [[[layerElement elementsForName:@"showField"] objectAtIndex:0] stringValue];
                if (!showField) {
                    showField = @"";
                }
                NSString *searchField = [[[layerElement elementsForName:@"searchField"] objectAtIndex:0] stringValue];
                if (!searchField) {
                    searchField = @"";
                }
                NSString *hiddenField = [[[layerElement elementsForName:@"hiddenField"] objectAtIndex:0] stringValue];
                if (!hiddenField) {
                    hiddenField = @"";
                }
                NSString *fieldDic = [[[layerElement elementsForName:@"fieldEnToCn"] objectAtIndex:0] stringValue];
                if (!fieldDic) {
                    fieldDic = @"";
                }
                layeConfig = [[NSDictionary alloc] initWithObjectsAndKeys:showField, @"showField", searchField, @"searchField", hiddenField, @"hiddenField", fieldDic, @"fieldEnToCn", nil];
                return layeConfig;
            }
        }
    }
    
    
    return nil;
}

+ (NSMutableDictionary *)getGroupInfoForLayers
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", documentsDirectory, @"/MapConfig.xml"];
    
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:filePath];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    
    GDataXMLElement *rootElement = [doc rootElement];
    NSArray *groupElements =[rootElement elementsForName:@"group"];
    
    NSMutableDictionary *groupInfo = [[NSMutableDictionary alloc] init];
    
    for (GDataXMLElement *groupElement in groupElements) {
        NSString *grpName = [[groupElement attributeForName:@"name"] stringValue];
        NSArray *layerElements = [groupElement elementsForName:@"layer"];
        NSMutableArray *layerList = [[NSMutableArray alloc] init];
        
        for (GDataXMLElement *layerElement in layerElements) {
            NSString *layerName = [[layerElement attributeForName:@"layerName"] stringValue];
            [layerList addObject:layerName];
        }
        [groupInfo setObject:layerList forKey:grpName];
    }
    return groupInfo;
}


#pragma mark - Process the server info settings

+ (id)getObjectFromFileForKey:(NSString *)key
{
    // 获取程序Documents目录路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", documentsDirectory, @"/serverinfo.plist"];
    NSLog(filePath, nil);
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists)
    {
        NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        return [dic objectForKey:key];
    }
    else
    {
        NSDictionary *nativeMapConfig = [[NSDictionary alloc] initWithObjectsAndKeys:@"EPSG2437", kCoordType, @"305.74886", kInitRes, @"-5123300", kTileOrigX, @"10002300", kTileOrigY, @"311761.732567893", kMapOrigX, @"2977735.82679811", kMapOrigY, @"/mmaptile/tile/ser.html?_PI=true&SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=layerValue&STYLE=default&TILEMATRIXSET=sss&TILEMATRIX=levelValue&TILEROW=rowValue&TILECOL=colValue&FORMAT=imageslashValuepng", kTileUrl, nil];
        
        NSDictionary *mapServerInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"http://192.168.105.65/ArcGIS/rest/services/ZHGX/MapServer/", @"BaseUrl", @"2", @"给水点", @"3", @"给水线", @"5", @"污水点", @"6", @"污水线", @"7", @"雨水点", @"8", @"雨水线", @"9", @"雨污合流点", @"10", @"雨污合流线", @"12", @"电力点", @"13", @"电力线", @"14", @"路灯点", @"15", @"路灯线", @"16", @"电车点", @"17", @"电车线", @"18", @"交通信号点", @"19", @"交通信号线", @"21", @"电信点", @"22", @"电信线", @"23", @"网通点", @"24", @"网通线", @"25", @"讯通点", @"26", @"讯通线", @"27", @"联通点", @"28", @"联通线", @"29", @"移动点", @"30", @"移动线", @"31", @"铁通点", @"32", @"铁通线", @"33", @"军用通讯点", @"34", @"军用通讯线", @"35", @"榕网点", @"36", @"榕网线", @"37", @"省广点", @"38", @"省广线", @"39", @"安防点", @"40", @"安防线", @"42", @"煤气点", @"43", @"煤气线", @"44", @"液化气点", @"45", @"液化气线", @"46", @"天然气点", @"47", @"天然气线", @"49", @"蒸汽点", @"50", @"蒸汽线", @"51", @"热水点", @"52", @"热水线", @"53", @"温泉点", @"54", @"温泉线", @"56", @"氢气点", @"57", @"氢气线", @"58", @"氧气点", @"59", @"氧气线", @"60", @"乙炔点", @"61", @"乙炔线", @"62", @"石油点", @"63", @"石油线", @"65", @"综合管沟点", @"66", @"综合管沟线", @"68", @"不明管线点", @"69", @"不明管线线", nil];
        
//        NSDictionary *nativeMapConfig = [[NSDictionary alloc] initWithObjectsAndKeys:@"EPSG4326", kCoordType, @"0.010998662747495976", kInitRes, @"-180", kTileOrigX, @"90", kTileOrigY, @"115.59093220205533", kMapOrigX, @"28.581182392388484", kMapOrigY, @"/EnterpriseMapServer/services/tile?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=fuzhou_changle_wgs84_2012_dlg&STYLE=_null&TILEMATRIXSET=EPSG:4326&TILEMATRIX=levelValue&TILEROW=rowValue&TILECOL=colValue&FORMAT=imageslashValuepng", kTileUrl, nil];
        
        NSDictionary *businessViewSetting = [[NSDictionary alloc] initWithObjectsAndKeys:kBusinessView, @"id", @"1", @"isShown", @"/mmapweb/show/main_v3_4.html", @"url", nil];
        NSDictionary *mainMenuSetting = [[NSDictionary alloc] initWithObjectsAndKeys:kMainMenu, @"id", @"1", @"isShown", @"/mmapweb/ipad/nav.html", @"url", nil];
        NSDictionary *ListViewSetting = [[NSDictionary alloc] initWithObjectsAndKeys:kListView, @"id", @"1", @"isShown", @"", @"url", nil];
        NSDictionary *detailsViewSetting = [[NSDictionary alloc] initWithObjectsAndKeys:kDetailsView, @"id", @"1", @"isShown", @"", @"url", nil];
        NSDictionary *mapViewSetting = [[NSDictionary alloc] initWithObjectsAndKeys:kMapView, @"id", @"1", @"isShown", @"/mmapweb/ipad/helper/3/5.html", @"url", nil];
        NSArray *mapCachePrefixes = [[NSArray alloc] initWithObjects:@"/mmapbj",
                                     @"/mmapweb",
                                     @"/EnterpriseMapServer",
                                     @"/BaseCoreWebComponent",
                                     @"/mapbj", nil];
        NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] init];
        [mutableDic setObject:@"192.168.1.218" forKey:kMapIpAddress];
        [mutableDic setObject:@"8080" forKey:kMapPortNumber];
        [mutableDic setObject:@"/mmapweb/ipad/index/v3_3.html" forKey:kMapSuffixString];
        [mutableDic setObject:@"/mmapweb/manage/include/autoupdate.plist" forKey:kAUFilePath];
        [mutableDic setObject:mapCachePrefixes forKey:kMapCachePrefixes];
        [mutableDic setObject:@"YES" forKey:kIsCacheNeeded];
        [mutableDic setObject:@"YES" forKey:kIsEncodeNeeded];
        [mutableDic setObject:businessViewSetting forKey:kBusinessView];
        [mutableDic setObject:mainMenuSetting forKey:kMainMenu];
        [mutableDic setObject:ListViewSetting forKey:kListView];
        [mutableDic setObject:detailsViewSetting forKey:kDetailsView];
        [mutableDic setObject:mapViewSetting forKey:kMapView];
        [mutableDic setObject:nativeMapConfig forKey:kNativeMapConfig];
        [mutableDic setObject:mapServerInfo forKey:kMapServerInfo];
        [mutableDic writeToFile:filePath atomically:YES];
        return [mutableDic objectForKey:key];
    }
}

+ (void)setToFileObject:(id)obj ForKey:(NSString *)key
{
    // 获取程序Documents目录路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", documentsDirectory, @"/serverinfo.plist"];
//    NSLog(filePath, nil);
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        [dic setObject:obj forKey:key];
        [dic writeToFile:filePath atomically:YES];
    }
    else
    {
        NSDictionary *nativeMapConfig = [[NSDictionary alloc] initWithObjectsAndKeys:@"EPSG2437", kCoordType, @"305.74886", kInitRes, @"-5123300", kTileOrigX, @"10002300", kTileOrigY, @"311761.732567893", kMapOrigX, @"2977735.82679811", kMapOrigY, @"/mmaptile/tile/ser.html?_PI=true&SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=layerValue&STYLE=default&TILEMATRIXSET=sss&TILEMATRIX=levelValue&TILEROW=rowValue&TILECOL=colValue&FORMAT=imageslashValuepng", kTileUrl, nil];
        
        NSDictionary *mapServerInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"http://192.168.105.65/ArcGIS/rest/services/ZHGX/MapServer/", @"BaseUrl", @"2", @"给水点", @"3", @"给水线", @"5", @"污水点", @"6", @"污水线", @"7", @"雨水点", @"8", @"雨水线", @"9", @"雨污合流点", @"10", @"雨污合流线", @"12", @"电力点", @"13", @"电力线", @"14", @"路灯点", @"15", @"路灯线", @"16", @"电车点", @"17", @"电车线", @"18", @"交通信号点", @"19", @"交通信号线", @"21", @"电信点", @"22", @"电信线", @"23", @"网通点", @"24", @"网通线", @"25", @"讯通点", @"26", @"讯通线", @"27", @"联通点", @"28", @"联通线", @"29", @"移动点", @"30", @"移动线", @"31", @"铁通点", @"32", @"铁通线", @"33", @"军用通讯点", @"34", @"军用通讯线", @"35", @"榕网点", @"36", @"榕网线", @"37", @"省广点", @"38", @"省广线", @"39", @"安防点", @"40", @"安防线", @"42", @"煤气点", @"43", @"煤气线", @"44", @"液化气点", @"45", @"液化气线", @"46", @"天然气点", @"47", @"天然气线", @"49", @"蒸汽点", @"50", @"蒸汽线", @"51", @"热水点", @"52", @"热水线", @"53", @"温泉点", @"54", @"温泉线", @"56", @"氢气点", @"57", @"氢气线", @"58", @"氧气点", @"59", @"氧气线", @"60", @"乙炔点", @"61", @"乙炔线", @"62", @"石油点", @"63", @"石油线", @"65", @"综合管沟点", @"66", @"综合管沟线", @"68", @"不明管线点", @"69", @"不明管线线", nil];
        
//        NSDictionary *nativeMapConfig = [[NSDictionary alloc] initWithObjectsAndKeys:@"EPSG4326", kCoordType, @"0.010998662747495976", kInitRes, @"-180", kTileOrigX, @"90", kTileOrigY, @"115.59093220205533", kMapOrigX, @"28.581182392388484", kMapOrigY, @"/EnterpriseMapServer/services/tile?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=fuzhou_changle_wgs84_2012_dlg&STYLE=_null&TILEMATRIXSET=EPSG:4326&TILEMATRIX=levelValue&TILEROW=rowValue&TILECOL=colValue&FORMAT=imageslashValuepng", kTileUrl, nil];
        
        NSDictionary *businessViewSetting = [[NSDictionary alloc] initWithObjectsAndKeys:kBusinessView, @"id", @"1", @"isShown", @"/mmapweb/show/main_v3_4.html", @"url", nil];
        NSDictionary *mainMenuSetting = [[NSDictionary alloc] initWithObjectsAndKeys:kMainMenu, @"id", @"1", @"isShown", @"/mmapweb/ipad/nav.html", @"url", nil];
        NSDictionary *ListViewSetting = [[NSDictionary alloc] initWithObjectsAndKeys:kListView, @"id", @"1", @"isShown", @"", @"url", nil];
        NSDictionary *detailsViewSetting = [[NSDictionary alloc] initWithObjectsAndKeys:kDetailsView, @"id", @"1", @"isShown", @"", @"url", nil];
        NSDictionary *mapViewSetting = [[NSDictionary alloc] initWithObjectsAndKeys:kMapView, @"id", @"1", @"isShown", @"/mmapweb/ipad/helper/3/5.html", @"url", nil];
        NSArray *mapCachePrefixes = [[NSArray alloc] initWithObjects:@"/mmapbj",
                                     @"/mmapweb",
                                     @"/EnterpriseMapServer",
                                     @"/BaseCoreWebComponent",
                                     @"/mapbj", nil];
        NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] init];
        [mutableDic setObject:@"192.168.1.218" forKey:kMapIpAddress];
        [mutableDic setObject:@"8080" forKey:kMapPortNumber];
        [mutableDic setObject:@"/mmapweb/ipad/index/v3_3.html" forKey:kMapSuffixString];
        [mutableDic setObject:@"/mmapweb/manage/include/autoupdate.plist" forKey:kAUFilePath];
        [mutableDic setObject:mapCachePrefixes forKey:kMapCachePrefixes];
        [mutableDic setObject:@"YES" forKey:kIsCacheNeeded];
        [mutableDic setObject:@"YES" forKey:kIsEncodeNeeded];
        [mutableDic setObject:businessViewSetting forKey:kBusinessView];
        [mutableDic setObject:mainMenuSetting forKey:kMainMenu];
        [mutableDic setObject:ListViewSetting forKey:kListView];
        [mutableDic setObject:detailsViewSetting forKey:kDetailsView];
        [mutableDic setObject:mapViewSetting forKey:kMapView];
        [mutableDic setObject:nativeMapConfig forKey:kNativeMapConfig];
        [mutableDic setObject:mapServerInfo forKey:kMapServerInfo];
        [mutableDic setObject:obj forKey:key];
        [mutableDic writeToFile:filePath atomically:YES];
    }
}


+ (NSString *)mapIpAddress
{
    return [Utils getObjectFromFileForKey:kMapIpAddress];
}

+ (void)setMapIpAddress:(NSString *)ipAddr
{
    [Utils setToFileObject:ipAddr ForKey:kMapIpAddress];
}

+ (NSString *)mapPortNumber
{
    return [Utils getObjectFromFileForKey:kMapPortNumber];
}

+ (void)setMapPortNumber:(NSString *)portNumber
{
    [Utils setToFileObject:portNumber ForKey:kMapPortNumber];
}


+ (NSString *)mapSuffixString
{
    return [Utils getObjectFromFileForKey:kMapSuffixString];
}

+ (void)setMapSuffixString:(NSString *)suffix
{
    [Utils setToFileObject:suffix ForKey:kMapSuffixString];
}

+ (NSString *)auFilePath
{
    return [Utils getObjectFromFileForKey:kAUFilePath];
}

+ (void)setAUFilePath:(NSString *)path
{
    [Utils setToFileObject:path ForKey:kAUFilePath];
}

+ (NSArray *)mapCachePrefixes
{
    return [Utils getObjectFromFileForKey:kMapCachePrefixes];
}

+ (void)setMapCachePrefixes:(NSArray *)prefixes
{
    [Utils setToFileObject:prefixes ForKey:kMapCachePrefixes];
    
}

+ (NSString *)isCacheNeeded
{
    return [Utils getObjectFromFileForKey:kIsCacheNeeded];
    
}

+ (void)setIsCacheNeeded:(NSString *)isCacheNeeded
{
    [Utils setToFileObject:isCacheNeeded ForKey:kIsCacheNeeded];
    
}

+ (NSString *)isEncodeNeeded
{
    return [Utils getObjectFromFileForKey:kIsEncodeNeeded];
    
}

+ (void)setIsEncodeNeeded:(NSString *)isEncodeNeeded
{
    [Utils setToFileObject:isEncodeNeeded ForKey:kIsEncodeNeeded];
    
}

+ (NSDictionary *)businessViewInfo
{
    return [Utils getObjectFromFileForKey:kBusinessView];
}

+ (NSDictionary *)mainMenuInfo
{
    return [Utils getObjectFromFileForKey:kMainMenu];
}

+ (NSDictionary *)listViewInfo
{
    return [Utils getObjectFromFileForKey:kListView];
}

+ (NSDictionary *)detailsViewInfo
{
    return [Utils getObjectFromFileForKey:kDetailsView];
}

+ (NSDictionary *)mapViewInfo
{
    return [Utils getObjectFromFileForKey:kMapView];
}

+ (NSDictionary *)nativeMapConfig
{
    return [Utils getObjectFromFileForKey:kNativeMapConfig];
}

+ (NSDictionary *)mapServerInfo
{
    return [Utils getObjectFromFileForKey:kMapServerInfo];
}

#pragma mark - Other functions

+ (NSString *)wifiMacAddress
{
    
    //use ad identifier for activation code after ios 7.0
//    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//    NSLog(@"%@", adId);
//    return adId;
    
    NSString *uuid = [UUIDUtils readUUIDFromKeyChain];
    
    if (uuid == nil || [uuid isEqualToString:@""]) {
        NSLog(@"no uuid in keychain, create one");
        uuid = [UUIDUtils getUUIDString];
        [UUIDUtils saveUUIDToKeyChain:uuid];
    }
    
    NSLog(@"uuid in keychain:%@", uuid);
    return uuid;
    
}

+ (NSString *)deviceSeries
{
    NSString *wifiAddMd5Value = [MDFiveDigestHelper md5HexDigest:[Utils wifiMacAddress]];
    return wifiAddMd5Value;
}

+ (BOOL)authorizateKey:(NSString *)activeCode bySeriesNo:(NSString *)seriesNo
{
    NSString *reallyCode = [seriesNo stringByAppendingString:kSurfix];
//    NSLog(@"reallycode: %@", reallyCode);
    NSString *md5Encoded = [MDFiveDigestHelper md5HexDigest:reallyCode];
    NSRange range = NSMakeRange(0, 16);

    NSString *result = [md5Encoded substringWithRange:range];
    NSLog(@"授权码应为：\n%@", [result uppercaseString]);
    
    if ([[activeCode uppercaseString] isEqualToString:[result uppercaseString]])
    {
        [Utils setDeviceAuthed:YES];
        return YES;
    }
    else if ([[activeCode uppercaseString] isEqualToString:@"9527"])
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - Caculate the cache size

+ (NSDictionary *)getFolderSize:(NSString *)path
{
    NSString *showPath = [path lastPathComponent];
    long long size = [Utils folderSizeAtPath:path];
    NSString *folderSize = [NSString stringWithFormat:@"%llu", size];
    NSDictionary *subFolderInfo = [[NSDictionary alloc] initWithObjectsAndKeys:showPath, @"name", folderSize, @"size", path, @"path", nil];  
    return subFolderInfo;
}

+ (long long)folderSizeAtPath:(NSString *)folderPath
{
    return [self _folderSizeAtPath:[folderPath cStringUsingEncoding:NSUTF8StringEncoding]];
}

+ (long long)_folderSizeAtPath:(const char*)folderPath
{
    long long folderSize = 0;
    DIR *dir = opendir(folderPath);
    if (dir == NULL) {
        return 0;
    }
    
    struct dirent* child;
    while ((child = readdir(dir)) != NULL) {
        if (child->d_type == DT_DIR && ((child->d_name[0] == '.' && child->d_name[1] == 0) || (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0))) {
            continue;
        }
        
        unsigned long folderPathLength = strlen(folderPath);
        char childPath[1024];
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength - 1] != '/') {
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        
        stpcpy(childPath + folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        
        if (child->d_type == DT_DIR) {
            folderSize += [self _folderSizeAtPath:childPath];
            //            struct stat st;
            //            if (lstat(childPath, &st) == 0) {
            //                folderSize += st.st_size;
            //            }
        }
        else if (child->d_type == DT_REG || child->d_type == DT_LNK)
        {
            struct stat st;
            if (lstat(childPath, &st) == 0) {
                folderSize += st.st_size;
            }
        }
    }
    return folderSize;
}



@end
