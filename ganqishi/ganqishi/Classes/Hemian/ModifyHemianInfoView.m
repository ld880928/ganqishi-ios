//
//  ModifyHemianInfoView.m
//  ganqishi
//
//  Created by jijeMac2 on 14-5-20.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import "ModifyHemianInfoView.h"
#import "Models.h"
#import "StepInputView.h"

@interface ModifyHemianInfoView()
@property(nonatomic,strong)NSArray *items;
@property (weak, nonatomic) IBOutlet UIView *infoHearderView;
@property(strong,nonatomic) NSMutableArray *inputsArray;
@end

@implementation ModifyHemianInfoView

- (void)showInView:(UIView *)view_
{
    self.frame = CGRectMake(0, 768.0f, self.bounds.size.width, self.bounds.size.height);
    [view_ addSubview:self];
    
    [UIView animateWithDuration:.5f animations:^{
        self.frame = CGRectMake(0, 64.0f, self.bounds.size.width, self.bounds.size.height);
    }];
}

- (void)hide
{
    [UIView animateWithDuration:.5f animations:^{
        self.frame = CGRectMake(0, 768.0f, self.bounds.size.width, self.bounds.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)cancel:(id)sender
{
    [self hide];
}

- (IBAction)save:(id)sender
{
    self.saveCallBackBlock(nil);
    [self hide];
}

+ (ModifyHemianInfoView *)ModifyHemianInfoViewWithItems:(NSArray *)items_ productModel:(ProductModel *)model_
{
    ModifyHemianInfoView *modifyHemianInfoView = [[[NSBundle mainBundle] loadNibNamed:@"ModifyHemianInfoView" owner:self options:nil] lastObject];
    
    modifyHemianInfoView.items = items_;
    
    for (int i=0; i<modifyHemianInfoView.items.count; i++) {
        ItemModel *itemModel = [modifyHemianInfoView.items objectAtIndex:i];
        
        UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(150.0f + 150.0f * i, 0, 150.0f, 44.0f)];
        itemLabel.text = itemModel.item_name;
        itemLabel.textAlignment = NSTextAlignmentCenter;
        [modifyHemianInfoView.infoHearderView addSubview:itemLabel];
    }
    
    for (int i=0; i<modifyHemianInfoView.items.count; i++) {
        UIView *v = [[modifyHemianInfoView.infoHearderView subviews] objectAtIndex:i];
        StepInputView *stepInputView = [[[NSBundle mainBundle] loadNibNamed:@"StepInputView" owner:self options:nil] lastObject];
        [stepInputView setPosition:CGPointMake(v.frame.origin.x + 20.0f, 142.0f)];
        [modifyHemianInfoView addSubview:stepInputView];
        [modifyHemianInfoView.inputsArray addObject:stepInputView];
        
        ProductItemRelationModel *m = [model_.productItems objectAtIndex:i];
        [stepInputView setInputValue:m.product_item_relation_produce];
    }
    
    
    return modifyHemianInfoView;
}

@end
