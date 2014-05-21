//
//  CustomScrollView.h
//  ganqishi
//
//  Created by Xing Kevin on 14-5-15.
//  Copyright (c) 2014年 colin. All rights reserved.
//


typedef NS_ENUM(NSInteger, NSScrollViewMode) {
    ViewMode   =  0,
    EditMode   =  1
};

#define BACKGROUND_GRAY [UIColor colorWithRed:.95f green:.95f blue:.95f alpha:1.0f]

#import <UIKit/UIKit.h>

@interface CustomScrollView : UIScrollView

// 设置浏览模式还是编辑模式
- (void)setMode:(NSScrollViewMode)mode;

// 设置Scroll View的内容
- (void)setValuesAndKeys:(NSArray *)arrValuesAndKeys;

// 获取Scroll View的内容
- (NSDictionary *)getValuesAndKeys;

@end
