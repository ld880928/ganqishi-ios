//
//  CustomFormModel.m
//  ganqishi
//
//  Created by Xing Kevin on 14-5-13.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import "CustomFormModel.h"
#import "FMResultSet.h"

@implementation CustomFormModel

- (instancetype)initWithFMResultSet:(FMResultSet *)rs
{
    if (self = [super init])
    {
        self.custom_form_id     = [rs stringForColumn:@"custom_form_id"];
        self.custom_form_key    = [rs stringForColumn:@"custom_form_key"];
        self.custom_form_name   = [rs stringForColumn:@"custom_form_name"];
        self.custom_form_index  = [rs objectForColumnName:@"custom_form_index"];
        self.custom_form_available = [rs objectForColumnName:@"custom_form_available"];
    }
    return self;
}

@end
