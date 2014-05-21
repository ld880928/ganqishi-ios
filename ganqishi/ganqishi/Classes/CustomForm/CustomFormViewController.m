//
//  CustomFormViewController.m
//  ganqishi
//
//  Created by Xing Kevin on 14-5-13.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import "CustomFormViewController.h"
#import "AddNewCustomDataView.h"

#import "DataBaseManager.h"
#import "DateManager.h"
#import "Models.h"

@interface CustomFormViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *startDate;
@property (weak, nonatomic) IBOutlet UITextField *endDate;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton1;
@property (weak, nonatomic) IBOutlet UIButton *addButton2;
@property (weak, nonatomic) IBOutlet UIView *infoHearderView;
@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (strong,nonatomic) UIDatePicker *datePicker;
@property (strong,nonatomic) AddNewCustomDataView *addNewView;
@property (strong,nonatomic) NSArray *columnList;
@property (strong,nonatomic) NSMutableArray *dataRelationList;
@property (strong,nonatomic) NSMutableArray *rowList;
@end

@implementation CustomFormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    self.searchButton.layer.cornerRadius = 5.0f;
    self.dataRelationList = [[NSMutableArray alloc] init];
    
    // 将textfield的inputView设置为datepicker
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.startDate.inputView = self.datePicker;
    self.endDate.inputView   = self.datePicker;
    
    // 将textfield的accessoryView设置为toolBar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 440)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelPicker)];
    toolBar.items = [NSArray arrayWithObject:rightItem];
    self.startDate.inputAccessoryView = toolBar;
    self.endDate.inputAccessoryView   = toolBar;
    
    //从plist文件中获得自定义表单的设置
    NSString *settingFilePath = [[NSBundle mainBundle] pathForResource:@"CustomFormSetting" ofType:@"plist"];
    NSDictionary *dicSettingInfo = [NSDictionary dictionaryWithContentsOfFile:settingFilePath];
    NSString *formName = [dicSettingInfo objectForKey:@"FormName"];
    self.columnList = [dicSettingInfo objectForKey:@"ColumnList"];
    self.title = formName;
    
    NSArray *customFormModels = [[DataBaseManager sharedManager] getCustomFormItems];
    
    //将新的字段加入到自定义表单
    for (int i=0; i<self.columnList.count; i++)
    {
        NSDictionary *dicCustomFormInfo     = [self.columnList objectAtIndex:i];
        NSString *customFormKeyFromXML      = [dicCustomFormInfo objectForKey:@"key"];
        
        BOOL existThisCustomFormModels = NO;
        for (int j=0; j<customFormModels.count; j++)
        {
            CustomFormModel *customFormModel = [customFormModels objectAtIndex:j];
            NSString *customFormKey = customFormModel.custom_form_key;
            //如果key相同，则比较是否变更name，index，available
            if ([customFormKey isEqualToString:customFormKeyFromXML])
            {
                existThisCustomFormModels = YES;
                
            }
        }
        
        //如果找不到这个key，则判定为新加字段
        if (!existThisCustomFormModels)
        {
            CustomFormModel *customFormModel    = [[CustomFormModel alloc] init];
            customFormModel.custom_form_id      = [[NSUUID UUID] UUIDString];
            customFormModel.custom_form_key     = [dicCustomFormInfo objectForKey:@"key"];
            customFormModel.custom_form_name    = [dicCustomFormInfo objectForKey:@"name"];
            customFormModel.custom_form_index   = [dicCustomFormInfo objectForKey:@"index"];
            customFormModel.custom_form_available = [dicCustomFormInfo objectForKey:@"available"];
            [[DataBaseManager sharedManager] newCustomForm:customFormModel];
        }
    }
    
    customFormModels = [[DataBaseManager sharedManager] getCustomFormItems];
    [self.dataRelationList setArray:customFormModels];
    
    //初始化header view
    [self initInfoHeader];
    
    //设置查询时间，并获得数据，重载TableView
    NSDate *now = [NSDate date];
    double oneWeekAgoDouble = [now timeIntervalSince1970] - 7*24*3600;
    NSDate *oneWeekAgo = [NSDate dateWithTimeIntervalSince1970:oneWeekAgoDouble];
    
    [self reloadDataFromDate:oneWeekAgo toDate:now];
}

// 查询事件
- (IBAction)searchData:(id)sender
{
    [self.startDate resignFirstResponder];
    [self.endDate   resignFirstResponder];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *fromDate = [dateFormatter dateFromString:self.startDate.text];
    NSDate *toDate   = [dateFormatter dateFromString:self.endDate.text];
    [self reloadDataFromDate:fromDate toDate:toDate];
}

// Get data for selected days and reload tableview
- (void)reloadDataFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateFormatter *dateFormatterWithTime = [[NSDateFormatter alloc] init];
    [dateFormatterWithTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // fromDate加上时间00:00:00
    NSString *fromDateStr = [[DateManager sharedManager] dateStringFrom:fromDate];
    NSString *fromDateWithTimeStr = [NSString stringWithFormat:@"%@ 00:00:00", fromDateStr];
    fromDate = [dateFormatterWithTime dateFromString:fromDateWithTimeStr];
    
    // toDate加上时间23:59:59
    NSString *toDateStr = [[DateManager sharedManager] dateStringFrom:toDate];
    NSString *toDateWithTimeStr = [NSString stringWithFormat:@"%@ 23:59:59", toDateStr];
    toDate = [dateFormatterWithTime dateFromString:toDateWithTimeStr];
    
    // 设置textfield的显示日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    fromDateStr = [dateFormatter stringFromDate:fromDate];
    toDateStr   = [dateFormatter stringFromDate:toDate];
    self.startDate.text = fromDateStr;
    self.endDate.text   = toDateStr;

    self.rowList = [[DataBaseManager sharedManager] getCustomFormDataFromDate:fromDate toDate:toDate];
    [self.infoTableView reloadData];
}

-(void) cancelPicker
{
    NSArray *subViews = self.view.subviews;
    for (UIView *someView in subViews)
    {
        if ([someView isKindOfClass:[UITextField class]] && [someView isFirstResponder])// 找到当前的firstResponder，然后赋值为datePicker的值
        {
            if ([self.view endEditing:NO])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSString *dateStr = [dateFormatter stringFromDate:self.datePicker.date];
                NSLog(@"%@", dateStr);
                UITextField *dateText = (UITextField *)someView;
                dateText.text = dateStr;
                
                self.searchButton.hidden = NO;
                self.addButton1.hidden   = NO;
                self.addButton2.hidden   = NO;
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark init header 初始化header
- (void)initInfoHeader
{
    while (self.infoHearderView.subviews.lastObject)
    {
        [(UIView *)self.infoHearderView.subviews.lastObject removeFromSuperview];
    }
    
    CGFloat moreLabelWidth = 0;
    CGFloat stateLabelWidth = 100.0f;
    
    // 此时view还在纵向模式，width为768，height为1024
    CGFloat columnWidth = (CGFloat)(self.infoHearderView.frame.size.width - stateLabelWidth)/self.columnList.count;
    int showLabelsCount = self.columnList.count;
    
    // 如果字段数量大于5，其余字段以省略号显示
    if (self.columnList.count > 5)
    {
        moreLabelWidth = 50.0f;
        showLabelsCount = 5;
        columnWidth = (CGFloat)(self.infoHearderView.frame.size.width - stateLabelWidth - moreLabelWidth)/showLabelsCount;
    }

    UILabel *columnLabel = nil;
    for (int i=0; i<showLabelsCount; i++) {
        columnLabel = [[UILabel alloc] initWithFrame:CGRectMake(columnWidth * i, 0, columnWidth, 44)];
        columnLabel.textAlignment = NSTextAlignmentCenter;
        columnLabel.attributedText = [[NSAttributedString alloc] initWithString:[[self.columnList objectAtIndex:i] objectForKey:@"name"] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
        [self.infoHearderView addSubview:columnLabel];
    }
    
    if (self.columnList.count > 5)
    {
        columnLabel = [[UILabel alloc] initWithFrame:CGRectMake(columnWidth * showLabelsCount, -5, moreLabelWidth, 44)];
        columnLabel.textAlignment = NSTextAlignmentCenter;
        columnLabel.attributedText = [[NSAttributedString alloc] initWithString:@"..." attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
        [self.infoHearderView addSubview:columnLabel];
    }
    
    columnLabel = [[UILabel alloc] initWithFrame:CGRectMake(columnWidth * showLabelsCount + moreLabelWidth, 0, stateLabelWidth, 44)];
    columnLabel.textAlignment = NSTextAlignmentCenter;
    columnLabel.attributedText = [[NSAttributedString alloc] initWithString:@"状态" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    [self.infoHearderView addSubview:columnLabel];
}

#pragma mark add new 增加新数据
- (IBAction)addNew:(id)sender
{
    self.addNewView = [[[NSBundle mainBundle] loadNibNamed:@"AddNewCustomDataView" owner:self options:nil] lastObject];
    __unsafe_unretained CustomFormViewController *safe_self = self;
    
    [self.addNewView setCancelCallBackBlock:^{
        // 返回
        [UIView animateWithDuration:[AddNewCustomDataView getAnimationTime] animations:^{
            CGRect frame = safe_self.addNewView.frame;
            safe_self.addNewView.frame = CGRectMake(frame.size.width, [AddNewCustomDataView getY], frame.size.width, frame.size.height);
        } completion:^(BOOL finished) {
            [safe_self.addNewView removeFromSuperview];
            safe_self.addNewView = nil;
        }];
    }];
    
    [self.addNewView setSaveCallBackBlock:^(BOOL removeView){
        // 保存
        NSDictionary *inputValues = [safe_self.addNewView.scrollView getValuesAndKeys];
        
        CustomFormDataModel *customFormDataModel  = [[CustomFormDataModel alloc] init];
        customFormDataModel.custom_form_data_id   = [[NSUUID UUID] UUIDString];
        customFormDataModel.custom_form_data_per  = @"本店";
        customFormDataModel.custom_form_data_syn  = [NSNumber numberWithBool:NO];
        customFormDataModel.custom_form_data_time = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        
        NSMutableArray *custom_form_data_relation_list = [NSMutableArray array];
        for (int i=0; i<safe_self.dataRelationList.count; i++)
        {
            CustomFormModel *customFormModel = [safe_self.dataRelationList objectAtIndex:i];
            
            CustomFormDataRelationModel *customFormDataRelationModel = [[CustomFormDataRelationModel alloc] init];
            customFormDataRelationModel.custom_form_data_relation_id = [[NSUUID UUID] UUIDString];
            customFormDataRelationModel.custom_form_data_id = customFormDataModel.custom_form_data_id;
            customFormDataRelationModel.custom_form_id = customFormModel.custom_form_id;
            //将date由double类型转换为string类型，存入custom_form_data_relation表
            if([customFormModel.custom_form_key isEqualToString:@"create_date"])
            {
                NSTimeInterval timeInterval = customFormDataModel.custom_form_data_time.doubleValue;
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                customFormDataRelationModel.custom_form_data_relation_value = [dateFormatter stringFromDate:date];
            }
            else
            {
                customFormDataRelationModel.custom_form_data_relation_value = [inputValues objectForKey:customFormModel.custom_form_name];
            }
            
            [custom_form_data_relation_list addObject:customFormDataRelationModel];
        }
        customFormDataModel.custom_form_data_relation_list = custom_form_data_relation_list;
        [[DataBaseManager sharedManager] newCustomFormData:customFormDataModel];
        
        //get data and reload tableview
        NSDate *now = [NSDate date];
        double oneWeekAgoDouble = [now timeIntervalSince1970] - 7*24*3600;
        NSDate *oneWeekAgo = [NSDate dateWithTimeIntervalSince1970:oneWeekAgoDouble];
        [safe_self reloadDataFromDate:oneWeekAgo toDate:now];
        
        
        if (removeView)
        {
            [UIView animateWithDuration:[AddNewCustomDataView getAnimationTime] animations:^{
                CGRect frame = safe_self.addNewView.frame;
                safe_self.addNewView.frame = CGRectMake(frame.size.width, [AddNewCustomDataView getY], frame.size.width, frame.size.height);
            } completion:^(BOOL finished) {
                [safe_self.addNewView removeFromSuperview];
                safe_self.addNewView = nil;
            }];
        }
    }];
    
    NSMutableArray *arrValuesAndKeys = [[NSMutableArray alloc] init];
    for (int i=0; i<self.columnList.count; i++)
    {
        // 不允许用户更改创建时间
        NSString *keyName = [[self.columnList objectAtIndex:i] objectForKey:@"name"];
        NSString *keyKey = [[self.columnList objectAtIndex:i] objectForKey:@"key"];
        NSString *keyValue = @"";
        if ([keyKey isEqualToString:@"create_date"])
        {
            continue;
        }
        
        NSDictionary *dicOnePair = [NSDictionary dictionaryWithObject:keyValue forKey:keyName];
        [arrValuesAndKeys addObject:dicOnePair];
    }
    
    [self.addNewView setValuesAndKeys:arrValuesAndKeys ForMode:EditMode];
    
    [self.view addSubview:self.addNewView];
    [UIView animateWithDuration:[AddNewCustomDataView getAnimationTime] animations:^{
        CGRect frame = self.addNewView.frame;
        self.addNewView.frame = CGRectMake(0, [AddNewCustomDataView getY], frame.size.width, frame.size.height);
    }];
}

#pragma mark tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rowList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CUSTOM_FORM_CELL_ID = @"custom_form_cell_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CUSTOM_FORM_CELL_ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CUSTOM_FORM_CELL_ID];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else{// 为了更新tableview cell里面的内容，又不影响重用机制
        while ([cell.contentView.subviews lastObject] != nil)
        {
             [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    
    CustomFormDataModel *customFormDataModel = [self.rowList objectAtIndex:indexPath.row];
    
    NSArray *customFormDataRelationList = customFormDataModel.custom_form_data_relation_list;
    
    int showLabelsCount = customFormDataRelationList.count;
    if (customFormDataRelationList.count > 5)
    {
        showLabelsCount = 5;
    }
    
    for (int i=0; i<showLabelsCount; i++) {
        UIView *v = [self.infoHearderView.subviews objectAtIndex:i];
        CustomFormDataRelationModel *customFormDataRelationModel = [customFormDataRelationList objectAtIndex:i];
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(v.frame.origin.x, 0, v.frame.size.width, 60)];
        countLabel.text = customFormDataRelationModel.custom_form_data_relation_value;
        countLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:countLabel];
    }

    if (indexPath.row % 2)
    {
        [cell setBackgroundColor:BACKGROUND_GRAY];
    }
    
    return cell;
}

#pragma mark tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.addNewView = [[[NSBundle mainBundle] loadNibNamed:@"AddNewCustomDataView" owner:self options:nil] lastObject];
    self.addNewView.isDetailView = YES;
    [self.addNewView.leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [self.addNewView.rightButton setTitle:@"修改" forState:UIControlStateNormal];
    
    __unsafe_unretained CustomFormViewController *safe_self = self;
    
    [self.addNewView setCancelCallBackBlock:^{
        // 取消
        [UIView animateWithDuration:[AddNewCustomDataView getAnimationTime] animations:^{
            CGRect frame = safe_self.addNewView.frame;
            safe_self.addNewView.frame = CGRectMake(frame.size.width, [AddNewCustomDataView getY], frame.size.width, frame.size.height);
        } completion:^(BOOL finished) {
            [safe_self.addNewView removeFromSuperview];
            safe_self.addNewView = nil;
        }];
    }];
    
    [self.addNewView setSaveCallBackBlock:^(BOOL removeView){
        // 保存
        NSDictionary *inputValues = [safe_self.addNewView.scrollView getValuesAndKeys];

        if (!removeView)// 修改数据
        {
            CustomFormDataModel *customFormDataModel = [safe_self.rowList objectAtIndex:indexPath.row];
            NSArray *customFormDataRelationList = customFormDataModel.custom_form_data_relation_list;
            for (int i=0; i<customFormDataRelationList.count; i++)
            {
                CustomFormDataRelationModel *customFormDataRelationModel = [customFormDataRelationList objectAtIndex:i];
                NSString *keyName = [[safe_self.columnList objectAtIndex:i] objectForKey:@"name"];
                NSString *keyKey = [[safe_self.columnList objectAtIndex:i] objectForKey:@"key"];
                if ([keyKey isEqualToString:@"create_date"])
                {
                    continue;
                }
                NSString *keyValue = [inputValues objectForKey:keyName];
                customFormDataRelationModel.custom_form_data_relation_value = keyValue;
                
                [[DataBaseManager sharedManager] modifyCustomFormDataRelation:customFormDataRelationModel];
            }
        }
        else// 增加数据
        {
            CustomFormDataModel *customFormDataModel  = [[CustomFormDataModel alloc] init];
            customFormDataModel.custom_form_data_id   = [[NSUUID UUID] UUIDString];
            customFormDataModel.custom_form_data_per  = @"本店";
            customFormDataModel.custom_form_data_syn  = [NSNumber numberWithBool:NO];
            customFormDataModel.custom_form_data_time = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
            
            NSMutableArray *custom_form_data_relation_list = [NSMutableArray array];
            for (int i=0; i<safe_self.dataRelationList.count; i++)
            {
                CustomFormModel *customFormModel = [safe_self.dataRelationList objectAtIndex:i];
                
                CustomFormDataRelationModel *customFormDataRelationModel = [[CustomFormDataRelationModel alloc] init];
                customFormDataRelationModel.custom_form_data_relation_id = [[NSUUID UUID] UUIDString];
                customFormDataRelationModel.custom_form_data_id = customFormDataModel.custom_form_data_id;
                customFormDataRelationModel.custom_form_id = customFormModel.custom_form_id;
                //
                if([customFormModel.custom_form_key isEqualToString:@"create_date"])
                {
                    NSTimeInterval timeInterval = customFormDataModel.custom_form_data_time.doubleValue;
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                    customFormDataRelationModel.custom_form_data_relation_value = [dateFormatter stringFromDate:date];
                }
                else
                {
                    customFormDataRelationModel.custom_form_data_relation_value = [inputValues objectForKey:customFormModel.custom_form_name];
                }
                
                
                [custom_form_data_relation_list addObject:customFormDataRelationModel];
            }
            customFormDataModel.custom_form_data_relation_list = custom_form_data_relation_list;
            [[DataBaseManager sharedManager] newCustomFormData:customFormDataModel];
        }
        //get data and reload tableview
        NSDate *now = [NSDate date];
        double oneWeekAgoDouble = [now timeIntervalSince1970] - 7*24*3600;
        NSDate *oneWeekAgo = [NSDate dateWithTimeIntervalSince1970:oneWeekAgoDouble];
        [safe_self reloadDataFromDate:oneWeekAgo toDate:now];
        
        if (removeView)
        {
            [UIView animateWithDuration:[AddNewCustomDataView getAnimationTime] animations:^{
                CGRect frame = safe_self.addNewView.frame;
                safe_self.addNewView.frame = CGRectMake(frame.size.width, [AddNewCustomDataView getY], frame.size.width, frame.size.height);
            } completion:^(BOOL finished) {
                [safe_self.addNewView removeFromSuperview];
                safe_self.addNewView = nil;
            }];
        }
        
    }];
    
    
    CustomFormDataModel *customFormDataModel = [self.rowList objectAtIndex:indexPath.row];
    NSArray *customFormDataRelationList = customFormDataModel.custom_form_data_relation_list;
    
    NSMutableArray *arrValuesAndKeys = [[NSMutableArray alloc] init];
    for (int i=0; i<customFormDataRelationList.count; i++)
    {
        CustomFormDataRelationModel *customFormDataRelationModel = [customFormDataRelationList objectAtIndex:i];
        // 不允许用户更改创建时间
        NSString *keyName = [[self.columnList objectAtIndex:i] objectForKey:@"name"];
        NSString *keyKey = [[self.columnList objectAtIndex:i] objectForKey:@"key"];
        NSString *keyValue = customFormDataRelationModel.custom_form_data_relation_value;
        if ([keyKey isEqualToString:@"create_date"])
        {
            continue;
        }
        
        NSDictionary *dicOnePair = [NSDictionary dictionaryWithObject:keyValue forKey:keyName];
        [arrValuesAndKeys addObject:dicOnePair];
    }
    [self.addNewView setValuesAndKeys:arrValuesAndKeys ForMode:ViewMode];
    
    [self.view addSubview:self.addNewView];
    [UIView animateWithDuration:[AddNewCustomDataView getAnimationTime] animations:^{
        CGRect frame = self.addNewView.frame;
        self.addNewView.frame = CGRectMake(0, [AddNewCustomDataView getY], frame.size.width, frame.size.height);
    }];
}

#pragma mark textField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.searchButton.hidden = YES;
    self.addButton1.hidden   = YES;
    self.addButton2.hidden   = YES;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:textField.text];
    self.datePicker.date = date;
}

@end
