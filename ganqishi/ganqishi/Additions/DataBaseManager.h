//
//  DataBaseManager.h
//  ganqishi
//
//  Created by jijeMac2 on 14-5-9.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProductModel;
@class CustomFormModel;
@class CustomFormDataModel;
@class CustomFormDataRelationModel;

@interface DataBaseManager : NSObject
+ (DataBaseManager *)sharedManager;

//根据class type 获取品项信息
- (id)getItemsByClassAndType:(NSString *)class_ type:(NSString *)type_;

//新建一条生产记录
- (void)newProductInfo:(ProductModel *)productModel;

//根据class  items 获取一天的生产信息列表
- (id)getProductInfoListByClassAndItems:(NSString *)class_ items:(NSArray *)items_ dateString:(NSString *)dateString_;

//新建和面信息。获取参照信息列表
- (id)getFormulaProductInfoListByClassAndItems:(NSString *)class_ items:(NSArray *)items_ date:(NSDate *)date_;

//根据class  items 获取生产历史信息列表
- (id)getProductInfoHistoryListByClassAndItems:(NSString *)class_ items:(NSArray *)items_;

//增加一条自定义表单数据
- (void)newCustomFormData:(CustomFormDataModel *)customFormDataModel;

//更改一条自定义表单数据
- (void)modifyCustomFormDataRelation:(CustomFormDataRelationModel *)customFormDataRelationModel;

//增加自定义表单字段
- (void)newCustomForm:(CustomFormModel *)customForm;

//根据时间获取增加自定义表单数据的列表
- (id)getCustomFormDataFromDate:(NSDate *)startDate toDate:(NSDate *)endDate;

// 获取所有的自定义表单的字段信息
- (id)getCustomFormItems;

@end
