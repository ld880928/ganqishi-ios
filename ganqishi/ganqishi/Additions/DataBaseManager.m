//
//  DataBaseManager.m
//  ganqishi
//
//  Created by jijeMac2 on 14-5-9.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import "DataBaseManager.h"

#import "GanqishiSQL.h"
#import "FMDB.h"

#import "StoreInfoManager.h"
#import "DateManager.h"
#import "Models.h"

@interface DataBaseManager()
@property(nonatomic,strong)NSString *dataBasePath;
@end

@implementation DataBaseManager

+ (DataBaseManager *)sharedManager
{
    static DataBaseManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
        
        sharedAccountManagerInstance.dataBasePath = [PATH_DOCUMENTS stringByAppendingPathComponent:[[StoreInfoManager sharedManager] getStoreID]];
        
        if (![GANQISHI_FILE_MANAGER fileExistsAtPath:sharedAccountManagerInstance.dataBasePath]) {
            [GANQISHI_FILE_MANAGER createDirectoryAtPath:sharedAccountManagerInstance.dataBasePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        FMDatabase *db = [FMDatabase databaseWithPath:[sharedAccountManagerInstance.dataBasePath stringByAppendingPathComponent:DB_NAME]];
        if ([db open]) {
            [db beginTransaction];
            
            [db executeUpdate:TABLE_CREATE_SQL_ITEM];
            [db executeUpdate:TABLE_CREATE_SQL_PRODUCT];
            [db executeUpdate:TABLE_CREATE_SQL_PRODUCT_ITEM_RELATION];
            [db executeUpdate:TABLE_CREATE_SQL_PRODUCT_REMARK];
            [db executeUpdate:TABLE_CREATE_SQL_UNIT_REGULER];
            [db executeUpdate:TABLE_CREATE_SQL_CUSTOM_FORM];
            [db executeUpdate:TABLE_CREATE_SQL_CUSTOM_FORM_DATA];
            [db executeUpdate:TABLE_CREATE_SQL_CUSTOM_FORM_RELATION];
            
            [db commit];
            [db close];
        }
    });
    return sharedAccountManagerInstance;
}

//根据class type 获取品项信息
- (id)getItemsByClassAndType:(NSString *)class_ type:(NSString *)type_
{
    NSString *sql = @"SELECT * FROM item WHERE item_class=? AND item_type=?";
    FMDatabase *db = [FMDatabase databaseWithPath:[self.dataBasePath stringByAppendingPathComponent:DB_NAME]];
    
    NSMutableArray *items = [NSMutableArray array];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:sql,class_,type_];
        while ([rs next]) {
            ItemModel *item = [[ItemModel alloc] initWithFMResultSet:rs];
            
            sql = @"SELECT * FROM unit_reguler WHERE item_id=?";
            
            FMResultSet *rs_ = [db executeQuery:sql,item.item_id];
            while ([rs_ next]) {
                item.unitReguler = [[UnitRegulerModel alloc ] initWithFMResultSet:rs_];
            }
            
            [items addObject:item];
        }
        
        [db close];
    }
    
    return items;
}

//根据class  items 获取一天的生产信息列表
- (id)getProductInfoListByClassAndItems:(NSString *)class_ items:(NSArray *)items_ dateString:(NSString *)dateString_
{
    NSString *sql = @"SELECT * FROM product WHERE product_class=? and product_date=? ORDER BY product_time ASC";
    FMDatabase *db = [FMDatabase databaseWithPath:[self.dataBasePath stringByAppendingPathComponent:DB_NAME]];
    NSMutableArray *products = [NSMutableArray array];
    
    if ([db open]) {
        [db beginTransaction];
        
        FMResultSet *rs = [db executeQuery:sql,class_,dateString_];
        while ([rs next]) {
            ProductModel *productModel = [[ProductModel alloc] init];
            productModel.product_id = [rs stringForColumn:@"product_id"];
            productModel.product_class = [rs stringForColumn:@"product_class"];
            productModel.product_time = [rs objectForColumnName:@"product_time"];
            productModel.product_syn = [rs objectForColumnName:@"product_syn"];
            productModel.product_date = [rs objectForColumnName:@"product_date"];
            
            //获取品项对应的产量
            NSMutableArray *productItemModels = [NSMutableArray array];
            for (int i=0; i<items_.count; i++) {
                ItemModel *item = [items_ objectAtIndex:i];
                ProductItemRelationModel *model = [[ProductItemRelationModel alloc] init];
                sql = @"SELECT * FROM product_item_relation WHERE product_id=? AND item_id=?";
                FMResultSet *rs_ = [db executeQuery:sql,productModel.product_id,item.item_id];
                while ([rs_ next]) {
                    model.item_id = item.item_id;
                    model.product_id = productModel.product_id;
                    model.product_item_relation_produce = [rs_ objectForColumnName:@"product_item_relation_produce"];
                    model.product_item_relation_id = [rs_ stringForColumn:@"product_item_relation_id"];
                }
                
                [productItemModels addObject:model];
            }
            
            productModel.productItems = productItemModels;
            
            //获取备注列表
            sql = @"SELECT * FROM product_remark WHERE product_id=?";
            FMResultSet *rs__ = [db executeQuery:sql,productModel.product_id];
            NSMutableArray *remarks = [NSMutableArray array];
            while ([rs__ next]) {
                ProductRemarkModel *remarkModel = [[ProductRemarkModel alloc] initWithFMResultSet:rs__];
                [remarks addObject:remarkModel];
            }
            productModel.productRemarks = remarks;
            
            [products addObject:productModel];
        }
        
        [db commit];
        [db close];
    }
    
    return products;
}

//新建和面信息。获取参照信息列表
- (id)getFormulaProductInfoListByClassAndItems:(NSString *)class_ items:(NSArray *)items_ date:(NSDate *)date_
{
    NSMutableArray *dataArray = [NSMutableArray array];
    
    NSString *dateString = [[DateManager sharedManager] dateStringFrom:date_];
    id todayProductInfoList = [self getProductInfoListByClassAndItems:class_ items:items_ dateString:dateString];
    
    //今天所有的和面信息
    if (todayProductInfoList && [todayProductInfoList count]) {
        [dataArray addObjectsFromArray:todayProductInfoList];
    }
    
    NSString *yesterday = nil;
    NSString *sql = @"SELECT distinct product_date FROM product WHERE product_time < ? AND product_date <> ? ORDER BY product_time ASC";
    FMDatabase *db = [FMDatabase databaseWithPath:[self.dataBasePath stringByAppendingPathComponent:DB_NAME]];
    if ([db open]) {
        [db beginTransaction];
        FMResultSet *rs = [db executeQuery:sql,[NSNumber numberWithDouble:[date_ timeIntervalSince1970]],dateString];
        while ([rs next]) {
            yesterday = [rs stringForColumn:@"product_date"];
            break;
        }
        
        if (yesterday) {
            
            NSMutableArray *products = [NSMutableArray array];
            
            sql = @"SELECT * FROM product WHERE product_class=? and product_date=? ORDER BY product_time ASC LIMIT 3";
            FMResultSet *rs = [db executeQuery:sql,class_,yesterday];
            while ([rs next]) {
                ProductModel *productModel = [[ProductModel alloc] init];
                productModel.product_id = [rs stringForColumn:@"product_id"];
                productModel.product_class = [rs stringForColumn:@"product_class"];
                productModel.product_time = [rs objectForColumnName:@"product_time"];
                productModel.product_syn = [rs objectForColumnName:@"product_syn"];
                productModel.product_date = [rs objectForColumnName:@"product_date"];
                
                //获取品项对应的产量
                NSMutableArray *productItemModels = [NSMutableArray array];
                for (int i=0; i<items_.count; i++) {
                    ItemModel *item = [items_ objectAtIndex:i];
                    ProductItemRelationModel *model = [[ProductItemRelationModel alloc] init];
                    sql = @"SELECT * FROM product_item_relation WHERE product_id=? AND item_id=?";
                    FMResultSet *rs_ = [db executeQuery:sql,productModel.product_id,item.item_id];
                    while ([rs_ next]) {
                        model.item_id = item.item_id;
                        model.product_id = productModel.product_id;
                        model.product_item_relation_produce = [rs_ objectForColumnName:@"product_item_relation_produce"];
                        model.product_item_relation_id = [rs_ stringForColumn:@"product_item_relation_id"];
                    }
                    [productItemModels addObject:model];
                    
                }
                
                productModel.productItems = productItemModels;
                
                //获取备注列表
                sql = @"SELECT * FROM product_remark WHERE product_id=?";
                FMResultSet *rs__ = [db executeQuery:sql,productModel.product_id];
                NSMutableArray *remarks = [NSMutableArray array];
                while ([rs__ next]) {
                    ProductRemarkModel *remarkModel = [[ProductRemarkModel alloc] initWithFMResultSet:rs__];
                    [remarks addObject:remarkModel];
                }
                productModel.productRemarks = remarks;
                
                [products addObject:productModel];
            }
            
            //上一天的前3条和面信息
            if (products && products.count) {
                [dataArray addObjectsFromArray:products];
            }
            
        }

        [db commit];
        [db close];
    }
    
    return dataArray;
}

//根据class  items 获取生产历史信息列表
- (id)getProductInfoHistoryListByClassAndItems:(NSString *)class_ items:(NSArray *)items_
{
    NSMutableArray *historys = [NSMutableArray array];
    //先查询date
    NSString *sql = @"SELECT distinct product_date FROM product WHERE product_class=? ORDER BY product_time ASC";
    FMDatabase *db = [FMDatabase databaseWithPath:[self.dataBasePath stringByAppendingPathComponent:DB_NAME]];
    if ([db open]) {
        [db beginTransaction];
        FMResultSet *rs = [db executeQuery:sql,class_];
        while ([rs next]) {
            
            NSString *dateString = [rs stringForColumn:@"product_date"];
            
            NSMutableArray *sums = [NSMutableArray array];
            
            for (int i=0; i<items_.count; i++) {
                
                ItemModel *item = [items_ objectAtIndex:i];
                sql = @"SELECT product_id FROM product WHERE product_date=? ORDER BY product_time ASC";
                FMResultSet *rs_ = [db executeQuery:sql,dateString];
                
                int sum = 0;
                
                while ([rs_ next]) {
                    NSString *product_id = [rs_ stringForColumn:@"product_id"];
                    sql = @"SELECT product_item_relation_produce FROM product_item_relation WHERE item_id=? AND product_id=?";
                    FMResultSet *rs__ = [db executeQuery:sql,item.item_id,product_id];
                    while ([rs__ next]) {
                        sum += [[rs__ objectForColumnName:@"product_item_relation_produce"] intValue];
                    }
                    
                }
                
                [sums addObject:[NSNumber numberWithInt:sum]];
                
            }
            
            
            [historys addObject:@{@"date": dateString,@"items" : sums}];
        }
        
        [db commit];
        [db close];
    }
    
    return historys;
}

//新建一条生产记录
- (void)newProductInfo:(ProductModel *)productModel
{
    NSString *sql = @"INSERT INTO product VALUES (?,?,?,?,?)";
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self.dataBasePath stringByAppendingPathComponent:DB_NAME]];
    if ([db open]) {
        [db beginTransaction];
        
        //插入生产记录
        [db executeUpdate:sql,productModel.product_id,productModel.product_class,productModel.product_syn,productModel.product_time,productModel.product_date];
        
        //插入备注
        for (ProductRemarkModel *remark in productModel.productRemarks) {
            sql = @"INSERT INTO product_remark VALUES (?,?,?,?)";
            [db executeUpdate:sql,remark.product_remark_id,remark.product_remark_time,remark.product_remark_content,remark.product_id];
        }
        
        //插入品项产量信息
        for (ProductItemRelationModel *model in productModel.productItems) {
            sql = @"INSERT INTO product_item_relation VALUES (?,?,?,?)";
            [db executeUpdate:sql,model.product_item_relation_id,model.product_id,model.item_id,model.product_item_relation_produce];
        }
        
        [db commit];
        [db close];
    }

}

//新建一条自定义表单数据
- (void)newCustomFormData:(CustomFormDataModel *)customFormDataModel
{
    NSString *sql = @"INSERT INTO custom_form_data VALUES (?,?,?,?)";
    FMDatabase *db = [FMDatabase databaseWithPath:[self.dataBasePath stringByAppendingPathComponent:DB_NAME]];
    if ([db open]) {
        [db beginTransaction];
        
        //插入表单数据
        [db executeUpdate:sql, customFormDataModel.custom_form_data_id, customFormDataModel.custom_form_data_per, customFormDataModel.custom_form_data_time, customFormDataModel.custom_form_data_syn];
        
        //插入表单数据联系
        for (CustomFormDataRelationModel *model in customFormDataModel.custom_form_data_relation_list)
        {
            sql = @"INSERT INTO custom_form_data_relation VALUES (?,?,?,?)";
            [db executeUpdate:sql, model.custom_form_data_relation_id, model.custom_form_id, model.custom_form_data_id, model.custom_form_data_relation_value];
        }
        
        [db commit];
        [db close];
    }
}

//更改一条自定义表单数据
- (void)modifyCustomFormDataRelation:(CustomFormDataRelationModel *)customFormDataRelationModel
{
    NSString *sql = @"UPDATE custom_form_data_relation SET custom_form_data_relation_value=? WHERE custom_form_data_id=? AND custom_form_id=?";
    FMDatabase *db = [FMDatabase databaseWithPath:[self.dataBasePath stringByAppendingPathComponent:DB_NAME]];
    if ([db open]) {
        [db beginTransaction];
        
        //更新表单数据
        [db executeUpdate:sql, customFormDataRelationModel.custom_form_data_relation_value, customFormDataRelationModel.custom_form_data_id, customFormDataRelationModel.custom_form_id];
        
        [db commit];
        [db close];
    }
}

//插入自定义表单字段
- (void)newCustomForm:(CustomFormModel *)customForm
{
    NSString *sql = @"INSERT INTO custom_form VALUES (?,?,?,?,?)";
    FMDatabase *db = [FMDatabase databaseWithPath:[self.dataBasePath stringByAppendingPathComponent:DB_NAME]];
    if ([db open]) {
        [db beginTransaction];
        
        //插入自定义表单字段
        [db executeUpdate:sql, customForm.custom_form_id, customForm.custom_form_key, customForm.custom_form_name, customForm.custom_form_index, customForm.custom_form_available];
        
        [db commit];
        [db close];
    }
}

//根据时间获取增加自定义表单数据的列表
- (id)getCustomFormDataFromDate:(NSDate *)startDate toDate:(NSDate *)endDate
{
    NSString *sql = @"SELECT custom_form_id FROM custom_form";
    FMDatabase *db = [FMDatabase databaseWithPath:[self.dataBasePath stringByAppendingPathComponent:DB_NAME]];
    NSMutableArray *customFormDataModels = [NSMutableArray array];
    
    if ([db open]) {
        [db beginTransaction];
        
        // 从custom_form获得所有的custom_form_id
        NSMutableArray *customFormIDs = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next])
        {
            [customFormIDs addObject:[rs stringForColumn:@"custom_form_id"]];
        }
        
        // 从custom_form_data获取指定日期内的数据
        NSNumber *startSeconds = [NSNumber numberWithDouble:[startDate timeIntervalSince1970]];
        NSNumber *endSeconds = [NSNumber numberWithDouble:[endDate timeIntervalSince1970]];
        
        sql = @"SELECT * FROM custom_form_data WHERE custom_form_data_time>? and custom_form_data_time<?";
        FMResultSet *rs_ = [db executeQuery:sql, startSeconds, endSeconds];
        while ([rs_ next]) {
            CustomFormDataModel *customFormDataModel = [[CustomFormDataModel alloc] initWithFMResultSet:rs_];
            
            NSMutableArray *customFormDataRelationModels = [NSMutableArray array];
            for (int i=0; i<customFormIDs.count; i++)
            {
                NSString *customFormID = [customFormIDs objectAtIndex:i];
                
                sql = @"SELECT * FROM custom_form_data_relation WHERE custom_form_data_id=? and custom_form_id=?";
                FMResultSet *rs__ = [db executeQuery:sql, customFormDataModel.custom_form_data_id, customFormID];
                while ([rs__ next])
                {
                    CustomFormDataRelationModel *customFormRelationModel = [[CustomFormDataRelationModel alloc] initWithFMResultSet:rs__];
                    [customFormDataRelationModels addObject:customFormRelationModel];
                }
            }
            customFormDataModel.custom_form_data_relation_list = customFormDataRelationModels;
            [customFormDataModels addObject:customFormDataModel];
        }
        [db commit];
        [db close];
    }
    
    return customFormDataModels;
}

// 获取所有的自定义表单的字段信息
- (id)getCustomFormItems
{
    NSString *sql = @"SELECT * FROM custom_form";
    FMDatabase *db = [FMDatabase databaseWithPath:[self.dataBasePath stringByAppendingPathComponent:DB_NAME]];
    NSMutableArray *customFormItemModels = [NSMutableArray array];
    
    if ([db open]) {
        [db beginTransaction];
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next])
        {
            CustomFormModel *customFormModel = [[CustomFormModel alloc] initWithFMResultSet:rs];
            [customFormItemModels addObject:customFormModel];
        }
        [db commit];
        [db close];
    }
    return customFormItemModels;
}

@end
