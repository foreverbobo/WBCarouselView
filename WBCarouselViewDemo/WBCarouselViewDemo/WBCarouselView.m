//
//  WBCarouselView.m
//  WBCarouselViewDemo
//
//  Created by 廖文博 on 16/8/18.
//  Copyright © 2016年 wenbo. All rights reserved.
//

#import "WBCarouselView.h"

#define kCirclate [self.delegate respondsToSelector:@selector(carouseViewNeedCirculate:)] ? [self.delegate carouseViewNeedCirculate:self] : NO

@interface WBCarouselViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation WBCarouselViewCell

- (UIImageView *)imageView
{
    if(!_imageView)
    {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

@end



@interface WBCarouselView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL circlate;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL dragEndCircle;
@property (nonatomic, assign) BOOL isFirstLayout;
@end

@implementation WBCarouselView



- (instancetype)init
{
    self = [super init];
    if (self) {
        [self collectionView];
        [self setUpViewConstrain];
        self.autoScrollEnable = NO;
        self.isFirstLayout = YES;
    }
    return self;
}

- (void)setAutoScrollEnable:(BOOL)autoScrollEnable
{
    if(autoScrollEnable)
    {
        [self timer];
    }
    else
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (BOOL)autoScrollEnable
{
    return _timer;
}


- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)reloadImageAtIndex:(NSInteger)index
{
    if(kCirclate)
    {
        if(index == 0)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:self.count + 1 inSection:0];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath , indexPath2]];
        }
        else if(index == self.count)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:self.count inSection:0];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath , indexPath2]];
        }
        else
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index + 1 inSection:0];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }
    else
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.circlate = kCirclate;
    if([self.dataSource respondsToSelector:@selector(numberOfImageViewCountCarouseView:)])
    {
        self.count = [self.dataSource numberOfImageViewCountCarouseView:self];
    }
    else
    {
         NSAssert(0, @"请事先carouse的delegate的返回ImageView的个数");
    }
    return self.circlate ? self.count + 2 : self.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WBCarouselViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if([self.dataSource respondsToSelector:@selector(carouseView:willSetImageView:index:)])
    {
        NSInteger row;
        if(self.circlate)
        {
            if(indexPath.row == 0)
            {
                row = self.count - 1;
            }
            else if(indexPath.row == self.count + 1)
            {
                row = 0;
            }
            else
            {
                row = indexPath.row - 1;
            }
        }
        else
        {
            row = indexPath.row;
        }
        
        [self.dataSource carouseView:self willSetImageView:cell.imageView index:row];
    }
    else
    {
        NSAssert(0, @"请事先carouse的delegate的setImageView");
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if([self.delegate respondsToSelector:@selector(carouseView:DidClickImageViewAtIndex:)])
    {
        NSInteger row;
        if(self.circlate)
        {
            if(indexPath.row == 0)
            {
                row = self.count - 1;
            }
            else if(indexPath.row == self.count + 1)
            {
                row = 0;
            }
            else
            {
                row = indexPath.row - 1;
            }
        }
        else
        {
            row = indexPath.row;
        }
        [self.delegate carouseView:self DidClickImageViewAtIndex:row];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(self.layer.frame.size.width, self.layer.frame.size.height);
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger row = scrollView.contentOffset.x / self.layer.frame.size.width - 1;
    NSInteger index = scrollView.contentOffset.x / self.layer.frame.size.width + 0.5;
    if(kCirclate)
    {
        index = index - 1;
        if(index == self.count)
        {
            index = 0;
        }
        if(index == -1)
        {
            index = 2;
        }
        
        NSLog(@"%ld",index);
    }
    if([self.delegate respondsToSelector:@selector(carouseView:DidEndScrollIndexOfImageView:)])
    {
        [self.delegate carouseView:self DidEndScrollIndexOfImageView:index];
    }
    
    
//    NSLog(@"%ld",row);
    if(kCirclate)
    {
        if(row == self.count )
        {
            NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        else
        {
            if(row == -1)
            {
                NSIndexPath *index = [NSIndexPath indexPathForRow:self.count  inSection:0];
                [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            }
        }
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if([self.delegate respondsToSelector:@selector(carouseViewNeedDragEndCirculate:)])
    {
        self.dragEndCircle = [self.delegate carouseViewNeedDragEndCirculate:self];
    }
    else
    {
        self.dragEndCircle = NO;
    }
}

- (void)timerRun
{
    if(self.dragEndCircle)
    {
        [self.timer invalidate];
        self.timer = nil;
        return;
    }
    
    NSInteger row = self.collectionView.contentOffset.x / self.layer.frame.size.width;
    
    if(kCirclate)
    {
        NSIndexPath *index = [NSIndexPath indexPathForRow:row + 1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
    else
    {
        if(row == self.count - 1)
        {
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
        else
        {
            NSIndexPath *index = [NSIndexPath indexPathForRow:row + 1 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
    }
}



- (void)setUpViewConstrain
{
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    //logoImageView右侧与父视图右侧对齐
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    //logoImageView顶部与父视图顶部对齐
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *bottonConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    leftConstraint.active = YES;
    rightConstraint.active = YES;
    topConstraint.active = YES;
    bottonConstraint.active = YES;
}

- (NSTimer *)timer
{
    if(!_timer)
    {
        NSTimeInterval time;
        if([self.delegate respondsToSelector:@selector(scollTimeOfCarouseView:)])
        {
            time = [self.delegate scollTimeOfCarouseView:self];
        }
        else
        {
            time = 2;
        }
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:@"NSEventTrackingRunLoopMode"];
    }
    return _timer;
}



- (UICollectionView *)collectionView
{
    if(!_collectionView)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        [self addSubview:_collectionView];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[WBCarouselViewCell class] forCellWithReuseIdentifier:@"Cell"];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = NO;
        
    }
    return _collectionView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView setCollectionViewLayout:layout animated:NO];
    CGFloat width = self.layer.bounds.size.width;
    CGPoint contentOffSet;
    contentOffSet.y = 0;
    NSInteger index = self.collectionView.contentOffset.x / width + 0.5;
    contentOffSet.x = index * width;
    self.collectionView.contentOffset = contentOffSet;
    if(self.isFirstLayout)
    {
        if(kCirclate)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(carouseView:DidEndScrollIndexOfImageView:)])
            {
                [self.delegate carouseView:self DidEndScrollIndexOfImageView:0];
            }
        }
        self.isFirstLayout = NO;
    }
    
}

@end
