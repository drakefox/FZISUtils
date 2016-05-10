//
//  FZISSandboxTool.m
//  FZISUtils
//
//  Created by fzis299 on 16/1/15.
//  Copyright (c) 2016年 FZIS. All rights reserved.
//

#import "FZISSandboxTool.h"

@implementation FZISSandboxTool

@synthesize penColor, penShape, penAlpha, penWidth;
@synthesize imageSaved = _isImageSaved;

- (FZISSandboxTool *)initWithMapView:(FZISMapView *)mapView
{
    self = [super init];
    if (self) {
        _mapView = mapView;
        
        penColor = [UIColor redColor];
        penShape = kShapeFreeLine;
        penAlpha = 1.0;
        penWidth = 2.0;
        
        _sandboxShapePoints = [[NSMutableArray alloc] init];
        _sandboxShapeTypes = [[NSMutableArray alloc] init];
        _sandboxPenColors = [[NSMutableArray alloc] init];;
        _sandboxPenWidths = [[NSMutableArray alloc] init];
        
        _isImageSaved = YES;
    }    
    
    return self;
}

- (void)startDrawing
{
    [self addLineView];
    [self addDrawLayer];
}

- (void)addLineView
{
    if (!_lineView) {
        _lineView = [[FZISLineView alloc] initWithFrame:_mapView.bounds];
    }
    _lineView.penColor = self.penColor;
    _lineView.penWidth = self.penWidth;
    _lineView.penShape = self.penShape;
    _lineView.lineViewDelegate = self;
    [_mapView addSubview:_lineView];
}

- (void)addDrawLayer
{
    _sandboxLayer = [CALayer layer];
    _sandboxLayer.name = @"SandboxLayer";
    _sandboxLayer.delegate = self;
    _sandboxLayer.frame = _mapView.frame;
    [_mapView.layer addSublayer:_sandboxLayer];
}

#pragma mark - FZISLineView delegate functions

- (void)lineViewTouchesEnded: (FZISLineView *)lineView
{
    _isImageSaved = NO;
    
    if (self.penShape == kShapeFreeLine) {
        AGSMutablePolyline *line = [[AGSMutablePolyline alloc] init];
        [line addPathToPolyline];
        NSMutableArray *points = lineView.points;
        for (int i = 0; i < [points count]; i++)
        {
            NSValue * pointItem = [points objectAtIndex:i];
            CGPoint screenPoint;
            [pointItem getValue:&screenPoint];
            
            AGSPoint *mapPoint = [_mapView toMapPoint:screenPoint];//屏幕坐标转地图坐标
            //NSLog(@"x=%f,y=%f",mapPoint.x,mapPoint.y);
            [line addPointToPath:mapPoint];
        }
        [lineView.points removeAllObjects];
        AGSSimpleLineSymbol *lineSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:self.penColor width:self.penWidth];
        AGSGraphic * drawGraphic= [AGSGraphic graphicWithGeometry:line symbol:lineSymbol attributes:nil];
        [_mapView.sketchLayer addGraphic:drawGraphic];
    }
    else
    {
        [_sandboxLayer setNeedsDisplay];
    }
}

- (void)lineViewTouchesBegan:(FZISLineView *)lineView
{
    _lineView.penColor = self.penColor;
    _lineView.penWidth = self.penWidth;
    _lineView.penShape = self.penShape;
}

#pragma mark - Draw features on the layer

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if ([_lineView.points count] == 0) {
        
        return;
    }
    
    CGPoint startPoint = [_lineView.points.firstObject CGPointValue];
    CGPoint endPoint = [_lineView.points.lastObject CGPointValue];
    
    [_sandboxShapePoints addObject:[NSValue valueWithCGPoint:startPoint]];
    [_sandboxShapePoints addObject:[NSValue valueWithCGPoint:endPoint]];
    [_sandboxShapeTypes addObject:[NSNumber numberWithInteger:self.penShape]];
    [_sandboxPenColors addObject:self.penColor];
    [_sandboxPenWidths addObject:[NSNumber numberWithFloat:self.penWidth]];
    
    UIGraphicsPushContext(ctx);
    for (int i = 0; i < [_sandboxShapePoints count]; i += 2) {
        CGPoint pointF = [[_sandboxShapePoints objectAtIndex:i] CGPointValue];
        CGPoint pointL = [[_sandboxShapePoints objectAtIndex:i + 1] CGPointValue];
        CGRect rectToFill = CGRectMake(pointF.x, pointF.y, pointL.x - pointF.x, pointL.y - pointF.y);
        NSInteger shape = [[_sandboxShapeTypes objectAtIndex:i / 2] integerValue];
        UIColor *tmpPenColor = [_sandboxPenColors objectAtIndex:i / 2];
        float tmpPenWidth = [[_sandboxPenWidths objectAtIndex:i / 2] floatValue];
        
        if (shape == kShapeCircleFill) {
            CGContextSetFillColorWithColor(ctx, tmpPenColor.CGColor);
            CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), rectToFill);
            
        }
        else if (shape == kShapeCircle)
        {
            CGContextSetStrokeColorWithColor(ctx, tmpPenColor.CGColor);
            CGContextSetLineWidth(ctx, tmpPenWidth);
            CGContextStrokeEllipseInRect(UIGraphicsGetCurrentContext(), rectToFill);
        }
        else if (shape == kShapeRectangleFill)
        {
            CGContextSetFillColorWithColor(ctx, tmpPenColor.CGColor);
            CGContextFillRect(UIGraphicsGetCurrentContext(), rectToFill);
        }
        else
        {
            CGContextSetStrokeColorWithColor(ctx, tmpPenColor.CGColor);
            CGContextSetLineWidth(ctx, tmpPenWidth);
            CGContextStrokeRect(UIGraphicsGetCurrentContext(), rectToFill);
        }
    }
    
    [_lineView.points removeAllObjects];
    UIGraphicsPopContext();
    return;
}


- (void)cleanup
{
    [_sandboxShapePoints removeAllObjects];
    [_sandboxShapeTypes removeAllObjects];
    [_sandboxPenColors removeAllObjects];
    [_sandboxPenWidths removeAllObjects];
    [_sandboxLayer setNeedsDisplay];
    [_mapView.sketchLayer removeAllGraphics];
    
    _isImageSaved = YES;
}

- (void)quit
{
    _isImageSaved = YES;
    [_lineView removeFromSuperview];
    [_sandboxLayer removeFromSuperlayer];
}

@end
