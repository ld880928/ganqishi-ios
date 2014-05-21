//
//  AddNewCustomDataView.m
//  ganqishi
//
//  Created by Xing Kevin on 14-5-14.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import "AddNewCustomDataView.h"

@interface AddNewCustomDataView()

@end

@implementation AddNewCustomDataView

+ (CGFloat)getY
{
    return 64.0f;
}

+ (NSTimeInterval)getAnimationTime
{
    return .5f;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)cancel:(id)sender
{
    if ([self.leftButton.titleLabel.text isEqualToString:@"取消"] && self.isDetailView)// 返回View Mode
    {
        [self.rightButton setTitle:@"修改" forState:UIControlStateNormal];
        [self.leftButton setTitle:@"返回" forState:UIControlStateNormal];
        [self.scrollView setMode:ViewMode];
        return;
    }
    self.cancelCallBackBlock();
}

- (IBAction)save:(id)sender
{
    if ([self.rightButton.titleLabel.text isEqualToString:@"修改"] && self.isDetailView)// 进入Edit Mode
    {
        [self.rightButton setTitle:@"保存" forState:UIControlStateNormal];
        [self.leftButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.scrollView setMode:EditMode];
        return;
    }
    if (self.isDetailView)// 返回View Mode并保存数据
    {
        [self.rightButton setTitle:@"修改" forState:UIControlStateNormal];
        [self.leftButton setTitle:@"返回" forState:UIControlStateNormal];
        [self.scrollView setMode:ViewMode];
        self.saveCallBackBlock(NO);
    }
    else
    {
        self.saveCallBackBlock(YES);
    }
    
}

- (void)initDataWithItems:(NSArray *)items_
{
    self.frame = CGRectMake(self.frame.size.width, [[self class] getY], self.frame.size.width, self.frame.size.height);
}

// 配置scrollview
- (void)setValuesAndKeys:(NSArray *)arrValuesAndKeys ForMode:(NSScrollViewMode)mode
{
    self.backgroundColor = BACKGROUND_GRAY;
    self.scrollView.backgroundColor = BACKGROUND_GRAY;
    self.scrollView.contentSize = CGSizeMake(984, 651);
    
    [self.scrollView setValuesAndKeys:arrValuesAndKeys];
    [self.scrollView setMode:mode];
}

- (void)dealloc
{
    self.cancelCallBackBlock = nil;
    self.saveCallBackBlock = nil;
}

@end
