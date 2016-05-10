//
//  FZISLineView.h
//  FZISUtils
//
//  Created by fzis299 on 16/1/26.
//  Copyright (c) 2016年 FZIS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kShapeRectangle 10
#define kShapeRectangleFill 11
#define kShapeCircle 12
#define kShapeCircleFill 13
#define kShapeFreeLine 14

@protocol FZISLineViewDelegate;

@interface FZISLineView : UIView{
    UIImage *_currentImg;
}

@property(nonatomic,strong) NSMutableArray *points;
@property(nonatomic,strong) UIImageView *imageView;

@property (nonatomic, retain) UIColor *penColor;
@property (nonatomic, assign) NSInteger penShape;
@property (nonatomic, assign) float penWidth;

@property (nonatomic, assign) id<FZISLineViewDelegate> lineViewDelegate;

@end


@protocol FZISLineViewDelegate <NSObject>

@optional

- (void)lineViewTouchesBegan:(FZISLineView *)lineView;
- (void)lineViewTouchesEnded:(FZISLineView *)lineView;

@end
