//
//  ViewController.m
//  WBCarouselViewDemo
//
//  Created by 廖文博 on 16/8/18.
//  Copyright © 2016年 wenbo. All rights reserved.
//

#import "ViewController.h"
#import "WBCarouselView.h"
#import <Masonry.h>
#define WBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define WBRandomColor WBColor(arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256))

@interface ViewController ()<WBCarouselViewDelegate, WBCarouselViewDataSource>
@property (nonatomic, weak) UIView *testView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WBCarouselView *testView = [WBCarouselView new];
    [self.view addSubview:testView];
    [testView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(100);
    }];
    self.testView = testView;
    testView.delegate = self;
    testView.dataSource = self;
    testView.autoScrollEnable = YES;
    
}

- (void)carouseView:(WBCarouselView *)carouseView willSetImageView:(UIImageView *)imageView index:(NSInteger)index
{
   
    if(index == 0)
    {
        imageView.backgroundColor = [UIColor redColor];
    }
    else if( index == 2)
    {
        imageView.backgroundColor = [UIColor greenColor];
    }
    else
    {
        imageView.backgroundColor = WBRandomColor;
    }
}

- (NSTimeInterval)scollTimeOfCarouseView:(WBCarouselView *)carouseView
{
    return 4;
    
}

- (NSInteger)numberOfImageViewCountCarouseView:(WBCarouselView *)carouseView
{
    return 3;
}

- (void)carouseView:(WBCarouselView *)carouseView DidClickImageViewAtIndex:(NSInteger)index
{
    NSLog(@"%ld",index);
    [carouseView reloadImageAtIndex:index];
}

- (void)carouseView:(WBCarouselView *)carouseView DidEndScrollIndexOfImageView:(NSInteger)index
{
    NSLog(@"%ld",index);
}

- (BOOL)carouseViewNeedCirculate:(WBCarouselView *)carouseView
{
    return YES;
}

//- (BOOL)carouseViewNeedDragEndCirculate:(WBCarouselView *)carouseView
//{
//    return YES;
//}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    self.testView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100);
}

@end
