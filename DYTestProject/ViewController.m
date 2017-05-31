//
//  ViewController.m
//  DYTestProject
//
//  Created by ZeroDY on 2017/5/19.
//  Copyright © 2017年 ZeroDY. All rights reserved.
//

#import "ViewController.h"

#if DEV
#define SERVER_URL @"这是DEV环境"
#define API_TOKEN @"qerqwerqw"
#elif UAT
#define SERVER_URL @"这是UAT环境"
#define API_TOKEN @"DI2023409jf90ew"
#else
#define SERVER_URL @"这是正式环境"
#define API_TOKEN @"71a629j0f090232"
#endif

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@ --- %@",SERVER_URL,API_TOKEN);
    
    DYViewBorderRadius(self.view, 20, 2, [UIColor redColor]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
