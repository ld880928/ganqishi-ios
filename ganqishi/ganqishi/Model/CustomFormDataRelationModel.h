//
//  CustomFormDataRelationModel.h
//  ganqishi
//
//  Created by Xing Kevin on 14-5-13.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMResultSet;

@interface CustomFormDataRelationModel : NSObject

@property(nonatomic, strong)NSString *custom_form_data_relation_id;
@property(nonatomic, strong)NSString *custom_form_id;
@property(nonatomic, strong)NSString *custom_form_data_id;
@property(nonatomic, strong)NSString *custom_form_data_relation_value;

- (instancetype)initWithFMResultSet:(FMResultSet *)rs;

@end
