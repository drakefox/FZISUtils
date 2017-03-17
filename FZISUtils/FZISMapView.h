//
//  FZISMapView.h
//  FZISUtils
//
//  Created by fzis299 on 16/1/26.
//  Copyright (c) 2016年 FZIS. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "FZISMeasurementTool.h"
#import "FZISGPSTool.h"

#define kMapNormal 0
#define kMapMeasureDistance 1
#define kMapMeasureArea 2
#define kDrawFeaturePoint 3
#define kDrawFeatureLine 4
#define kDrawFeaturePolygon 5
#define kShowFeaturePoint 6
#define kShowFeatureLine 7
#define kShowFeaturePolygon 8
#define kHighlightFeaturePoint 9
#define kHighlightFeatureLine 10
#define kHighlightFeaturePolygon 11
#define kMapEndMeasure 12
#define kMapEndDraw 13
#define kMapCleanup 14
#define kMapSandBox 15

#define kLayerTypeSHP 20
#define kLayerTypeTILED 21
#define kLayerTypeGDB 22
#define kLayerTypeRT 23

@interface FZISMapView : AGSMapView
<AGSCalloutDelegate,AGSMapViewLayerDelegate,AGSMapViewTouchDelegate>
{
    FZISMeasurementTool *_measurementTool;
    FZISGPSTool *_gpsTool;
    NSInteger _baseLayerCount;
//    AGSGDBGeodatabase *geoDatabase;
}

@property (nonatomic, assign) NSInteger mapStatus;
@property (nonatomic, assign) BOOL isAccurateMeasure;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) AGSSketchGraphicsLayer *sketchLayer;

@property (nonatomic, retain) NSMutableArray *SHPLayers;
@property (nonatomic, retain) NSMutableArray *TILEDLayers;
@property (nonatomic, retain) NSMutableArray *GDBLayers;

@property (nonatomic, retain) NSMutableDictionary *invisibleLayers;

@property (nonatomic, retain) NSDictionary *mapServerInfo;

@property (nonatomic, retain) NSDictionary *layerTree;
@property (nonatomic, retain) NSMutableDictionary *nameFieldSettings;
@property (nonatomic, retain) NSMutableDictionary *keyFieldsSettings;
@property (nonatomic, retain) NSMutableDictionary *detailFieldsSettings;
@property (nonatomic, retain) NSMutableDictionary *fieldConvSettings;
@property (nonatomic, retain) NSMutableDictionary *maxScaleSettings;
@property (nonatomic, retain) NSMutableDictionary *minScaleSettings;
@property (nonatomic, retain) NSMutableDictionary *canQuerySettings;
@property (nonatomic, retain) NSMutableDictionary *isVisibleSettings;



- (void)initMapView;
- (void)loadBaseMap;

- (void)showDom:(BOOL)showDom showDlg:(BOOL)showDlg animate:(BOOL)animate;

- (void)loadLayer:(NSString *)layerName;
- (void)loadLayer:(NSString *)layerName withType:(NSInteger)layerType;
- (void)removeMapLayerWithName2:(NSString *)layerName;
- (void)removeMapLayerWithLayerName:(NSString *)layerName;
//- (UIImage*)snapshot:(UIView*)eaglview;
- (UIImage *)saveMapImage;

- (void)changeOpacityForLayer:(NSString *)layer toValue:(float)opacity;

- (void)startLocationDisplay;
- (void)stopLocationDisplay;

- (void)showCustomizedCallout:(UIViewController *)controller forFeature:(id)feature withInfo:(NSDictionary *)info;

- (void)removeObservers;

@end
