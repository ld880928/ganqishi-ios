//
//  CustomFormModel.h
//  ganqishi
//
//  Created by Xing Kevin on 14-5-13.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMResultSet;

@interface CustomFormModel : NSObject

@property(nonatomic, strong)NSString *custom_form_id;
@property(nonatomic, strong)NSString *custom_form_key;
@property(nonatomic, strong)NSString *custom_form_name;
@property(nonatomic, strong)NSNumber *custom_form_index;
@property(nonatomic, strong)NSNumber *custom_form_available;

- (instancetype)initWithFMResultSet:(FMResultSet *)rs;

@end
