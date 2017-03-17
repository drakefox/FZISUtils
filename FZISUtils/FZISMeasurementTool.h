//
//  FZISMeasurementTool.h
//  FZISUtils
//
//  Created by fzis299 on 16/1/14.
//  Copyright (c) 2016年 FZIS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

//#define kLabelOffset 10.0
#define kLabelOffset CGPointMake(0, -20);

@interface FZISMeasurementTool : NSObject
{
    NSInteger _measurementType;
    NSMutableArray *_measurementPoints;
//    NSMutableArray *_measureLengthLables;
//    NSMutableArray *_measureAreaPoints;
//    NSMutableArray *_selectAddressPoints;
    AGSSketchGraphicsLayer *_drawLayer;
//    NSMutableArray *_labelGraphics;
    AGSGraphic *_lastLabelGraphic;
    
    NSMutableArray *_tmpGraphics;
    
    UIButton *_btnCleanup;
}

//@property (nonatomic, assign) NSInteger measurementType;

- (FZISMeasurementTool *)initWithDrawLayer:(AGSSketchGraphicsLayer *)layer;
- (void)startDistanceMeasurement;
- (void)startAreaMeasurement;
- (void)updateWithPoint:(AGSPoint *)point;
- (void)stopMeasurement;
- (void)cleanup;

@end
