//  
//  ViewController.m
//  顶部放大
//
//  Created by 张江东 on 16/10/26.
//  Copyright © 2016年 58kuaipai. All rights reserved.
//

#import "ViewController.h"
#import "TransformerHeaderController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(next)];
    self.navigationItem.rightBarButtonItem = item;
    
    
}

- (void)next{
    
    TransformerHeaderController *vc = [[TransformerHeaderController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}



@end
