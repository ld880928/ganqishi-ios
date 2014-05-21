//
//  LogInViewController.m
//  ganqishi
//
//  Created by Xing Kevin on 14-5-19.
//  Copyright (c) 2014年 colin. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController ()

@property (weak, nonatomic) IBOutlet UIButton *statePOS;
@property (weak, nonatomic) IBOutlet UIButton *stateServer;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
    NSLog(@"%f", offsetY);
    
    [UIView animateWithDuration:0.3f animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, offsetY, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
}

- (IBAction)loginSystem:(id)sender
{
    NSString *userNameStr = self.userName.text;
    NSString *passwordStr = self.password.text;
    NSLog(@"%@ %@", userNameStr, passwordStr);
}

- (IBAction)settingsSystem:(id)sender
{
    
}

@end
