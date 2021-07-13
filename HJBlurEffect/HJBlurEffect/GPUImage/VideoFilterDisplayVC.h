//
//  VideoFilterDisplayVC.h
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/6/29.
//  Copyright © 2021 linggao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VideoFilteringCallback

- (void)finishedTestWithAverageTimesForCPU:(CGFloat)cpuTime coreImage:(CGFloat)coreImageTime gpuImage:(CGFloat)gpuImageTime;

@end

@interface VideoFilterDisplayVC : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (assign, nonatomic) CGFloat totalFrameTimeForCPU;
@property (assign, nonatomic) CGFloat totalFrameTimeForCoreImage;
@property (assign, nonatomic) CGFloat totalFrameTimeForGPUImage;
@property (assign, nonatomic) NSUInteger numberOfCPUFramesCaptured;
@property (assign, nonatomic) NSUInteger numberOfCoreImageFramesCaptured;
@property (assign, nonatomic) NSUInteger numberOfGPUImageFramesCaptured;
@property (strong, nonatomic) GLKView *videoDisplayView;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoOutput;
@property (strong, nonatomic) CIContext *coreImageContext;
@property (strong, nonatomic) CIFilter *coreImageFilter;
@property (assign, nonatomic) GLuint renderBuffer;
@property (assign, nonatomic) BOOL processUsingCPU;
@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;
@property (strong, nonatomic) GPUImageOutput <GPUImageInput> *benchmarkedGPUImageFilter;
@property (strong, nonatomic) GPUImageView *filterView;
@property (weak, nonatomic) id <VideoFilteringCallback> delegate;
@property (strong, nonatomic) EAGLContext *openGLESContext;

- (void)startAVFoundationVideoProcessing;
- (void)displayVideoForCPU;
- (void)displayVideoForCoreImage;
- (void)displayVideoForGPUImage;

@end

NS_ASSUME_NONNULL_END
