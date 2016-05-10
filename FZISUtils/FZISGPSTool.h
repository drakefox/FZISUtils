//
//  FZISGPSTool.h
//  FZISUtils
//
//  Created by fzis299 on 16/1/26.
//  Copyright (c) 2016年 FZIS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface FZISGPSTool : NSObject
{
    AGSLocationDisplay *_locationDisplay;
}

- (FZISGPSTool *)initWithLocationDisplay:(AGSLocationDisplay *)locationDisplay;

- (void)startLocationDisplay;
- (void)stopLocationDisplay;

@end
