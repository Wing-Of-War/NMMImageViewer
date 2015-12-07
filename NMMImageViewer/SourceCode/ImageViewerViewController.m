//
//  ImageViewerViewController.m
//  SGCourseBoard
//
//  Created by 张珏 on 15/12/3.
//  Copyright © 2015年 nomemo. All rights reserved.
//

#import "ImageViewerViewController.h"

@interface ImageViewerViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) NSMutableArray *scrollViews;



@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIGestureRecognizer *tapGesture;


@property (nonatomic, strong) NSArray *imageLinks;

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) CGFloat currentScrollViewWidth;
@property (nonatomic, assign) CGFloat currentScrollViewHeight;

@end

@implementation ImageViewerViewController


+ (void)showInViewController:(UIViewController *)viewCon {
    ImageViewerViewController *viewrVC = [[ImageViewerViewController alloc]init];
    [viewCon presentViewController:viewrVC animated:YES completion:^{
        
    }];
}


- (void)setupTestData {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0 ; i < 3 ; i++) {
        [array addObject:[NSString stringWithFormat:@"TallImage%d.jpg", i+1]];
    }
    self.imageLinks = [NSArray arrayWithArray:array];
}

- (void)setupMainScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor redColor];
    scrollView.pagingEnabled = true;
    [self.view addSubview:scrollView];
    self.mainScrollView = scrollView;
    self.mainScrollView.delegate = self;
}


- (void)setupImageView {
    self.imageViews = [NSMutableArray array];
    self.scrollViews = [NSMutableArray array];
    for (NSString *imageLink in self.imageLinks) {
        UIScrollView *scrollView = [[UIScrollView alloc]init];
        scrollView.maximumZoomScale = 4;
        scrollView.minimumZoomScale = 1;
        scrollView.delegate = self;
        scrollView.backgroundColor = [UIColor grayColor];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageLink]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [scrollView addSubview:imageView];
        imageView.clipsToBounds = true;
        [self.scrollViews addObject:scrollView];
        [self.mainScrollView addSubview:scrollView];
        [self.imageViews addObject:imageView];
    }
    [self redrawScrollView];
}

- (void)redrawScrollView {
    self.mainScrollView.frame = self.view.frame;
    NSInteger imageCount = self.imageViews.count;
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);

    self.currentScrollViewHeight = height;
    self.currentScrollViewWidth = width;
    
    self.mainScrollView.contentSize = CGSizeMake(width * imageCount, height );
    for (int i = 0; i < imageCount; i++) {
        [self resizeImageView:i];
    }
    self.mainScrollView.contentOffset = CGPointMake(self.currentPage * self.currentScrollViewWidth, 0);
}


- (void)resizeImageView:(NSInteger)index {
    UIScrollView *sc = self.scrollViews[index];
    sc.frame = CGRectMake(self.currentScrollViewWidth * index, 0, self.currentScrollViewWidth, self.currentScrollViewHeight);
    UIImageView *iv = self.imageViews[index];
    iv.transform = CGAffineTransformIdentity;
    
    float scaleX = iv.image.size.width/self.currentScrollViewWidth;
    float scaleY = iv.image.size.height/self.currentScrollViewHeight;
    if (scaleX > scaleY) {
        sc.contentSize = CGSizeMake( iv.image.size.width/scaleX , iv.image.size.height / scaleX);
        iv.frame = CGRectMake(0, 0, iv.image.size.width/scaleX, iv.image.size.height / scaleX);

    } else {
        sc.contentSize = CGSizeMake( iv.image.size.width/scaleY , iv.image.size.height / scaleY);
        iv.frame = CGRectMake(0, 0, iv.image.size.width/scaleY, iv.image.size.height / scaleY);

    }
    iv.center = self.mainScrollView.center;
    for (id u in sc.subviews) {
        if (u != iv) {
            [u removeFromSuperview];
        }
    }
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self redrawScrollView];
}


- (void)configureView {
    self.view.backgroundColor = [UIColor blackColor];
}


- (void)dismiss {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTestData];

    [self setupMainScrollView];
    [self setupImageView];
    [self configureView];
    [self setupGestures];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%@", NSStringFromSelector(_cmd));

    
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.mainScrollView) {
        return;
    }
    int page = scrollView.contentOffset.x/self.currentScrollViewWidth;
    if (page == self.currentPage) {
        //没有翻页
        return;
    }
    
    [self resizeImageView:self.currentPage];
    self.currentPage = page;
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView != self.mainScrollView) {
        UIImageView *imageView = self.imageViews[self.currentPage];
        return imageView;
    }
    return nil;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    NSInteger index = [self.scrollViews indexOfObject:scrollView];
    UIImageView *imgView = self.imageViews[index];
    CGSize boundsSize = scrollView.bounds.size;
    CGRect imgFrame = imgView.frame;
    CGSize contentSize = scrollView.contentSize;
    
    CGPoint centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);
    
    // center horizontally
    if (imgFrame.size.width <= boundsSize.width)
      {
        centerPoint.x = boundsSize.width/2;
      }
    
    // center vertically
    if (imgFrame.size.height <= boundsSize.height)
      {
        centerPoint.y = boundsSize.height/2;
      }
    imgView.center = centerPoint;
}


#pragma mark - Gesture

- (void)setupGestures {
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    [self.view addGestureRecognizer:self.tapGesture];
}



@end
