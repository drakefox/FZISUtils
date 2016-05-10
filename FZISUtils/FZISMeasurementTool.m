//
//  FZISMeasurementTool.m
//  FZISUtils
//
//  Created by fzis299 on 16/1/14.
//  Copyright (c) 2016年 FZIS. All rights reserved.
//

#import "FZISMeasurementTool.h"
//#import "FZISMapView.h"

@implementation FZISMeasurementTool


- (FZISMeasurementTool *)initWithDrawLayer:(AGSSketchGraphicsLayer *)layer
{
    self = [super init];
    if (self) {
        _drawLayer = layer;
        _measurementPoints = [[NSMutableArray alloc] init];
        _tmpGraphics = [[NSMutableArray alloc] init];
        _btnCleanup = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        _btnCleanup.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.6];
        
        [_btnCleanup setTitle:@"X" forState:UIControlStateNormal];
        [_btnCleanup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnCleanup addTarget:self action:@selector(btnCleanupClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [layer.mapView addSubview:_btnCleanup];
    }
    return self;
}

- (void)btnCleanupClicked:(id)sender
{
    [self cleanup];
}

- (void)startDistanceMeasurement
{
    [self cleanup];
    _measurementType = 0;
}

- (void)startAreaMeasurement
{
    [self cleanup];
    _measurementType = 1;
}

- (void)updateWithPoint:(AGSPoint *)point
{
    AGSSimpleMarkerSymbol* markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    markerSymbol.color = [UIColor greenColor];
    markerSymbol.size = CGSizeMake(8.0, 8.0);
    markerSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
    
    AGSGraphic *graphicPoint = [AGSGraphic graphicWithGeometry:point symbol:markerSymbol attributes:nil];
    [_drawLayer addGraphic:graphicPoint];
    
    [_measurementPoints addObject:point];
    
    if (_measurementType == 0) {
        [self measureDistance];
    }
    else
    {
        [self measureArea];
    }
}

- (void)measureDistance
{
    if ([_tmpGraphics count] > 0) {
        [_drawLayer removeGraphics:_tmpGraphics];//清除旧的
        [_tmpGraphics removeAllObjects];
    }
    
    AGSPoint *lastPoint = [_measurementPoints lastObject];
    
    AGSPoint *distancetLablePoint = [AGSPoint pointWithX:lastPoint.x + kLabelOffset * _drawLayer.mapView.mapScale / _drawLayer.mapView.maxScale y:lastPoint.y - kLabelOffset * _drawLayer.mapView.mapScale / _drawLayer.mapView.maxScale spatialReference:lastPoint.spatialReference];
    
    AGSMapView *mapView = _drawLayer.mapView;
    CGPoint lastScreenPoint = [mapView toScreenPoint:lastPoint];
    CGPoint btnCleanupOrigPoint = CGPointMake(lastScreenPoint.x - 15.0, lastScreenPoint.y - 40.0);
    
    _btnCleanup.frame = CGRectMake(btnCleanupOrigPoint.x, btnCleanupOrigPoint.y, 30, 30);
    
    NSString *distanceDisplay = @"";
    
    AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
    
    NSInteger pointCount = [_measurementPoints count];
    
    if (pointCount >= 2) {
        AGSMutablePolyline *line = [[AGSMutablePolyline alloc] init];
        [line addPathToPolyline];
        for (NSInteger i = pointCount - 1; i >= 0; i--) {
            AGSPoint *point = [_measurementPoints objectAtIndex:i];
            [line addPoint:point toPath:0];
        }
        
        AGSSimpleLineSymbol * lineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
        lineSymbol.style = AGSSimpleLineSymbolStyleSolid;
        lineSymbol.width = 2;
        lineSymbol.color = [UIColor blueColor];
        
        AGSGraphic *tmpGraphic = [AGSGraphic graphicWithGeometry:line symbol:lineSymbol attributes:nil];
        [_tmpGraphics addObject:tmpGraphic];
        [_drawLayer addGraphics:_tmpGraphics];
        
        double totalDistance = fabs([geometryEngine lengthOfGeometry:line]);
        if (totalDistance > 1000.0f) {
            totalDistance = totalDistance / 1000.0f;
            distanceDisplay = [NSString stringWithFormat:@"%0.2f公里", totalDistance];
        }
        else
        {
            distanceDisplay = [NSString stringWithFormat:@"%0.2f米", totalDistance];
        }
        
    }
    else
    {
        distanceDisplay = @"起点";
    }
    AGSTextSymbol *txtSymbol = [[AGSTextSymbol alloc] initWithText:distanceDisplay color:[UIColor purpleColor]];
    txtSymbol.fontSize = 17.0f;
    txtSymbol.fontFamily = @"Heiti SC";
    AGSGraphic *distanceLabel = [AGSGraphic graphicWithGeometry:distancetLablePoint symbol:txtSymbol attributes:nil];
    _lastLabelGraphic = distanceLabel;
    [_drawLayer addGraphic:distanceLabel];
}


- (void)measureArea
{
    if ([_tmpGraphics count] > 0) {
        [_drawLayer removeGraphics:_tmpGraphics];//清除旧的
        [_tmpGraphics removeAllObjects];
    }
    
    AGSPoint *lastPoint = [_measurementPoints lastObject];
    AGSPoint *areaLablePoint = [AGSPoint pointWithX:lastPoint.x + kLabelOffset * _drawLayer.mapView.mapScale / _drawLayer.mapView.maxScale y:lastPoint.y - kLabelOffset * _drawLayer.mapView.mapScale / _drawLayer.mapView.maxScale spatialReference:lastPoint.spatialReference];
    
    AGSMapView *mapView = _drawLayer.mapView;
    CGPoint lastScreenPoint = [mapView toScreenPoint:lastPoint];
    CGPoint btnCleanupOrigPoint = CGPointMake(lastScreenPoint.x - 15.0, lastScreenPoint.y - 40.0);
    
    _btnCleanup.frame = CGRectMake(btnCleanupOrigPoint.x, btnCleanupOrigPoint.y, 30, 30);
    
    NSString *areaDisplay = @"";
    
    //AGSPoint *lastPoint;
    AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
    
    NSInteger pointCount = _measurementPoints.count;
    if (pointCount >= 3) {
        
        AGSMutablePolygon * polygon = [[AGSMutablePolygon alloc] init];
        [polygon addRingToPolygon];
        for (int i = 0; i < pointCount; i++) {
            AGSPoint *point = [_measurementPoints objectAtIndex:i];
            [polygon addPointToRing:point];
        }
        
        AGSSimpleFillSymbol * fillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        fillSymbol.color = [UIColor colorWithRed:255 green:255 blue:0 alpha:0.3];
        fillSymbol.style = AGSSimpleFillSymbolStyleSolid;
        
        AGSSimpleLineSymbol * lineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
        lineSymbol.style = AGSSimpleLineSymbolStyleSolid;
        lineSymbol.width = 2;
        lineSymbol.color = [UIColor blueColor];
        
        fillSymbol.outline = lineSymbol;
        
        AGSGraphic *tmpGraphic = [AGSGraphic graphicWithGeometry:polygon symbol:fillSymbol attributes:nil];
        [_tmpGraphics addObject:tmpGraphic];
        [_drawLayer addGraphic:tmpGraphic];
        
        double area = fabs([geometryEngine areaOfGeometry:polygon]);
        double areaInMu = area * 3.0 / 2000.0;
        if (area > 1000000.0) {
            area = area / 1000000.0f;
            areaDisplay = [NSString stringWithFormat:@"%0.2f平方公里", area];
        }
        else
        {
            areaDisplay = [NSString stringWithFormat:@"%0.2f平方米", area];
        }
        areaDisplay = [NSString stringWithFormat:@"%@, 合%0.2f亩", areaDisplay, areaInMu];
        AGSTextSymbol *txtSymbol = [[AGSTextSymbol alloc] initWithText:areaDisplay color:[UIColor purpleColor]];
        txtSymbol.fontSize = 17.0f;
        txtSymbol.fontFamily = @"Heiti SC";
        AGSGraphic *areaLabel = [AGSGraphic graphicWithGeometry:areaLablePoint symbol:txtSymbol attributes:nil];
        [_tmpGraphics addObject:areaLabel];
        _lastLabelGraphic = areaLabel;
        [_drawLayer addGraphic:areaLabel];
        
    }
}

- (void)stopMeasurement
{
    if (_measurementType == 0) {
        
        if ([_measurementPoints count] >= 2) {
            [_drawLayer removeGraphic:_lastLabelGraphic];
            AGSTextSymbol *symbol = (AGSTextSymbol *)_lastLabelGraphic.symbol;
            AGSTextSymbol *txtSymbol = [[AGSTextSymbol alloc] initWithText:[NSString stringWithFormat:@"全长：%@", symbol.text] color:[UIColor purpleColor]];
            txtSymbol.fontSize = 17.0f;
            txtSymbol.fontFamily = @"Heiti SC";
            AGSGraphic *distanceLabel = [AGSGraphic graphicWithGeometry:_lastLabelGraphic.geometry symbol:txtSymbol attributes:nil];
            [_drawLayer addGraphic:distanceLabel];
        }
    }
    else
    {
        if ([_measurementPoints count] >= 3) {
            [_drawLayer removeGraphic:_lastLabelGraphic];
            AGSTextSymbol *symbol = (AGSTextSymbol *)_lastLabelGraphic.symbol;
            AGSTextSymbol *txtSymbol = [[AGSTextSymbol alloc] initWithText:[NSString stringWithFormat:@"面积：%@", symbol.text] color:[UIColor purpleColor]];
            txtSymbol.fontSize = 17.0f;
            txtSymbol.fontFamily = @"Heiti SC";
            AGSGraphic *areaLabel = [AGSGraphic graphicWithGeometry:_lastLabelGraphic.geometry symbol:txtSymbol attributes:nil];
            [_drawLayer addGraphic:areaLabel];
        }
    }
}

- (void)cleanup
{
    if ([_measurementPoints count] > 0) {
        [_measurementPoints removeAllObjects];
    }
    if ([_tmpGraphics count] > 0) {
        [_tmpGraphics removeAllObjects];
    }
    [_drawLayer removeAllGraphics];
    
    _btnCleanup.frame = CGRectMake(0, 0, 0, 0);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"mapScale"]) {
        double maxScale = _drawLayer.mapView.maxScale;
        double currScale = [[change objectForKey:@"new"] doubleValue];
        double lastScale = [[change objectForKey:@"old"] doubleValue];
        double offset = kLabelOffset * (currScale - lastScale) / maxScale;
        for (AGSGraphic *graphic in [_drawLayer graphics]) {
            if ([graphic.symbol isKindOfClass:[AGSTextSymbol class]]) {
                AGSPoint *point = (AGSPoint *)graphic.geometry;
                AGSPoint *newPoint = [[AGSPoint alloc] initWithX:point.x + offset y:point.y - offset spatialReference:point.spatialReference];
                graphic.geometry = newPoint;
            }
        }
        
        if ([_measurementPoints count] > 0) {
            AGSPoint *lastPoint = [_measurementPoints lastObject];
            AGSMapView *mapView = _drawLayer.mapView;
            CGPoint lastScreenPoint = [mapView toScreenPoint:lastPoint];
            CGPoint btnCleanupOrigPoint = CGPointMake(lastScreenPoint.x - 15.0, lastScreenPoint.y - 40.0);
            
            _btnCleanup.frame = CGRectMake(btnCleanupOrigPoint.x, btnCleanupOrigPoint.y, 30, 30);
        }        
    }
    
    if ([keyPath isEqualToString:@"visibleAreaEnvelope"]) {
        if ([_measurementPoints count] > 0) {
            AGSPoint *lastPoint = [_measurementPoints lastObject];
            AGSMapView *mapView = _drawLayer.mapView;
            CGPoint lastScreenPoint = [mapView toScreenPoint:lastPoint];
            CGPoint btnCleanupOrigPoint = CGPointMake(lastScreenPoint.x - 15.0, lastScreenPoint.y - 40.0);
            
            _btnCleanup.frame = CGRectMake(btnCleanupOrigPoint.x, btnCleanupOrigPoint.y, 30, 30);
        }
    }
}

@end
