//
//  XMPhotoView.m
//  XMPhotoBrowser
//
//  Created by weipengcheng on 2021/11/18.
//

#import "XMPhotoView.h"

#import "XMPhotoViewScrollView.h"

@interface XMPhotoView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *photoContainerView;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation XMPhotoView

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
    [self addSubview:self.photoContainerView];
    [self.photoContainerView addSubview:self.imageView];
    self.photoContainerView.frame = self.bounds;
    self.photoContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.photoImage = [UIImage imageNamed:@"test"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.photoContainerView.frame = self.bounds;
    if (self.photoImage) {
        CGFloat scale = self.photoImage.size.width / self.photoImage.size.height;
        //宽度设置为container宽度
        CGFloat width = self.photoContainerView.bounds.size.width;
        CGFloat height = width / scale;
        if (UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeLeft || UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeRight) {
            height = self.photoContainerView.bounds.size.height;
            width = height * scale;
        }
        CGRect frame = CGRectMake(0, 0, width, height);
        CGPoint center = CGPointMake(self.photoContainerView.center.x, self.photoContainerView.center.y);
        self.imageView.frame = frame;
        self.imageView.center = center;
        CGFloat scaleH = self.photoContainerView.bounds.size.height / self.photoImage.size.height;
        CGFloat scaleW = self.photoContainerView.bounds.size.width / self.photoImage.size.width;
        CGFloat realZoomScale = MAX(MAX(scaleH, scaleW), 2);
        self.photoContainerView.minimumZoomScale = 1.0;
        self.photoContainerView.maximumZoomScale = realZoomScale;
        self.photoContainerView.contentSize = self.imageView.bounds.size;
    } else {
        self.imageView.frame = self.photoContainerView.bounds;
    }
}

#pragma mark setter
- (void)setPhotoImage:(UIImage *)photoImage {
    _photoImage = photoImage;
    self.imageView.image = photoImage;
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}


#pragma mark lazyMethod
- (UIScrollView *)photoContainerView {
    if (!_photoContainerView) {
        _photoContainerView = [[UIScrollView alloc] init];
        _photoContainerView.backgroundColor = UIColor.clearColor;
        _photoContainerView.delegate = self;
        _photoContainerView.maximumZoomScale = 2;
        _photoContainerView.minimumZoomScale = 1;
        _photoContainerView.showsVerticalScrollIndicator = NO;
        _photoContainerView.showsHorizontalScrollIndicator = NO;
        _photoContainerView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _photoContainerView.clipsToBounds = YES;
        _photoContainerView.multipleTouchEnabled = YES; 
    }
    return _photoContainerView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}
@end
