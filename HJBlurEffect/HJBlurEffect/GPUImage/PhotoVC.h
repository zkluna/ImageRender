//
//  PhotoVC.h
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/7/8.
//  Copyright © 2021 linggao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoVC : UIViewController

@property (strong, nonatomic) GPUImageStillCamera *stillCamera;
@property (strong, nonatomic) GPUImageOutput <GPUImageInput> *filter;
@property (strong, nonatomic)GPUImageOutput <GPUImageInput > *secondFilter;
@property (strong, nonatomic) GPUImageOutput <GPUImageInput> *terminalFilter;
@property (strong, nonatomic) UISlider *filterSettingsSlider;
@property (strong, nonatomic) UIButton *photoCaptureButton;
@property (strong, nonatomic) GPUImagePicture *memoryPressurePicture1;
@property (strong, nonatomic) GPUImagePicture *memoryPressurePicture2;

- (void)updateSliderValue:(UISlider *)sender;
- (void)takePhoto:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
