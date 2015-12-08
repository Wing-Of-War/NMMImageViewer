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

@property (nonatomic, assign) TestType type;

@end

@implementation ImageViewerViewController


+ (void)showInViewController:(UIViewController *)viewCon testType:(TestType)type{
    ImageViewerViewController *viewrVC = [[ImageViewerViewController alloc]init];
    viewrVC.type = type;
    [viewCon presentViewController:viewrVC animated:YES completion:^{
        
    }];
}


- (void)setupTestData {
    NSMutableArray *array = [NSMutableArray array];
    
    
    switch (self.type) {
        case TestType_Tall:
            for (int i = 0 ; i < 3 ; i++) {
                [array addObject:[NSString stringWithFormat:@"TallImage%d.jpg", i+1]];
            }
            break;
            case TestType_Small:
            for (int i = 0 ; i < 3 ; i++) {
                [array addObject:[NSString stringWithFormat:@"SmallImage%d.png", i+1]];
            }
            break;
            case TestType_Normal:
            for (int i = 0 ; i < 3 ; i++) {
                [array addObject:[NSString stringWithFormat:@"ppt%d.JPG", i+1]];
            }
            break;
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



#pragma mark - ImageViews Adjust

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
    
    if ([self imageViewShouldSetToTop:iv.image]) {
        //Setup tall image to Viewre.
        iv.frame = CGRectMake(0, 0, self.currentScrollViewWidth, iv.image.size.height / scaleX);
        sc.contentSize = CGSizeMake( self.currentScrollViewWidth , iv.image.size.height / scaleX);
        
    } else if ([self imageViewShouldSetToCenter:iv.image]){
        iv.frame = CGRectMake(0, 0, iv.image.size.width, iv.image.size.height );
        sc.contentSize = CGSizeMake(iv.image.size.width, iv.image.size.height);
        iv.center = self.mainScrollView.center;
    } else {
        float scaleY = iv.image.size.height/self.currentScrollViewHeight;
        if (scaleX > scaleY) {
            sc.contentSize = CGSizeMake( iv.image.size.width/scaleX , iv.image.size.height / scaleX);
            iv.frame = CGRectMake(0, 0, iv.image.size.width/scaleX, iv.image.size.height / scaleX);
            
        } else {
            sc.contentSize = CGSizeMake( iv.image.size.width/scaleY , iv.image.size.height / scaleY);
            iv.frame = CGRectMake(0, 0, iv.image.size.width/scaleY, iv.image.size.height / scaleY);
            
        }
        iv.center = self.mainScrollView.center;
    }
    
    for (id u in sc.subviews) {
        if (u != iv) {
            [u removeFromSuperview];
        }
    }
}

- (BOOL)imageViewShouldSetToTop:(UIImage *)image {
    if ((image.size.width > self.currentScrollViewWidth * 0.75) &&
        (image.size.height / image.size.width > self.currentScrollViewHeight/self.currentScrollViewWidth)) {
        return true;
    }
    return false;
}

- (BOOL)imageViewShouldSetToCenter:(UIImage *)image {
    if ((image.size.width < self.currentScrollViewWidth) && (image.size.height < self.currentScrollViewHeight)) {
        return true;
    }
    return false;
}




#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.mainScrollView) {
        return;
    }
    int page = scrollView.contentOffset.x/self.currentScrollViewWidth;
    if (page == self.currentPage) {
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
