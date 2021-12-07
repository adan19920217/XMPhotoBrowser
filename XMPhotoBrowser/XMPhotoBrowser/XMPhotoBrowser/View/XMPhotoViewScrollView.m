//
//  XMPhotoViewScrollView.m
//  XMPhotoBrowser
//
//  Created by weipengcheng on 2021/11/18.
//

#import "XMPhotoViewScrollView.h"

@implementation XMPhotoViewScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
