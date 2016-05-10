//
//  RequestPreprocessor.h
//  FZISMap
//
//  Created by fzis299 on 13-7-25.
//  Copyright (c) 2013年 FZIS. All rights reserved.
//

//common url identifications
//#define kShowLeftPanle      @"AD_MAP://m=showLeftPanel"
//#define kShowWebViewWin     @"AD_MAP://m=showWebViewWin"
//#define kShowModalWin       @"AD_MAP://m=showModalWin"
#define kGetQueryParam      @"AD_MAP://m=queryParamReady"

//url identifications from main map view
#define kTakeLocation       @"AD_MAP://m=takeLocation"
#define kDrawPicture        @"AD_MAP://m=drawPicture"
#define kPhotoShoot         @"AD_MAP://m=photoShoot"
#define kPhotoView          @"AD_MAP://m=photoView"
#define kScreenShoot        @"AD_MAP://m=screenShoot"
#define kShow360demo        @"AD_MAP://m=show360demo"
#define kFileModify         @"AD_MAP://m=fileModify"
#define kClearStatus        @"AD_MAP://m=clearStatus"
#define kCheckUpdate        @"AD_MAP://m=checkUpdate"
#define kSaveFeature        @"AD_MAP://m=saveFeature"

//url identifications from left panel view
//#define kLeftPanelReady     @"AD_MAP://m=leftPanelReady"
#define kSubjectLoc         @"AD_MAP://m=subjectLoc"
#define kFastLoc            @"AD_MAP://m=fastLoc"
#define kMarkMap            @"AD_MAP://m=markMap"
#define kAddLayer           @"AD_MAP://m=addLayer"
#define kShowPopDlg         @"AD_MAP://m=showPopDialog"
#define kSaveStatus         @"AD_MAP://m=saveStatus"
#define kPlotting           @"AD_MAP://m=plotting"
#define kDelFeature         @"AD_MAP://m=delFeature"

//url identifications from web view win
#define kContrastPageReady  @"AD_MAP://m=contrastPageReady"
#define kCloseHomePage      @"AD_MAP://m=closeHomePage"
#define kOpenAnualBook      @"AD_MAP://m=openAnualBook"
#define kCloseContrastpage  @"AD_MAP://m=closeContrastPage"

//url identifications from modal view win
#define kModalViewReady     @"AD_MAP://m=modalWinReady"

//restruct the logic
#define kOpenView           @"AD_MAP://m=openView"
#define kPageReady          @"AD_MAP://m=pageReady"
#define kRunJS              @"AD_MAP://m=runJS"
#define kCloseView          @"AD_MAP://m=closeView"

//typedef NS_ENUM(NSInteger, RequestOprationType) {
//    RequestOprationTypeTakeLocation,
//    RequestOprationTypeDrawPicture,
//    RequestOprationTypePhotoShoot,
//    RequestOprationTypePhotoView,
//    RequestOprationTypeShow360demo,
//    RequestOprationTypeShowWebViewWin,
//    RequestOprationTypeShowModalWin,
//    RequestOprationTypeFileModify,
//    RequestOprationTypeShowLeftPanle
//};

#import <Foundation/Foundation.h>

@interface RequestPreprocessor : NSObject


@property (nonatomic, assign) BOOL shouldLoad;
@property (nonatomic, retain) NSString *notificationType;
@property (nonatomic, retain) NSString *getParamFuncName;

- (RequestPreprocessor *)initWithRequest:(NSURLRequest *)request;

@end
