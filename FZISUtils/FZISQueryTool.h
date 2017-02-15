//
//  FZISQueryTool.h
//  MPDemo
//
//  Created by fzis299 on 16/1/19.
//  Copyright (c) 2016年 FZIS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZISMapView.h"
#import "FZISLineView.h"
#import "FZISNetworkTool.h"

@protocol FZISQueryToolDelegate;


@interface FZISQueryTool : NSObject
<AGSMapViewTouchDelegate,FZISLineViewDelegate,FZISNetworkToolDelegate,AGSIdentifyTaskDelegate, AGSQueryTaskDelegate>
{
    FZISMapView *_mapView;
    FZISLineView *_lineView;
    NSMutableDictionary *_results;
    
    FZISNetworkTool *_networkTool;
    
    NSArray *_layersInfo;
    NSMutableArray *_tiledLayerIds;
    NSMutableArray *_tiledLayerNames;
    
    NSMutableDictionary *_layerNameDic;
    
    AGSIdentifyTask *_identifyTask;
    AGSIdentifyParameters *_identifyParams;
    
    NSMutableDictionary *_queryTasks;
    
    AGSLayer *_statisticLayer;
}

@property (nonatomic, retain) id<FZISQueryToolDelegate> delegate;
@property (nonatomic, retain) AGSGraphic *queryGraphic;


- (FZISQueryTool *)initWithMapView:(FZISMapView *)mapView;
- (void)startSpatialQuery;
- (void)stopSpatialQuery;
- (void)startSearchWithKeyword:(NSString *)keyword;
- (void)startSearchWithKeyword:(NSString *)keyword onLayer:(NSString *)layerName;
- (void)startSearchWithKeyword:(NSString *)keyword onLayers:(NSArray *)layers;
- (void)startStatisticOnLayer:(AGSLayer *)layer;

@end


@protocol FZISQueryToolDelegate <NSObject>

@optional

- (void)FZISQueryTool:(FZISQueryTool *)queryTool didExecuteWithQueryResult:(NSDictionary *)result;
- (void)FZISQueryTool:(FZISQueryTool *)queryTool didExecuteWithStatisticResult:(NSDictionary *)result;
- (void)FZISQueryToolWillExecute;

@end
