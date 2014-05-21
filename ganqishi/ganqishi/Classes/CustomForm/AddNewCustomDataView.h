//
//  AddNewCustomDataView.h
//  ganqishi
//
//  Created by Xing Kevin on 14-5-14.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomScrollView.h"

@interface AddNewCustomDataView : UIView
@property(copy,nonatomic)void (^cancelCallBackBlock)();
@property(copy,nonatomic)void (^saveCallBackBlock)(BOOL removeView);

@property (nonatomic, unsafe_unretained) BOOL isDetailView;// 表示是否是从UIableView push过来的
@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton *rightButton;
@property (nonatomic, weak) IBOutlet CustomScrollView *scrollView;

+ (CGFloat)getY;
+ (NSTimeInterval)getAnimationTime;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (void)initDataWithItems:(NSArray *)items_;

// 配置scrollview
- (void)setValuesAndKeys:(NSArray *)arrValuesAndKeys ForMode:(NSScrollViewMode)mode;

@end
