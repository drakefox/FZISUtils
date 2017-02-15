//
//  FZISMapView.m
//  FZISUtils
//
//  Created by fzis299 on 16/1/26.
//  Copyright (c) 2016年 FZIS. All rights reserved.
//

#import <OpenGLES/ES1/glext.h>

#import "FZISMapView.h"
#import "GDataXMLNode.h"
#import "ShpHelper.h"
#import "AGSSketchGraphicsLayer+exposePrivate.h"
#import "FZISQueryTool.h"
#import "Utils.h"

@implementation FZISMapView

@synthesize filePath, sketchLayer, mapStatus, isAccurateMeasure;
@synthesize SHPLayers, TILEDLayers, GDBLayers, invisibleLayers;
@synthesize mapServerInfo;
@synthesize nameFieldSettings, keyFieldsSettings, detailFieldsSettings, fieldConvSettings, maxScaleSettings, minScaleSettings, canQuerySettings, isVisibleSettings, layerTree;
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)initMapView
{
    [AGSRuntimeEnvironment setClientID:@"hKE5vax5TL9FSS45" error:nil];
    self.gridSize = 0.0f;
    self.backgroundColor = [UIColor whiteColor];
    self.layerDelegate = self;
    self.filePath = [NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];//设置地图数据存放位置
    [self loadBaseMap];
    [self showDom:NO showDlg:NO animate:NO];
    sketchLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:nil];
    [sketchLayer setAntialias:YES];
    [self addMapLayer:sketchLayer withName:@"SketchLayer"];//顶层草图

//    [self loadGDBLayer:@"热点"];
//    AGSLayer *layerView = [self mapLayerForName:@"热点"];
//    layerView.opacity = 0.0;
    
//    [self loadGDBLayer:@"开盖报警点"];
//    AGSLayer *layerViewOpenAlarm = [self mapLayerForName:@"开盖报警点"];
//    layerViewOpenAlarm.opacity = 0.0;

    
    self.callout.delegate = self;
    self.touchDelegate = self;
    
    UITapGestureRecognizer *tapWithDoubleTouchesGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWithDoubleTouchesReceived:)];
    
    for (UIGestureRecognizer *recgnizer in [self gestureRecognizers]) {
        if ([recgnizer isKindOfClass:[UITapGestureRecognizer class]]) {
            UITapGestureRecognizer *tabgesture = (UITapGestureRecognizer *)recgnizer;
            if (tabgesture.numberOfTouchesRequired == 2) {
                tabgesture.enabled = NO;
            }
        }
        
        if ([recgnizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
            [tapWithDoubleTouchesGestureRecognizer requireGestureRecognizerToFail:recgnizer];
        }
    }
    
    tapWithDoubleTouchesGestureRecognizer.numberOfTapsRequired = 1;
    tapWithDoubleTouchesGestureRecognizer.numberOfTouchesRequired = 2;
    [self addGestureRecognizer:tapWithDoubleTouchesGestureRecognizer];
    
    UITapGestureRecognizer *tapWithSingleTouchGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWithSingleTouchReceived:)];
    tapWithSingleTouchGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapWithSingleTouchGestureRecognizer];
    
    _measurementTool = [[FZISMeasurementTool alloc] initWithDrawLayer:sketchLayer];    
    
    _gpsTool = [[FZISGPSTool alloc] initWithLocationDisplay:self.locationDisplay];
    
    [self addObserver:self forKeyPath:@"mapStatus" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"isAccurateMeasure" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_measurementTool forKeyPath:@"mapScale" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self addObserver:_measurementTool forKeyPath:@"visibleAreaEnvelope" options:NSKeyValueObservingOptionNew context:nil];
    
    SHPLayers = [[NSMutableArray alloc] init];
    TILEDLayers = [[NSMutableArray alloc] init];
    GDBLayers = [[NSMutableArray alloc] init];
    invisibleLayers = [[NSMutableDictionary alloc] init];
    
    mapServerInfo = [Utils mapServerInfo];
    
    [self parseLayerSettings];
    
    for (NSString *layerName in [invisibleLayers allKeys]) {
        [self loadLayer:layerName withType:[[invisibleLayers objectForKey:layerName] integerValue]];
        AGSLayer *layerView = [self mapLayerForName:layerName];
        layerView.opacity = 0.0f;
    }
}

- (void)parseLayerSettings
{
    NSString *basePath = [NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    NSString *configPath = [NSString stringWithFormat:@"%@/LayerConfig.plist", basePath, nil];
    
    layerTree = [[NSDictionary alloc] initWithContentsOfFile:configPath];
    
    nameFieldSettings = [[NSMutableDictionary alloc] init];
    fieldConvSettings = [[NSMutableDictionary alloc] init];
    detailFieldsSettings = [[NSMutableDictionary alloc] init];
    keyFieldsSettings = [[NSMutableDictionary alloc] init];
    maxScaleSettings = [[NSMutableDictionary alloc] init];
    minScaleSettings = [[NSMutableDictionary alloc] init];
    canQuerySettings = [[NSMutableDictionary alloc] init];
    isVisibleSettings = [[NSMutableDictionary alloc] init];
    
    if ([layerTree objectForKey:@"nameField"] != nil && [[layerTree objectForKey:@"nameField"] count] > 0) {
        [nameFieldSettings setValuesForKeysWithDictionary:[layerTree objectForKey:@"nameField"]];
    }
    
    if ([layerTree objectForKey:@"keyFields"] != nil && [[layerTree objectForKey:@"keyFields"] count] > 0) {
        [keyFieldsSettings setValuesForKeysWithDictionary:[layerTree objectForKey:@"keyFields"]];
    }
    
    if ([layerTree objectForKey:@"fieldConv"] != nil && [[layerTree objectForKey:@"fieldConv"] count] > 0) {
        [fieldConvSettings setValuesForKeysWithDictionary:[layerTree objectForKey:@"fieldConv"]];
    }
    
    if ([layerTree objectForKey:@"detailFields"] != nil && [[layerTree objectForKey:@"detailFields"] count] > 0) {
        [detailFieldsSettings setValuesForKeysWithDictionary:[layerTree objectForKey:@"detailFields"]];
    }
    
    if ([layerTree objectForKey:@"maxScale"] != nil) {
        [maxScaleSettings setObject:[layerTree objectForKey:@"maxScale"] forKey:[layerTree objectForKey:@"title"]];
    }
    
    if ([layerTree objectForKey:@"minScale"] != nil) {
        [minScaleSettings setObject:[layerTree objectForKey:@"minScale"] forKey:[layerTree objectForKey:@"title"]];
    }
    
    if ([layerTree objectForKey:@"canQuery"] != nil) {
        [canQuerySettings setObject:[layerTree objectForKey:@"canQuery"] forKey:[layerTree objectForKey:@"title"]];
    }
    
    if ([layerTree objectForKey:@"isVisible"] != nil) {
        [isVisibleSettings setObject:[layerTree objectForKey:@"isVisible"] forKey:[layerTree objectForKey:@"title"]];
    }
    
    for (NSDictionary *layerInfo in [layerTree objectForKey:@"children"]) {
        [self getFieldSettings4Layer:layerInfo];
    }
}

- (void)getFieldSettings4Layer:(NSDictionary *)layerInfo
{
    if ([layerInfo objectForKey:@"nameField"] != nil && [[layerInfo objectForKey:@"nameField"] count] > 0) {
        [nameFieldSettings setValuesForKeysWithDictionary:[layerInfo objectForKey:@"nameField"]];
    }
    
    if ([layerInfo objectForKey:@"keyFields"] != nil && [[layerInfo objectForKey:@"keyFields"] count] > 0) {
        [keyFieldsSettings setValuesForKeysWithDictionary:[layerInfo objectForKey:@"keyFields"]];
    }
    
    if ([layerInfo objectForKey:@"fieldConv"] != nil && [[layerInfo objectForKey:@"fieldConv"] count] > 0) {
        [fieldConvSettings setValuesForKeysWithDictionary:[layerInfo objectForKey:@"fieldConv"]];
    }
    
    if ([layerInfo objectForKey:@"detailFields"] != nil && [[layerInfo objectForKey:@"detailFields"] count] > 0) {
        [detailFieldsSettings setValuesForKeysWithDictionary:[layerInfo objectForKey:@"detailFields"]];
    }
    
    if ([layerInfo objectForKey:@"maxScale"] != nil) {
        [maxScaleSettings setObject:[layerInfo objectForKey:@"maxScale"] forKey:[layerInfo objectForKey:@"title"]];
    }
    
    if ([layerInfo objectForKey:@"minScale"] != nil) {
        [minScaleSettings setObject:[layerInfo objectForKey:@"minScale"] forKey:[layerInfo objectForKey:@"title"]];
    }
    
    if ([layerInfo objectForKey:@"canQuery"] != nil) {
        [canQuerySettings setObject:[layerInfo objectForKey:@"canQuery"] forKey:[layerInfo objectForKey:@"title"]];
    }
    
    if ([layerInfo objectForKey:@"isVisible"] != nil) {
        [isVisibleSettings setObject:[layerInfo objectForKey:@"isVisible"] forKey:[layerInfo objectForKey:@"title"]];
        if ([[layerInfo objectForKey:@"nodeType"] integerValue] == 0 && [[layerInfo objectForKey:@"isVisible"] integerValue] == 0) {
            [invisibleLayers setObject:[layerInfo objectForKey:@"layerType"] forKey:[layerInfo objectForKey:@"title"]];
        }
    }
    
    if ([[layerTree objectForKey:@"children"] count] > 0) {
        for (NSDictionary *subLayerInfo in [layerInfo objectForKey:@"children"]) {
            [self getFieldSettings4Layer:subLayerInfo];
        }
    }
}

- (void)tapWithDoubleTouchesReceived:(UITapGestureRecognizer *)gestureRecognizer
{
    if (mapStatus == kMapMeasureDistance || mapStatus == kMapMeasureArea) {
        [_measurementTool stopMeasurement];
        mapStatus = mapStatus * 100;
    }
    
}


- (void)tapWithSingleTouchReceived:(UITapGestureRecognizer *)gestureRecognizer
{
    AGSPoint *measurePoint;
    AGSPoint *mappoint = [self toMapPoint:[gestureRecognizer locationInView:self]];
    
    if (!isAccurateMeasure) {
        measurePoint = mappoint;
    }
    else
    {
        CGPoint scrCenterPoint = self.center;
        measurePoint = [self toMapPoint:scrCenterPoint];
    }
    
//    self.callout.backgroundColor = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:0.8];
//    self.callout.borderWidth = 0;
//    self.callout.title = @"X";
//    self.callout.titleColor = [UIColor whiteColor];
//    self.callout.
//    [self.callout showCalloutAt:measurePoint screenOffset:CGPointMake(0, 0) animated:YES];
    
    switch (mapStatus) {
        case kMapMeasureDistance: case kMapMeasureArea:
            [_measurementTool updateWithPoint:measurePoint];
            break;
        case kMapMeasureDistance * 100: case kMapMeasureArea * 100:
            mapStatus = mapStatus / 100;
            [_measurementTool cleanup];
            [_measurementTool updateWithPoint:measurePoint];
            break;
        default:
            break;
    }
}

- (void)loadBaseMap
{
    NSString *path4BaseMapConfig = [NSString stringWithFormat:@"%@/BaseMapConfig.xml", self.filePath];
    
    //    NSLog(path4BaseMapConfig, nil);
    
    NSString *xmlString = [[NSString alloc] initWithContentsOfFile:path4BaseMapConfig encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(xmlString, nil);
    
    GDataXMLDocument *xmlDocument = [[GDataXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil];
    
    
    GDataXMLElement *rootElement = [xmlDocument rootElement];
    
    NSArray *arrBaseMapNodes = [rootElement elementsForName:@"geo"];
    
    GDataXMLElement *geoNode = [arrBaseMapNodes objectAtIndex:0];
    
    NSArray *arrayLayerNodes = [geoNode elementsForName:@"layer"];
    //    NSLog(@"%lu", (unsigned long)[arrayLayerNodes count],nil);
    
    for (GDataXMLElement *node in arrayLayerNodes) {
        NSString *layerName = [[node attributeForName:@"layerName"] stringValue];
        NSString *tpkFilePath = [NSString stringWithFormat:@"%@/%@", self.filePath, [[node attributeForName:@"fileName"] stringValue]];
        //        NSLog(@"%@", tpkFilePath);
        AGSLocalTiledLayer *tiledLayer = [AGSLocalTiledLayer localTiledLayerWithPath:tpkFilePath];
        if (tiledLayer != nil) {
            [self addMapLayer:tiledLayer withName:layerName];
            _baseLayerCount++;
        }
    }
    
}

- (GDataXMLDocument *)mapConfigDocument
{
    NSString *path4MapConfig = [NSString stringWithFormat:@"%@/MapConfig.xml", self.filePath];
    NSString *xmlString = [[NSString alloc] initWithContentsOfFile:path4MapConfig encoding:NSUTF8StringEncoding error:nil];
    GDataXMLDocument *xmlDocument = [[GDataXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil];
    return xmlDocument;
}

- (GDataXMLElement *)layerElement:(NSString *)layerName
{
    GDataXMLDocument *mapConfigDoc = [self mapConfigDocument];
    GDataXMLElement *rootElement = [mapConfigDoc rootElement];
    GDataXMLElement *layerElement;
    NSArray *grpNodes = [rootElement elementsForName:@"group"];
    //    NSLog(@"%lu", (unsigned long)[arrGrpNodes count], nil);
    for (GDataXMLElement *grpNode in grpNodes) {
        NSArray *layerNodes = [grpNode elementsForName:@"layer"];
        //        NSLog(@"%lu", (unsigned long)[arrLayerNodes count], nil);
        for (GDataXMLElement *layerNode in layerNodes) {
            NSString *cfgLayerName = [[layerNode attributeForName:@"layerName"] stringValue];
            if ([layerName isEqualToString:cfgLayerName]) {
                layerElement = [[GDataXMLElement alloc] initWithXMLString:[layerNode XMLString] error:nil];
                //                NSLog([layerNode XMLString], nil);
                return layerElement;
            }
        }
    }
    return nil;
}

- (void)loadLayer:(NSString *)layerName
{
    //    GDataXMLElement *layerNode = [self layerElement:layerName];
    //    if (layerNode == nil) {
    //        return;
    //    }
    //
    //    NSString *fileName = [[layerNode attributeForName:@"fileName"] stringValue];
    //
    //    GDataXMLElement *minScaleNode = [[layerNode elementsForName:@"minScale"] objectAtIndex:0];
    //    GDataXMLElement *maxScaleNode = [[layerNode elementsForName:@"maxScale"] objectAtIndex:0];
    //
    //    GDataXMLElement *rendererNode = [[layerNode elementsForName:@"renderer"] objectAtIndex:0];
    //
    //    AGSRenderer *renderer = [self getRenderFromXMLNode:rendererNode];
    //
    //    double minScale = [[minScaleNode stringValue] doubleValue];
    //    double maxScale = [[maxScaleNode stringValue] doubleValue];
    //
    //    NSLog(@"%f:%f", minScale, maxScale, nil);
    //
    //
    //    NSString *path4ShpFiles = [NSString stringWithFormat:@"%@/Data", self.filePath];
    //
    //    NSMutableArray * data = shp2AGSGraphics(path4ShpFiles, fileName);
    //
    //    AGSGraphicsLayer *layer = [AGSGraphicsLayer graphicsLayer];
    //    if (minScale > 0.0f) {
    //        layer.minScale = minScale;
    //    }
    //    if (maxScale > 0.0f) {
    //        layer.maxScale = maxScale;
    //    }
    //
    //    [self addMapLayer:layer withName:layerName];
    //    layer.renderer = renderer;
    //
    //    [layer addGraphics:data];
}

- (void)loadSHPLayer:(NSString *)layerName
{
    GDataXMLElement *layerNode = [self layerElement:layerName];
    if (layerNode == nil) {
        return;
    }
    
    NSString *fileName = [[layerNode attributeForName:@"fileName"] stringValue];
    
//    GDataXMLElement *minScaleNode = [[layerNode elementsForName:@"minScale"] objectAtIndex:0];
//    GDataXMLElement *maxScaleNode = [[layerNode elementsForName:@"maxScale"] objectAtIndex:0];
    
    GDataXMLElement *rendererNode = [[layerNode elementsForName:@"renderer"] objectAtIndex:0];
    
    AGSRenderer *renderer = [self getRenderFromXMLNode:rendererNode];
    
//    double minScale = [[minScaleNode stringValue] doubleValue];
//    double maxScale = [[maxScaleNode stringValue] doubleValue];
    
//    NSLog(@"%f:%f", minScale, maxScale, nil);
    
    
    NSString *path4ShpFiles = [NSString stringWithFormat:@"%@/SHPLayer", self.filePath];
    
    NSMutableArray * data = shp2AGSGraphics(path4ShpFiles, fileName);
    
    AGSGraphicsLayer *layer = [AGSGraphicsLayer graphicsLayer];
    
    double minScale;
    double maxScale;
    if ([maxScaleSettings objectForKey:layerName] != nil) {
        maxScale = [[maxScaleSettings objectForKey:layerName] doubleValue];
        layer.maxScale = maxScale;
    }
    
    if ([minScaleSettings objectForKey:layerName] != nil) {
        minScale = [[minScaleSettings objectForKey:layerName] doubleValue];
        layer.minScale = minScale;
    }
    
//    if (minScale > 0.0f) {
//        layer.minScale = minScale;
//    }
//    if (maxScale > 0.0f) {
//        layer.maxScale = maxScale;
//    }
    
//    [self addMapLayer:layer withName:layerName];
    [self insertMapLayer:layer withName:layerName atIndex:_baseLayerCount];
    layer.renderer = renderer;
    
    [layer addGraphics:data];
}

- (void)loadTILEDLayer:(NSString *)layerName
{
    NSString *tpkFilePath = [NSString stringWithFormat:@"%@/TiledLayer/%@.tpk", self.filePath, layerName];
    //        NSLog(@"%@", tpkFilePath);
    AGSLocalTiledLayer *tiledLayer = [AGSLocalTiledLayer localTiledLayerWithPath:tpkFilePath];
    
    double minScale;
    double maxScale;
    if ([maxScaleSettings objectForKey:layerName] != nil) {
        maxScale = [[maxScaleSettings objectForKey:layerName] doubleValue];
        tiledLayer.maxScale = maxScale;
    }
    
    if ([minScaleSettings objectForKey:layerName] != nil) {
        minScale = [[minScaleSettings objectForKey:layerName] doubleValue];
        tiledLayer.minScale = minScale;
    }
    
    if (tiledLayer != nil) {
//        [self addMapLayer:tiledLayer withName:layerName];
        [self insertMapLayer:tiledLayer withName:layerName atIndex:_baseLayerCount];
    }
}

- (void)loadGDBLayer:(NSString *)layerName
{
    AGSGDBGeodatabase *geoDatabase = [AGSGDBGeodatabase geodatabaseWithPath:[NSString stringWithFormat:@"%@/GDBLayer/GDBLayers.geodatabase", self.filePath] error:nil];
    AGSGDBFeatureTable *gdbTable = [geoDatabase featureTableForLayerName:layerName];
    AGSFeatureTableLayer *flayer = [[AGSFeatureTableLayer alloc] initWithFeatureTable:gdbTable];
    
    double maxScale;
    double minScale;
    
    if ([maxScaleSettings objectForKey:layerName] != nil) {
        maxScale = [[maxScaleSettings objectForKey:layerName] doubleValue];
        flayer.maxScale = maxScale;
    }
    
    if ([minScaleSettings objectForKey:layerName] != nil) {
        minScale = [[minScaleSettings objectForKey:layerName] doubleValue];
        flayer.minScale = minScale;
    }
    
//    [self addMapLayer:flayer withName:layerName];
    [self insertMapLayer:flayer withName:layerName atIndex:_baseLayerCount];
}

- (AGSRenderer *)getRenderFromXMLNode:(GDataXMLElement *)rendererNode
{
    NSString *rendererType = [[rendererNode attributeForName:@"type"] stringValue];
    
    AGSSimpleRenderer *simpleRenderer;
    AGSUniqueValueRenderer *uniqueValueRenderer;
    //    AGSClassBreaksRenderer *classBreaksRenderer;
    
    
    if ([rendererType isEqualToString:@"SimpleRenderer"]) {
        AGSCompositeSymbol *compositeSymbol = [[AGSCompositeSymbol alloc] init];
        
        NSArray *symbolNodes = [rendererNode elementsForName:@"symbol"];
        //        NSLog(@"1");
        for (GDataXMLElement *symbolNode in symbolNodes) {
            AGSSymbol *symbol = [self getSymbolFromXMLNode:symbolNode];
            if (symbol == nil) {
                return nil;
            }
            [compositeSymbol addSymbol:symbol];
        }
        simpleRenderer  = [[AGSSimpleRenderer alloc] initWithSymbol:compositeSymbol];
        return simpleRenderer;
    }
    else if ([rendererType isEqualToString:@"UniqueValueRenderer"]) {
        NSString *field1 = [[rendererNode attributeForName:@"field1"] stringValue];
        //        NSLog(field1, nil);
        //        NSString *field2 = [[rendererNode attributeForName:@"field2"] stringValue];
        //        NSString *field3 = [[rendererNode attributeForName:@"field3"] stringValue];
        
        uniqueValueRenderer = [[AGSUniqueValueRenderer alloc] init];
        NSArray *symbolNodes = [rendererNode elementsForName:@"symbol"];
        NSMutableArray *uniqueValues = [[NSMutableArray alloc] init];
        //        NSLog(@"1");
        for (GDataXMLElement *symbolNode in symbolNodes) {
            NSString *uniqueValue = [[symbolNode attributeForName:@"uniqueValue"] stringValue];
            NSString *label = [[symbolNode attributeForName:@"label"] stringValue];
            NSString *description = [[symbolNode attributeForName:@"description"] stringValue];
            
            AGSSymbol *symbol = [self getSymbolFromXMLNode:symbolNode];
            if (symbol == nil) {
                return nil;
            }
            if ([uniqueValue isEqualToString:@"defaultSymbol"]) {
                uniqueValueRenderer.defaultLabel = label;
                uniqueValueRenderer.defaultSymbol = symbol;
            }
            else
            {
                AGSUniqueValue *uniqueValueObj = [[AGSUniqueValue alloc] initWithValue:uniqueValue label:label description:description symbol:symbol];
                [uniqueValues addObject:uniqueValueObj];
            }
        }
        uniqueValueRenderer.fields = @[field1];
        uniqueValueRenderer.uniqueValues = uniqueValues;
        //        NSLog(@"===============");
        //        NSLog(@"%lu", (unsigned long)[uniqueValueRenderer.uniqueValues count], nil);
        return uniqueValueRenderer;
    }
    else {
        return nil;
    }
    
}

- (void)loadLayer:(NSString *)layerName withType:(NSInteger)layerType
{
    switch (layerType) {
        case kLayerTypeSHP:
            [self loadSHPLayer:layerName];
            if ([[canQuerySettings objectForKey:layerName] integerValue] == 1)
            {
                [SHPLayers addObject:layerName];
            }
            break;
        case kLayerTypeTILED:
            [self loadTILEDLayer:layerName];
            if ([[canQuerySettings objectForKey:layerName] integerValue] == 1)
            {
                [TILEDLayers addObject:layerName];
            }
            break;
        case kLayerTypeGDB:
            [self loadGDBLayer:layerName];
            if ([[canQuerySettings objectForKey:layerName] integerValue] == 1)
            {
                [GDBLayers addObject:layerName];
            }
            break;
        default:
            break;
    }
}

- (AGSSymbol *)getSymbolFromXMLNode:(GDataXMLElement *)symbolNode
{
    NSString *symbolType = [[symbolNode attributeForName:@"type"] stringValue];
    
    NSString *symbolStyle = [[[symbolNode elementsForName:@"style"] objectAtIndex:0] stringValue];
    NSString *symbolColor = [[[symbolNode elementsForName:@"color"] objectAtIndex:0] stringValue];
    NSInteger symbolWidth = 0;
    //    NSLog(@"2");
    AGSSimpleLineSymbol *outline = nil;
    
    if ([[symbolNode elementsForName:@"width"] count] > 0) {
        symbolWidth = [[[[symbolNode elementsForName:@"width"] objectAtIndex:0] stringValue] integerValue];
    }
    
    if ([[symbolNode elementsForName:@"outline"] count] > 0) {
        GDataXMLElement *outlineNode = [[symbolNode elementsForName:@"outline"] objectAtIndex:0];
        GDataXMLElement *outlineSymbolNode = [[outlineNode elementsForName:@"symbol"] objectAtIndex:0];
        outline = (AGSSimpleLineSymbol *)[self getSymbolFromXMLNode:outlineSymbolNode];
    }
    
    AGSSimpleMarkerSymbol *simpleMarkerSymbol;
    AGSSimpleLineSymbol *simpleLineSymbol;
    AGSSimpleFillSymbol *simpleFillSymbol;
    //    AGSPictureMarkerSymbol *pictureMarkerSymbol;
    //    AGSPictureFillSymbol *pictureFillSymbol;
    //    NSLog(symbolType, nil);
    if ([symbolType isEqualToString:@"SimpleMarkerSymbol"]) {
        simpleMarkerSymbol = [[AGSSimpleMarkerSymbol alloc] init];
        if ([symbolStyle isEqualToString:@"SimpleMarkerSymbolStyleCircle"]) {
            simpleMarkerSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
        }
        else if ([symbolStyle isEqualToString:@"SimpleMarkerSymbolStyleCross"]){
            simpleMarkerSymbol.style = AGSSimpleMarkerSymbolStyleCross;
        }
        else if ([symbolStyle isEqualToString:@"SimpleMarkerSymbolStyleDiamond"]){
            simpleMarkerSymbol.style = AGSSimpleMarkerSymbolStyleDiamond;
        }
        else if ([symbolStyle isEqualToString:@"SimpleMarkerSymbolStyleSquare"]){
            simpleMarkerSymbol.style = AGSSimpleMarkerSymbolStyleSquare;
        }
        else if ([symbolStyle isEqualToString:@"SimpleMarkerSymbolStyleTriangle"]){
            simpleMarkerSymbol.style = AGSSimpleMarkerSymbolStyleTriangle;
        }
        else if ([symbolStyle isEqualToString:@"SimpleMarkerSymbolStyleX"]){
            simpleMarkerSymbol.style = AGSSimpleMarkerSymbolStyleX;
        }
        else {
            return nil;
        }
        //        NSLog(@"3");
        simpleMarkerSymbol.color = [self getColorFromString:symbolColor];
        if (outline != nil) {
            simpleMarkerSymbol.outline = outline;
        }
        return simpleMarkerSymbol;
    }
    else if ([symbolType isEqualToString:@"SimpleLineSymbol"])
    {
        simpleLineSymbol = [[AGSSimpleLineSymbol alloc] init];
        if ([symbolStyle isEqualToString:@"SimpleLineSymbolStyleDash"]) {
            simpleLineSymbol.style = AGSSimpleLineSymbolStyleDash;
        }
        else if ([symbolStyle isEqualToString:@"SimpleLineSymbolStyleDashDot"]){
            simpleLineSymbol.style = AGSSimpleLineSymbolStyleDashDot;
        }
        else if ([symbolStyle isEqualToString:@"SimpleLineSymbolStyleDashDotDot"]){
            simpleLineSymbol.style = AGSSimpleLineSymbolStyleDashDotDot;
        }
        else if ([symbolStyle isEqualToString:@"SimpleLineSymbolStyleDot"]){
            simpleLineSymbol.style = AGSSimpleLineSymbolStyleDot;
        }
        else if ([symbolStyle isEqualToString:@"SimpleLineSymbolStyleInsideFrame"]){
            simpleLineSymbol.style = AGSSimpleLineSymbolStyleInsideFrame;
        }
        else if ([symbolStyle isEqualToString:@"SimpleLineSymbolStyleNull"]){
            simpleLineSymbol.style = AGSSimpleLineSymbolStyleNull;
        }
        else if ([symbolStyle isEqualToString:@"SimpleLineSymbolStyleSolid"]){
            simpleLineSymbol.style = AGSSimpleLineSymbolStyleSolid;
        }
        else {
            return nil;
        }
        simpleLineSymbol.color = [self getColorFromString:symbolColor];
        if (symbolWidth > 0) {
            simpleLineSymbol.width = symbolWidth;
        }
        return simpleLineSymbol;
    }
    else if ([symbolType isEqualToString:@"SimpleFillSymbol"])
    {
        simpleFillSymbol = [[AGSSimpleFillSymbol alloc] init];
        if ([symbolStyle isEqualToString:@"SimpleFillSymbolStyleBackwardDiagonal"]) {
            simpleFillSymbol.style = AGSSimpleFillSymbolStyleBackwardDiagonal;
        }
        else if ([symbolStyle isEqualToString:@"SimpleFillSymbolStyleCross"]){
            simpleFillSymbol.style = AGSSimpleFillSymbolStyleCross;
        }
        else if ([symbolStyle isEqualToString:@"SimpleFillSymbolStyleDiagonalCross"]){
            simpleFillSymbol.style = AGSSimpleFillSymbolStyleDiagonalCross;
        }
        else if ([symbolStyle isEqualToString:@"SimpleFillSymbolStyleForwardDiagonal"]){
            simpleFillSymbol.style = AGSSimpleFillSymbolStyleForwardDiagonal;
        }
        else if ([symbolStyle isEqualToString:@"SimpleFillSymbolStyleHorizontal"]){
            simpleFillSymbol.style = AGSSimpleFillSymbolStyleHorizontal;
        }
        else if ([symbolStyle isEqualToString:@"SimpleFillSymbolStyleNull"]){
            simpleFillSymbol.style = AGSSimpleFillSymbolStyleNull;
        }
        else if ([symbolStyle isEqualToString:@"SimpleFillSymbolStyleSolid"]){
            simpleFillSymbol.style = AGSSimpleFillSymbolStyleSolid;
        }
        else if ([symbolStyle isEqualToString:@"SimpleFillSymbolStyleVertical"]){
            simpleFillSymbol.style = AGSSimpleFillSymbolStyleVertical;
        }
        else {
            return nil;
        }
        simpleFillSymbol.color = [self getColorFromString:symbolColor];
        if (outline != nil) {
            simpleFillSymbol.outline = outline;
        }
        return simpleFillSymbol;
    }
    else
    {
        return nil;
    }
    
}

- (UIColor *)getColorFromString:(NSString *)colorString
{
    NSMutableArray *components = [[colorString componentsSeparatedByString:@","] mutableCopy];
    if ([components count] == 3) {
        [components addObject:@"1"];
    }
    UIColor *color = [[UIColor alloc] initWithRed:[[components objectAtIndex:0] floatValue] / 255.0f  green:[[components objectAtIndex:1] floatValue] / 255.0f blue:[[components objectAtIndex:2] floatValue] / 255.0f alpha:[[components objectAtIndex:3] floatValue]];
    return color;
}


- (void)showDom:(BOOL)showDom showDlg:(BOOL)showDlg animate:(BOOL)animate
{
    AGSLayer *layerViewDom = [self mapLayerForName:@"dom"];
    AGSLayer *layerViewDlg = [self mapLayerForName:@"dlg"];
    AGSLayer *layerViewDt = [self mapLayerForName:@"dt"];
    
    if (showDom) {
        layerViewDlg.opacity = 0.0;
        layerViewDt.opacity = 0.0;
        if (animate) {
            [UIView animateWithDuration:1.0 animations:^{
                [layerViewDom setOpacity:1.0];
            } completion:^(BOOL finished) {
            }];
        }
        else
        {
            layerViewDom.opacity = 1.0;
        }
        
    }
    else if (showDlg)
    {
        layerViewDom.opacity = 0.0;
        layerViewDt.opacity = 0.0;
        if (animate) {
            [UIView animateWithDuration:1.0 animations:^{
                [layerViewDlg setOpacity:1.0];
            } completion:^(BOOL finished) {
            }];
        }
        else
        {
            layerViewDlg.opacity = 1.0;
        }
    }
    else if (!showDlg && !showDom)
    {
        layerViewDlg.opacity = 0.0;
        layerViewDom.opacity = 0.0;
        if (animate) {
            [UIView animateWithDuration:1.0 animations:^{
                [layerViewDt setOpacity:1.0];
            } completion:^(BOOL finished) {
            }];
        }
        else
        {
            layerViewDt.opacity = 1.0;
        }
    }
//    NSLog(@"%f, %f, %f", layerViewDom.opacity, layerViewDlg.opacity, layerViewDt.opacity);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"mapStatus"]) {
        NSInteger status = [[change objectForKey:@"new"] integerValue];
        
        switch (status) {
            case kMapMeasureDistance:
                [_measurementTool startDistanceMeasurement];
                break;
            case kMapMeasureArea:
                [_measurementTool startAreaMeasurement];
                break;
            default:
                [_measurementTool cleanup];
                break;
        }
    }
    if ([keyPath isEqualToString:@"isAccurateMeasure"]) {
        
        if (isAccurateMeasure) {
            [self drawCrossMark];
        }
        else
        {
            [self clearCrossMark];
        }
    }
}

- (void)drawCrossMark
{
    CALayer *crossMarkLayer = [CALayer layer];
    crossMarkLayer.name = @"CrossMarkLayer";
    crossMarkLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    crossMarkLayer.delegate = self;
    [self.layer addSublayer:crossMarkLayer];
    [crossMarkLayer setNeedsDisplay];
}

- (void)clearCrossMark
{
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.name isEqualToString:@"CrossMarkLayer"]) {
            [layer removeFromSuperlayer];
        }
    }
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if ([layer.name isEqualToString:@"CrossMarkLayer"]) {
        UIGraphicsPushContext(ctx);
        CGContextSetLineWidth(ctx, 2.0);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetRGBStrokeColor(ctx, 0.0, 0.8, 0.8, 1.0);
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, 400.0, layer.frame.size.height / 2.0);
        CGContextAddLineToPoint(ctx, layer.frame.size.width - 400.0, layer.frame.size.height / 2.0);
        CGContextStrokePath(ctx);
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, layer.frame.size.width / 2.0, 300.0);
        CGContextAddLineToPoint(ctx, layer.frame.size.width / 2.0, layer.frame.size.height - 300.0);
        CGContextStrokePath(ctx);
        CGRect rectangle = CGRectMake(layer.frame.size.width / 2.0 - 50.0, layer.frame.size.height / 2.0 - 50.0, 100.0, 100.0);
        CGContextAddEllipseInRect(ctx, rectangle);
        CGContextStrokePath(ctx);
        UIGraphicsPopContext();
        return;
    }
}

- (void)removeMapLayerWithName2:(NSString *)layerName
{
    [self removeMapLayerWithName:layerName];
}

- (void)removeMapLayerWithLayerName:(NSString *)layerName
{
    [self removeMapLayerWithName:layerName];
    if ([SHPLayers containsObject:layerName]) {
        [SHPLayers removeObject:layerName];
    }
    else if ([TILEDLayers containsObject:layerName])
    {
        [TILEDLayers removeObject:layerName];
    }
    else
    {
        [GDBLayers removeObject:layerName];
    }
}

- (UIImage *)saveMapImage
{
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imageCALayer = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *imageOpenGLLayer = [self snapshot:self];
    
    UIImage *image = [self addTwoImageToOne:imageOpenGLLayer twoImage:imageCALayer];
    
    return image;
}

- (void)startLocationDisplay
{
    [_gpsTool startLocationDisplay];
}

- (void)stopLocationDisplay
{
    double angle = self.rotationAngle;
    
    if (angle != 0) {
        [self setRotationAngle:0 animated:YES];
    }
    
    [_gpsTool stopLocationDisplay];
}


- (void)changeOpacityForLayer:(NSString *)layerName toValue:(float)opacity
{
    AGSLayer *layer = [self mapLayerForName:layerName];
    layer.opacity = opacity;
}

- (void)showCustomizedCallout:(UIViewController *)viewController forFeature:(id)feature withInfo:(NSDictionary *)info
{
    AGSPoint *center = [[[feature geometry] envelope] center];
    
    AGSGeometryType geometryType = AGSGeometryTypeForGeometry([feature geometry]);
    AGSGraphic *tmpGraphic = [[AGSGraphic alloc] init];
    tmpGraphic.geometry = [feature geometry];
    
    if (geometryType == AGSGeometryTypePoint) {
        AGSSimpleMarkerSymbol *symbol = [[AGSSimpleMarkerSymbol alloc] init];
        symbol.style = AGSSimpleMarkerSymbolStyleCircle;
        //symbol.color = [UIColor greenColor];
        symbol.color = [UIColor colorWithRed:74.0/255.0 green:185.0/255.0 blue:189.0/255.0 alpha:1];
        symbol.outline = [[AGSSimpleLineSymbol alloc] init];
        symbol.outline.color = [UIColor blueColor];
        tmpGraphic.symbol = symbol;
    }
    else if (geometryType == AGSGeometryTypePolyline)
    {
        AGSSimpleLineSymbol *symbol = [[AGSSimpleLineSymbol alloc] init];
        symbol.style = AGSSimpleLineSymbolStyleSolid;
        symbol.width = 5.0f;
        //symbol.color = [UIColor greenColor];
        symbol.color = [UIColor colorWithRed:74.0/255.0 green:185.0/255.0 blue:189.0/255.0 alpha:1];
        tmpGraphic.symbol = symbol;
    }
    else if (geometryType == AGSGeometryTypePolygon)
    {
        AGSSimpleLineSymbol *lineSymbol = [[AGSSimpleLineSymbol alloc] init];
        lineSymbol.style = AGSSimpleLineSymbolStyleSolid;
        lineSymbol.width = 2.0f;
        lineSymbol.color = [UIColor redColor];
        
        AGSSimpleFillSymbol *symbol = [[AGSSimpleFillSymbol alloc] init];
        symbol.style = AGSSimpleFillSymbolStyleCross;
        //symbol.color = [UIColor greenColor];
        symbol.color = [UIColor colorWithRed:74.0/255.0 green:185.0/255.0 blue:189.0/255.0 alpha:1];
        symbol.outline = lineSymbol;
        tmpGraphic.symbol = symbol;
    }
    
    [sketchLayer removeAllGraphics];
    [sketchLayer addGraphic:tmpGraphic];
    
    self.callout.customView = viewController.view;
    self.callout.backgroundColor = [UIColor clearColor];
    self.callout.alpha = 0.8;
    [self.callout showCalloutAt:center screenOffset:CGPointMake(0, 0) animated:YES];
    [self centerAtPoint:center animated:YES];
}


- (void)removeObservers
{
    [self removeObserver:self forKeyPath:@"mapStatus"];
    [self removeObserver:self forKeyPath:@"isAccurateMeasure"];
    [self removeObserver:_measurementTool forKeyPath:@"mapScale"];
    [self removeObserver:_measurementTool forKeyPath:@"visibleAreaEnvelope"];
}

- (UIImage*)snapshot:(UIView*)eaglview
{
    GLint backingWidth, backingHeight;
    
    // Bind the color renderbuffer used to render the OpenGL ES view
    
    // If your application only creates a single color renderbuffer which is already bound at this point,
    
    // this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
    
    // Note, replace viewRenderbuffer with the actual name of the renderbuffer object defined in your class.
    
    //    glBindRenderbufferOES(GL_RENDERBUFFER_OES, );
    
    // Get the size of the backing CAEAGLLayer
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
    
    NSInteger dataLength = width * height * 4;
    
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    
    // Create a CGImage with the pixel data
    
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    
    // otherwise, use kCGImageAlphaPremultipliedLast
    
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    
    // OpenGL ES measures data in PIXELS
    
    // Create a graphics context with the target size measured in POINTS
    
    NSInteger widthInPoints, heightInPoints;
    
    CGFloat scale = eaglview.contentScaleFactor;
    
    widthInPoints = width / scale;
    
    heightInPoints = height / scale;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
    
//        if (NULL != UIGraphicsBeginImageContextWithOptions) {
//    
//            // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
//    
//            // Set the scale parameter to your OpenGL ES view's contentScaleFactor
//    
//            // so that you get a high-resolution snapshot when its value is greater than 1.0
//    
//            CGFloat scale = eaglview.contentScaleFactor;
//    
//            widthInPoints = width / scale;
//    
//            heightInPoints = height / scale;
//    
//            UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
//    
//        }
//    
//        else {
//    
//            // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
//    
//            widthInPoints = width;
//    
//            heightInPoints = height;
//    
//            UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
//    
//        }
    
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    
    // Flip the CGImage by rendering it to the flipped bitmap context
    
    // The size of the destination area is measured in POINTS
    
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    
    
    // Retrieve the UIImage from the current context
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    UIGraphicsEndImageContext();
    
    // Clean up
    
    free(data);
    
    CFRelease(ref);
    
    CFRelease(colorspace);
    
    CGImageRelease(iref);
    
    return image;
}

- (UIImage *)addTwoImageToOne:(UIImage *)oneImg twoImage:(UIImage *)twoImg
{
    UIGraphicsBeginImageContext(oneImg.size);
    
    [oneImg drawInRect:CGRectMake(0, 0, oneImg.size.width, oneImg.size.height)];
    [twoImg drawInRect:CGRectMake(0, 0, twoImg.size.width, twoImg.size.height)];
    
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImg;
}

@end
