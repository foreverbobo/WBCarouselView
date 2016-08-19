//
//  WBCarouselView.h
//  WBCarouselViewDemo
//
//  Created by 廖文博 on 16/8/18.
//  Copyright © 2016年 wenbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WBCarouselView;

@protocol WBCarouselViewDataSource <NSObject>
/** 轮播图每个imageView的设置 */
- (void)carouseView:(WBCarouselView *)carouseView willSetImageView:(UIImageView *)imageView index:(NSInteger)index;
/** 轮播图返回imageView的个数 */
- (NSInteger)numberOfImageViewCountCarouseView:(WBCarouselView *)carouseView;


@end

@protocol WBCarouselViewDelegate <NSObject>


@optional
/** 点击轮播图的index */
- (void)carouseView:(WBCarouselView *)carouseView DidClickImageViewAtIndex:(NSInteger)index;
/** 点击轮播图是否循环 */
- (BOOL)carouseViewNeedCirculate:(WBCarouselView *)carouseView;
/** 点击轮播图拖拽 是否 停止循环 */
- (BOOL)carouseViewNeedDragEndCirculate:(WBCarouselView *)carouseView;
/** 轮播图滚动一次 返回的imageView是第几个ImageView */
- (void)carouseView:(WBCarouselView *)carouseView DidEndScrollIndexOfImageView:(NSInteger)index;

@end

@interface WBCarouselView : UIView

@property (nonatomic, weak) id<WBCarouselViewDelegate>delegate;
@property (nonatomic, weak) id<WBCarouselViewDataSource>dataSource;

@property (nonatomic, assign) BOOL autoScrollEnable;

/** 取消定时循环  默认是定时蓄暖 */
- (void)cancelCircle;

- (void)reloadData;

- (void)reloadImageAtIndex:(NSInteger)index;

@end
