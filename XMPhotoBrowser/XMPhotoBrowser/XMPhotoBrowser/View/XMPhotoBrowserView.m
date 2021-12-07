//
//  XMPhotoBrowserView.m
//  XMPhotoBrowser
//
//  Created by weipengcheng on 2021/11/18.
//

#import "XMPhotoBrowserView.h"

//View
#import "XMPhotoView.h"

//宏定义
#define kPadding 5
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)
#define kOffsetTagIndex(index) (index + kPhotoViewTagOffset)

@interface XMPhotoBrowserView () <UIScrollViewDelegate>
///承载所有子视图的scrollview
@property (nonatomic, strong) UIScrollView *scrollView;
///当前活跃的所有子视图
@property (nonatomic, strong) NSMutableArray *visibleCells;
///复用池中的cell
@property (nonatomic, strong) NSMutableArray *reusableCells;
@end

@implementation XMPhotoBrowserView

#pragma mark init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configSubViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self configSubViews];
    }
    return self;
}

#pragma mark ui
- (void)configSubViews {
    [self addSubview:self.scrollView];
    CGRect frame = self.bounds;
    frame.origin.x -= kPadding;
    frame.size.width += (2 * kPadding);
    self.scrollView.frame = frame;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    CGFloat padding = kPadding;
    CGFloat width = frame.size.width;
    CGFloat height = self.bounds.size.height;

    for (NSInteger i = 0; i < 1; i ++) {
        XMPhotoView *photoView = [self dequeueReuseableCellWithIndexPath:[NSIndexPath indexPathForRow:kOffsetTagIndex(i) inSection:0]];
        CGRect frame = CGRectMake(width * i + (i + 1)*padding, 0, width - 2 * padding, height);
        photoView.frame = frame;
        [self.scrollView addSubview:photoView];
    }
    [self makeCellReusable:[self dequeueReuseableCellWithIndexPath:[NSIndexPath indexPathForRow:kOffsetTagIndex(1) inSection:0]]];
    self.scrollView.contentSize = CGSizeMake(frame.size.width * 20, height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    frame.size.width += (2 * kPadding);
    CGFloat width = frame.size.width;
    CGFloat height = self.bounds.size.height;
    self.scrollView.contentSize = CGSizeMake(frame.size.width * 20, height);
    for (XMPhotoView *photoView in self.visibleCells) {
        [self updateIndexPhotoViewFrame:kPhotoViewIndex(photoView) scrollView:self.scrollView];
    }
}

#pragma mark 复用相关
///获取一个可用的cell，复用池中有可用的view时从复用池中取，没有时新建一个view返回
- (XMPhotoView *)dequeueReuseableCellWithIndexPath:(NSIndexPath *)indexPath {
    XMPhotoView *dequeuedItem = nil;
    if (!self.reusableCells.count) {
        dequeuedItem = [[XMPhotoView alloc] init];
        [self makeCellVisible:dequeuedItem];
    } else {
        dequeuedItem = [self.reusableCells firstObject];
    }
    dequeuedItem.tag = indexPath.row;
    [self makeCellVisible:dequeuedItem];
    return dequeuedItem;
}

///标记一个view为可用状态
- (void)makeCellReusable:(XMPhotoView *)photoView {
    if (photoView.tag == -1) {
        return;
    }
    photoView.tag = -1;
    [self.reusableCells addObject:photoView];
    [self.visibleCells removeObject:photoView];

}

///标记一个view为活跃状态
- (void)makeCellVisible:(XMPhotoView *)photoView {
    [self.visibleCells addObject:photoView];
    [self.reusableCells removeObject:photoView];
}

#pragma mark 调整活跃区域view的布局

///更新活跃区域
- (void)updateVisibleRect:(UIScrollView *)scrollView {
    ///活跃区域
    CGRect visibleRect = CGRectMake(MAX(scrollView.contentOffset.x, 0), 0, scrollView.frame.size.width, scrollView.frame.size.height);
    //准备上一个cell
    {
        NSInteger currentIndex = scrollView.contentOffset.x /( scrollView.bounds.size.width - kPadding * 2);

        NSInteger index = currentIndex - 1;
        if (index < 20 && index >= 0) {
            [self updateIndexPhotoViewFrame:index scrollView:scrollView];
        }
    }
    //准备下一个cell
    {
        NSInteger currentIndex = scrollView.contentOffset.x / (scrollView.bounds.size.width - kPadding * 2);

        NSInteger index = currentIndex + 1;
        if (index < 20 && index >= 1) {
            [self updateIndexPhotoViewFrame:index scrollView:scrollView];        }
    }
    //处理当前的cell
    {
        NSInteger currentIndex = scrollView.contentOffset.x / (scrollView.bounds.size.width - kPadding * 2);
        NSInteger index = currentIndex;
        if (currentIndex < 20 && currentIndex >= 0) {
            [self updateIndexPhotoViewFrame:index scrollView:scrollView];
        }
    }
    for (UIView *itemView in scrollView.subviews) {
        if ([itemView isKindOfClass:[XMPhotoView class]]) {
            XMPhotoView *phtotView = (XMPhotoView *)itemView;
            if (!CGRectIntersectsRect(visibleRect, itemView.frame)) {
                [self makeCellReusable:phtotView];
                [phtotView removeFromSuperview];
            }
        }
    }
}

#pragma mark 更新对应index下的photoViewFrame
- (void)updateIndexPhotoViewFrame:(NSInteger)index scrollView:(UIScrollView *)scrollView{
    XMPhotoView *photoView = [scrollView viewWithTag:kOffsetTagIndex(index)];
    if (!photoView) {
        photoView =  [self dequeueReuseableCellWithIndexPath:[NSIndexPath indexPathForRow:kOffsetTagIndex(index) inSection:0]];
        [scrollView addSubview:photoView];
    }
    CGFloat x = index * scrollView.bounds.size.width + kPadding;
    photoView.frame = CGRectMake(x, 0, self.bounds.size.width, scrollView.frame.size.height);
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateVisibleRect:scrollView];
}

#pragma mark lazyMethod
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}

- (NSMutableArray *)visibleCells {
    if (!_visibleCells) {
        _visibleCells = [NSMutableArray array];
    }
    return _visibleCells;
}

- (NSMutableArray *)reusableCells {
    if (!_reusableCells) {
        _reusableCells = [NSMutableArray array];
    }
    return _reusableCells;
}
@end
