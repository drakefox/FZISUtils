//
//  FZISGPSTool.m
//  FZISUtils
//
//  Created by fzis299 on 16/1/26.
//  Copyright (c) 2016年 FZIS. All rights reserved.
//

#import "FZISGPSTool.h"

@implementation FZISGPSTool

- (FZISGPSTool *)initWithLocationDisplay:(AGSLocationDisplay *)locationDisplay
{
    self = [super init];
    if (self) {
        _locationDisplay = locationDisplay;
//        [_locationDisplay.dataSource setDelegate:self];
    }
    
    return self;
}

- (void)startLocationDisplay
{
    
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] ==  kCLAuthorizationStatusRestricted || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                      message:@"当前无法访问定位服务，请确认定位服务已打开并授权本应用使用。"
                                                     delegate:nil
                                            cancelButtonTitle:@"我知道了"
                                            otherButtonTitles:nil];
        [alert show];
    }
    
//    _locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    _locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeCompassNavigation;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    _locationDisplay.interfaceOrientation = orientation;
    _locationDisplay.wanderExtentFactor = 0;
    [_locationDisplay startDataSource];
}

- (void)stopLocationDisplay
{
    [_locationDisplay stopDataSource];
}
//
//- (void)locationDisplayDataSourceStarted:(id<AGSLocationDisplayDataSource>)dataSource
//{
//    NSLog(@"start...");
//}
//
//- (void)locationDisplayDataSource:(id<AGSLocationDisplayDataSource>)dataSource didUpdateWithLocation:(AGSLocation *)location
//{
//    NSLog(@"updating new location");
//}
//
//- (void)locationDisplayDataSource:(id<AGSLocationDisplayDataSource>)dataSource didUpdateWithHeading:(double)heading
//{
//    NSLog(@"updating new heading");
//}
//
//- (void)locationDisplayDataSource:(id<AGSLocationDisplayDataSource>)dataSource didFailWithError:(NSError *)error
//{
//    NSLog(@"error occurred");
//}
//
//- (void)locationDisplayDataSourceStopped:(id<AGSLocationDisplayDataSource>)dataSource
//{
//    NSLog(@"stopped...");
//}

@end
