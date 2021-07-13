//
//  MultViewVC.h
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/7/9.
//  Copyright © 2021 linggao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface MultViewVC : UIViewController

@property (strong, nonatomic) GPUImageView *view1;
@property (strong, nonatomic) GPUImageView *view2;
@property (strong, nonatomic) GPUImageView *view3;
@property (strong, nonatomic) GPUImageView *view4;
@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;

@end

NS_ASSUME_NONNULL_END
