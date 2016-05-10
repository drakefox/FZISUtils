//
//  RequestPreprocessor.m
//  FZISMap
//
//  Created by fzis299 on 13-7-25.
//  Copyright (c) 2013年 FZIS. All rights reserved.
//

#import "RequestPreprocessor.h"

@implementation RequestPreprocessor

@synthesize shouldLoad;
@synthesize notificationType;

- (RequestPreprocessor *)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    if (self) {
        NSString* requestString = [[request URL] absoluteString];
        //link the urls and the notifications from main map view
        if ([requestString rangeOfString:kTakeLocation].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"TakeLocationNotification";            
        }
        else if ([requestString rangeOfString:kDrawPicture].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"DrawPictureNotification";
        }
        else if ([requestString rangeOfString:kPhotoShoot].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"PhotoShootNotification";
        }
        else if ([requestString rangeOfString:kPhotoView].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"PhotoViewNotification";
        }
        else if ([requestString rangeOfString:kScreenShoot].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"ScreenShootNotification";
        }
        else if ([requestString rangeOfString:kShow360demo].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"Show360demoNotification";
        }
        else if ([requestString rangeOfString:kFileModify].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"FileModifyNotification";
        }
        else if ([requestString rangeOfString:kClearStatus].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"ClearStatusNotification";
        }
        else if ([requestString rangeOfString:kCheckUpdate].length > 0)
        {
            self.shouldLoad = YES;
            self.notificationType = @"CheckUpdateNotification";
        }
        else if ([requestString rangeOfString:kSaveFeature].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"SaveFeatureNotification";
        }
        //link the urls and the notifications from left panel view
        else if ([requestString rangeOfString:kPageReady].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"PageReadyNotification";
        }
        else if ([requestString rangeOfString:kRunJS].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"RunJSNotification";
        }
        else if ([requestString rangeOfString:kSubjectLoc].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"RunJSOnMapNotification";
        }
        else if ([requestString rangeOfString:kFastLoc].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"RunJSOnMapNotification";
        }
        else if ([requestString rangeOfString:kMarkMap].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"RunJSOnMapNotification";
        }
        else if ([requestString rangeOfString:kAddLayer].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"RunJSOnMapNotification";
        }
        else if ([requestString rangeOfString:kShowPopDlg].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"RunJSOnMapNotification";
        }
        else if ([requestString rangeOfString:kPlotting].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"RunJSOnMapNotification";
        }
        else if ([requestString rangeOfString:kSaveStatus].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"SaveStatusNotification";
        }
        else if ([requestString rangeOfString:kDelFeature].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"DelFeatureNotification";
        }
        //link the urls and the notifications from web view win
        else if ([requestString rangeOfString:kContrastPageReady].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"ContrastPageReadyNotification";
        }
        else if ([requestString rangeOfString:kCloseContrastpage].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"CloseContrastPageNotification";
        }
        else if ([requestString rangeOfString:kCloseHomePage].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"CloseHomePageNotification";
        }
        else if ([requestString rangeOfString:kOpenAnualBook].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"OpenAnualBookNotification";
        }
        //link the urls and the notifications from modal view win
        else if ([requestString rangeOfString:kModalViewReady].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"ModalViewReadyNotification";
        }
        //link the urls and the notifications for common
        else if ([requestString rangeOfString:kOpenView].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"OpenViewNotification";
        }
        else if ([requestString rangeOfString:kCloseView].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"CloseViewNotification";
        }
//        else if ([requestString rangeOfString:kShowLeftPanle].length > 0)
//        {
//            self.shouldLoad = NO;
//            self.notificationType = @"ShowLeftPanleNotification";
//        }
        else if ([requestString rangeOfString:kGetQueryParam].length > 0)
        {
            self.shouldLoad = NO;
            self.notificationType = @"GetQueryParamNotification";
        }
        else
        {
            self.shouldLoad = YES;
            self.notificationType = @"";
        }
        self.getParamFuncName = [self parseGetParamFuncNameFromRequest:request];
    }
    return self;
}

- (NSString *)parseGetParamFuncNameFromRequest:(NSURLRequest *)request
{
    NSString* requestString = [[request URL] absoluteString];
    NSString *queryStr = [[request URL] query];
    if (queryStr && [requestString rangeOfString:@"AD_MAP"].length > 0) {
        NSRange range = [queryStr rangeOfString:@"="];
        NSString *getParamFunc =  [queryStr substringFromIndex:(range.location + 1)];
        getParamFunc = [getParamFunc stringByAppendingString:@"()"];
        return getParamFunc;
    }
    else
    {
        return nil;
    }
}

@end
