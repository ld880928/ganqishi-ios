//
//  GanqishiSQL.h
//  ganqishi
//
//  Created by jijeMac2 on 14-5-9.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#ifndef ganqishi_GanqishiSQL_h
#define ganqishi_GanqishiSQL_h

#define GANQISHI_FILE_MANAGER [NSFileManager defaultManager]

#define PATH_DOCUMENTS NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define PATH_LIBRARY NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0]
#define PATH_CACHE NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]

//数据库名
#define DB_NAME @"ganqishi.db"

//表名

//品项数据表
#define TABLE_NAME_ITEM @"item"
#define TABLE_CREATE_SQL_ITEM @"CREATE TABLE IF NOT EXISTS item (item_id TEXT PRIMARY KEY, item_type TEXT, item_class TEXT, item_unit TEXT, item_name TEXT);"

//生产数据表
#define TABLE_NAME_PRODUCT @"product"
#define TABLE_CREATE_SQL_PRODUCT @"CREATE TABLE IF NOT EXISTS product (product_id TEXT PRIMARY KEY, product_class TEXT, product_syn BOOLEAN, product_time NUMERIC , product_date TEXT);"

//生产品项关联数据表
#define TABLE_NAME_PRODUCT_ITEM_RELATION @"product_item_relation"
#define TABLE_CREATE_SQL_PRODUCT_ITEM_RELATION @"CREATE TABLE IF NOT EXISTS product_item_relation (product_item_relation_id TEXT PRIMARY KEY, product_id TEXT, item_id TEXT, product_item_relation_produce NUMERIC);"

//生产数据备注表
#define TABLE_NAME_PRODUCT_REMARK @"product_remark"
#define TABLE_CREATE_SQL_PRODUCT_REMARK @"CREATE TABLE IF NOT EXISTS product_remark (product_remark_id TEXT PRIMARY KEY, product_remark_time NUMERIC, product_remark_content TEXT, product_id TEXT);"

//单位规则数据表
#define TABLE_NAME_UNIT_REGULER @"unit_reguler"
#define TABLE_CREATE_SQL_UNIT_REGULER @"CREATE TABLE IF NOT EXISTS unit_reguler (unit_reguler_id TEXT PRIMARY KEY, unit_reguler_type TEXT, unit_reguler_name TEXT, unit_reguler_ratio TEXT, item_id TEXT);"

//自定义表单表
#define TABLE_NAME_CUSTOM_FORM @"custom_form"
#define TABLE_CREATE_SQL_CUSTOM_FORM @"CREATE TABLE IF NOT EXISTS custom_form (custom_form_id TEXT PRIMARY KEY, custom_form_key TEXT, custom_form_name TEXT, custom_form_index TEXT UNIQUE, custom_form_available TEXT);"

//表单数据表
#define TABLE_NAME_CUSTOM_FORM_DATA @"custom_form_data"
#define TABLE_CREATE_SQL_CUSTOM_FORM_DATA @"CREATE TABLE IF NOT EXISTS custom_form_data (custom_form_data_id TEXT PRIMARY KEY, custom_form_data_per TEXT, custom_form_data_time NUMERIC, custom_form_data_syn BOOLEAN);"

//表单数据关联表
#define TABLE_NAME_CUSTOM_FORM_DATA_RELATION @"custom_form_data_relation"
#define TABLE_CREATE_SQL_CUSTOM_FORM_RELATION @"CREATE TABLE IF NOT EXISTS custom_form_data_relation (custom_form_data_relation_id TEXT PRIMARY KEY, custom_form_id TEXT, custom_form_data_id TEXT, custom_form_data_relation_value TEXT);"

#endif
