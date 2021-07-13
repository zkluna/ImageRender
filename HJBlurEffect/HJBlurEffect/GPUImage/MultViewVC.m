//
//  MultViewVC.m
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/7/9.
//  Copyright © 2021 linggao. All rights reserved.
//

#import "MultViewVC.h"

@interface MultViewVC ()

@end

@implementation MultViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChildren];
}
- (void)setupChildren {
    CGRect mainScreenFrame = [UIScreen mainScreen].bounds;
    UIView *primaryView = [[UIView alloc] initWithFrame:mainScreenFrame];
    primaryView.backgroundColor = [UIColor blueColor];
    self.view = primaryView;
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    CGFloat halfWidth = round(mainScreenFrame.size.width / 2.0);
    CGFloat halfHeight = round(mainScreenFrame.size.height / 2.0);
    _view1 = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, halfWidth, halfHeight)];
    _view2 = [[GPUImageView alloc] initWithFrame:CGRectMake(halfWidth, 0, halfWidth, halfHeight)];
    _view3 = [[GPUImageView alloc] initWithFrame:CGRectMake(0, halfHeight, halfWidth, halfHeight)];
    _view4 = [[GPUImageView alloc] initWithFrame:CGRectMake(halfWidth, halfHeight, halfWidth, halfHeight)];
    [self.view addSubview:_view1];
    [self.view addSubview:_view2];
    [self.view addSubview:_view3];
    [self.view addSubview:_view4];
    
    GPUImageFilter *filter1 = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"Shader1"];
    GPUImageFilter *filter2 = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"Shader2"];
    GPUImageSepiaFilter *filter3 = [[GPUImageSepiaFilter alloc] init];
    
    [filter1 forceProcessingAtSize:_view2.sizeInPixels];
    [filter2 forceProcessingAtSize:_view3.sizeInPixels];
    [filter3 forceProcessingAtSize:_view4.sizeInPixels];
    
    [_videoCamera addTarget:_view1];
    
    [_videoCamera addTarget:filter1];
    [filter1 addTarget:_view2];
    
    [_videoCamera addTarget:filter2];
    [filter2 addTarget:_view3];
    
    [_videoCamera addTarget:filter3];
    [filter3 addTarget:_view4];
    
    [_videoCamera startCameraCapture];;
}

@end
