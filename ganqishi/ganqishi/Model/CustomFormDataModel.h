//
//  CustomFormDataModel.h
//  ganqishi
//
//  Created by Xing Kevin on 14-5-13.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMResultSet;

@interface CustomFormDataModel : NSObject

@property(nonatomic, strong)NSString *custom_form_data_id;
@property(nonatomic, strong)NSString *custom_form_data_per;
@property(nonatomic, strong)NSNumber *custom_form_data_time;
@property(nonatomic, strong)NSNumber *custom_form_data_syn;
@property(nonatomic, strong)NSMutableArray  *custom_form_data_relation_list;

- (instancetype)initWithFMResultSet:(FMResultSet *)rs;

@end
