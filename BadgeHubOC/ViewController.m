//
//  ViewController.m
//  BadgeHubOC
//
//  Created by 月成 on 2020/2/26.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "ViewController.h"
#import "BadgeHub.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 200, 100, 100)];
    view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:view];
    
    BadgeHub *hub = [[BadgeHub alloc] initWithView:view];
    
    [hub increment];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hub bump];
    });
}


@end
