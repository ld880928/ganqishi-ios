//
//  LogInViewController.m
//  ganqishi
//
//  Created by Xing Kevin on 14-5-19.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import "LogInViewController.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>

@interface LogInViewController ()

@property (weak, nonatomic) IBOutlet UIButton *statePOS;
@property (weak, nonatomic) IBOutlet UIButton *stateServer;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *loginFailMsg;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation LogInViewController

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
    self.scrollView.bounces = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    //    self.extendedLayoutIncludesOpaqueBars = YES;
    //    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect rect = [keyboardBoundsValue CGRectValue];
    CGFloat offsetY = rect.size.width;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, offsetY, 0.0);
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - offsetY);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    [self.scrollView scrollRectToVisible:CGRectMake(0, -460, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect rect = [keyboardBoundsValue CGRectValue];
    CGFloat offsetY = rect.size.width;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - offsetY);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)loginSystem:(id)sender
{
    self.loginFailMsg.hidden = YES;
    
    NSString *userNameStr = self.userName.text;
    NSString *passwordStr = self.password.text;
    NSLog(@"%@ %@", userNameStr, passwordStr);
    
    NSString *passwordMD5 = [self md5:passwordStr];
    NSLog(@"%@", passwordMD5);
    
    NSString *urlString = @"http://172.27.72.111.8080/boh/annonymity/demo/test";
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:userNameStr, @"username", passwordMD5, @"password", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    //模拟回值
    NSString *loginRespPath = [[NSBundle mainBundle] pathForResource:@"LoginResp" ofType:@"plist"];
    NSDictionary *responseObject = [NSDictionary dictionaryWithContentsOfFile:loginRespPath];
    if ([[responseObject objectForKey:@"code"] isEqualToString:@"1001"])// 请求成功
    {
        // 存储用户信息
        NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
        [settings setObject:[responseObject objectForKey:@"users"] forKey:@"users"];
        [settings writeToFile:settingsPath atomically:YES];
        UIViewController *navigationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"navID"];
        [self presentViewController:navigationVC animated:YES completion:nil];
    }
    else
    {
        self.loginFailMsg.hidden = NO;
    }
    
    //    NSError *error = nil;
    //    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    //    if (error)
    //    {
    //        NSLog(@"Unsupported JSON Format");
    //    }
    //    NSDictionary *dicInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    //    NSLog(@"%@", dicInfo);
    
}

- (IBAction)settingsSystem:(id)sender
{
    
}

- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
