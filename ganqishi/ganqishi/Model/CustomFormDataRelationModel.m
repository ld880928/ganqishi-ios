//
//  CustomFormDataRelationModel.m
//  ganqishi
//
//  Created by Xing Kevin on 14-5-13.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import "CustomFormDataRelationModel.h"
#import "FMResultSet.h"

@implementation CustomFormDataRelationModel

- (instancetype)initWithFMResultSet:(FMResultSet *)rs
{
    if (self = [super init])
    {
        self.custom_form_data_relation_id = [rs stringForColumn:@"custom_form_data_relation_id"];
        self.custom_form_id = [rs stringForColumn:@"custom_form_id"];
        self.custom_form_data_id = [rs stringForColumn:@"custom_form_data_id"];
        self.custom_form_data_relation_value = [rs stringForColumn:@"custom_form_data_relation_value"];
    }
    return self;
}

@end
