//
//  FZISNetworkTool.m
//  FZISUtils
//
//  Created by fzis299 on 16/1/21.
//  Copyright (c) 2016年 FZIS. All rights reserved.
//

#import "FZISNetworkTool.h"

@implementation FZISNetworkTool

@synthesize url;
@synthesize name;

- (FZISNetworkTool *)initWithURL:(NSString *)urlString
{
    self = [super init];
    if (self) {
        self.url = [NSURL URLWithString:urlString];
    }
    
    return self;
}

//- (void)sendRequestWithData:(NSData *)data
//{
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url];
//    [request setTimeoutInterval:10];
//    
//    if ([self isRemoteHostReachable]) {
//        if (data != nil) {
//            [request setHTTPMethod:@"POST"];
//            [request setHTTPBody:data];
//            [self sendRequestByPOST:request];
//        }
//        else
//        {
//            [self performSelectorInBackground:@selector(sendRequestByGET:) withObject:request];
//        }
//    }
//}

- (void)sendRequestByPOSTWithData:(NSData *)data
{
    if ([self isRemoteHostReachable]) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url];
        [request setTimeoutInterval:10];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:data];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError != nil) {
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(FZISNetworkTool:didGetError:)]) {
                    [self.delegate FZISNetworkTool:self didGetError:connectionError];
                }
            }
            else
            {
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(FZISNetworkTool:didGetResponse:withData:)]) {
                    [self.delegate FZISNetworkTool:self didGetResponse:response withData:data];
                }
            }
        }];
    }
    else
    {
        NSError *error = [[NSError alloc] init];
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(FZISNetworkTool:didGetError:)]) {
            [self.delegate FZISNetworkTool:self didGetError:error];
        }
    }
    
}

- (NSDictionary *)sendRequestByGET
{
    NSDictionary *result;
    
    if ([self isRemoteHostReachable])
    {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url];
        
        [request setTimeoutInterval:10];
        NSURLResponse *response;
        NSError *error;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error != nil) {
            result = [[NSDictionary alloc] initWithObjectsAndKeys:error, @"error", nil];
        }
        else
        {
            result = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"data", response, @"response", nil];
        }
    }   
    
    return result;
}

- (BOOL)isRemoteHostReachable
{
    Reachability *r = [Reachability reachabilityWithHostName:url.host];
    
    if ([r currentReachabilityStatus] == NotReachable) {
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
