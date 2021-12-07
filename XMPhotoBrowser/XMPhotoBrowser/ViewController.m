//
//  ViewController.m
//  XMPhotoBrowser
//
//  Created by weipengcheng on 2021/10/29.
//

#import "ViewController.h"
#import "XMPhotoBrowserView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    XMPhotoBrowserView *photoView = [[XMPhotoBrowserView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:photoView];
    photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


@end
