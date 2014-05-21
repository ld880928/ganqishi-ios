//
//  CustomFormDataModel.m
//  ganqishi
//
//  Created by Xing Kevin on 14-5-13.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import "CustomFormDataModel.h"
#import "FMResultSet.h"

@implementation CustomFormDataModel

- (instancetype)initWithFMResultSet:(FMResultSet *)rs
{
    if (self = [super init])
    {
        self.custom_form_data_id    = [rs stringForColumn:@"custom_form_data_id"];
        self.custom_form_data_per   = [rs stringForColumn:@"custom_form_data_per"];
        self.custom_form_data_time  = [rs objectForColumnName:@"custom_form_data_time"];
        self.custom_form_data_syn   = [rs objectForColumnName:@"custom_form_data_syn"];
    }
    return self;
}

@end
