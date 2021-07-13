//
//  SimpleImageVC.h
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/6/29.
//  Copyright © 2021 linggao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface SimpleImageVC : UIViewController

@property (strong, nonatomic) GPUImagePicture *sourcePicture;
@property (strong, nonatomic) GPUImageOutput <GPUImageInput> *sepiaFilter;
@property (strong, nonatomic) GPUImageOutput <GPUImageInput> *sepiaFilter2;
@property (strong, nonatomic) UISlider *imageSileder;

@end

NS_ASSUME_NONNULL_END
