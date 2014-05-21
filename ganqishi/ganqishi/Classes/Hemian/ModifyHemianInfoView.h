//
//  ModifyHemianInfoView.h
//  ganqishi
//
//  Created by jijeMac2 on 14-5-20.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductModel;

@interface ModifyHemianInfoView : UIView

@property(copy,nonatomic)void (^saveCallBackBlock)(id info);

- (void)showInView:(UIView *)view_;
- (void)hide;

+ (ModifyHemianInfoView *)ModifyHemianInfoViewWithItems:(NSArray *)items_ productModel:(ProductModel *)model_;
@end
