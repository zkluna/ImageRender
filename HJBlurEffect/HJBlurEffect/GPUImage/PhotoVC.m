//
//  PhotoVC.m
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/7/8.
//  Copyright © 2021 linggao. All rights reserved.
//

#import "PhotoVC.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoVC ()

@end

@implementation PhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChildren];
    [self setupFilter];
}
- (void)setupChildren {
    CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];
    GPUImageView *primaryView = [[GPUImageView alloc] initWithFrame:mainScreenFrame];
    primaryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.filterSettingsSlider = [[UISlider alloc] initWithFrame:CGRectMake(25.0, mainScreenFrame.size.height - 50.0, mainScreenFrame.size.width - 50.0, 40.0)];
    [_filterSettingsSlider addTarget:self action:@selector(updateSliderValue:) forControlEvents:UIControlEventValueChanged];
    _filterSettingsSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _filterSettingsSlider.minimumValue = 0.0;
    _filterSettingsSlider.maximumValue = 3.0;
    _filterSettingsSlider.value = 1.0;
    [primaryView addSubview:_filterSettingsSlider];
    
    _photoCaptureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _photoCaptureButton.frame = CGRectMake(round(mainScreenFrame.size.width / 2.0 - 150.0 / 2.0), mainScreenFrame.size.height - 90.0, 150.0, 40.0);
    [_photoCaptureButton setTitle:@"Capture Photo" forState:UIControlStateNormal];
    _photoCaptureButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_photoCaptureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [_photoCaptureButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [primaryView addSubview:_photoCaptureButton];
    self.view = primaryView;
}
- (void)setupFilter {
    _stillCamera = [[GPUImageStillCamera alloc] init];
//    _stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _filter = [[GPUImageSketchFilter alloc] init];
//    _filter = [[GPUImageGrayscaleFilter alloc] init];
//    _filter = [[GPUImageKuwaharaFilter alloc] init];  //GPUImageKuwaharaFilter
//    _filter = [[GPUImageColorInvertFilter alloc] init];
//    _filter = [[GPUImagePixellateFilter alloc] init];
    //    filter = [[GPUImageUnsharpMaskFilter alloc] init];
    //    [(GPUImageSketchFilter *)filter setTexelHeight:(1.0 / 1024.0)];
    //    [(GPUImageSketchFilter *)filter setTexelWidth:(1.0 / 768.0)];
    //    filter = [[GPUImageSmoothToonFilter alloc] init];
    //    filter = [[GPUImageSepiaFilter alloc] init];
    //    filter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.5, 0.5, 0.5, 0.5)];
    //    secondFilter = [[GPUImageSepiaFilter alloc] init];
    //    terminalFilter = [[GPUImageSepiaFilter alloc] init];
    //    [filter addTarget:secondFilter];
    //    [secondFilter addTarget:terminalFilter];
        
    //    [filter prepareForImageCapture];
    //    [terminalFilter prepareForImageCapture];
    [_stillCamera addTarget:_filter];
    GPUImageView *filterView = (GPUImageView *)self.view;
    [_filter addTarget:filterView];
    //    [terminalFilter addTarget:filterView];
        
    //    [stillCamera.inputCamera lockForConfiguration:nil];
    //    [stillCamera.inputCamera setFlashMode:AVCaptureFlashModeOn];
    //    [stillCamera.inputCamera unlockForConfiguration];
    [_stillCamera startCameraCapture];
    //    UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];
    //    memoryPressurePicture1 = [[GPUImagePicture alloc] initWithImage:inputImage];
    //
    //    memoryPressurePicture2 = [[GPUImagePicture alloc] initWithImage:inputImage];
}
- (void)updateSliderValue:(UISlider *)sender {
    [(GPUImageSketchFilter *)_filter setEdgeStrength:sender.value];
//    [(GPUImagePixellateFilter *)_filter setFractionalWidthOfAPixel:sender.value];
//    [(GPUImageGammaFilter *)_filter setGamma:sender.value];
}
- (void)takePhoto:(UIButton *)sender {
    [self.photoCaptureButton setEnabled:NO];
    __weak typeof(self) weakSelf = self;
    [_stillCamera capturePhotoAsJPEGProcessedUpToFilter:_filter withCompletionHandler:^(NSData *processedJPEG, NSError *error) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:processedJPEG metadata:weakSelf.stillCamera.currentCaptureMetadata completionBlock:^(NSURL *assetURL, NSError *error2) {
             if (error2) {
                 NSLog(@"ERROR: the image failed to be written");
             } else {
                 NSLog(@"PHOTO SAVED - assetURL: %@", assetURL);
             }
             runOnMainQueueWithoutDeadlocking(^{
                 [weakSelf.photoCaptureButton setEnabled:YES];
             });
         }];
    }];
}

@end
