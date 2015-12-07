//
//  ImageViewerViewController.h
//  SGCourseBoard
//
//  Created by 张珏 on 15/12/3.
//  Copyright © 2015年 nomemo. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, TestType) {
    TestType_Tall,
    TestType_Small,
};

@interface ImageViewerViewController : UIViewController

+ (void)showInViewController:(UIViewController *)viewCon testType:(TestType)type;

@end
