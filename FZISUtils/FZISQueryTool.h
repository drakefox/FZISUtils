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
<AGSMapViewTouchDelegate,FZISLineViewDelegate,FZISNetworkToolDelegate,AGSIdentifyTaskDelegate>
{
    FZISMapView *_mapView;
    FZISLineView *_lineView;
    NSMutableDictionary *_results;
    
    FZISNetworkTool *_networkTool;
    
    NSArray *_layersInfo;
    NSMutableArray *_tiledLayerIds;
    NSMutableArray *_tiledLayerNames;
    
    AGSIdentifyTask *_identifyTask;
    AGSIdentifyParameters *_identifyParams;
}

@property (nonatomic, retain) id<FZISQueryToolDelegate> delegate;
@property (nonatomic, retain) AGSGraphic *queryGraphic;


- (FZISQueryTool *)initWithMapView:(FZISMapView *)mapView;
- (void)startSpatialQuery;
- (void)stopSpatialQuery;

@end


@protocol FZISQueryToolDelegate <NSObject>

@optional

- (void)FZISQueryTool:(FZISQueryTool *)queryTool didExecuteWithQueryResult:(NSDictionary *)result;
- (void)FZISQueryToolWillExecute;

@end