//
//  VideoFilterDisplayVC.m
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/6/29.
//  Copyright © 2021 linggao. All rights reserved.
//

#import "VideoFilterDisplayVC.h"

#define BLURSIGMA 4.0

@interface VideoFilterDisplayVC ()

@end

@implementation VideoFilterDisplayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self displayVideoForCPU];
}
- (void)startAVFoundationVideoProcessing {
    AVCaptureDevice *backFacingCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            backFacingCamera = device;
        }
    }
    self.captureSession = [[AVCaptureSession alloc] init];
    NSError *error = nil;
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:backFacingCamera error:&error];
    if ([self.captureSession canAddInput:self.videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [_videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [_videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    if ([_captureSession canAddOutput:_videoOutput]) {
        [_captureSession addOutput:_videoOutput];
    } else {
        NSLog(@"Couldn't add video output");
    }
    [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
}
- (void)displayVideoForCPU {
    self.totalFrameTimeForCPU = 0.0;
    self.numberOfCPUFramesCaptured = 0;
    [self startAVFoundationVideoProcessing];
    self.processUsingCPU = YES;
    [self.captureSession startRunning];
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [self.captureSession stopRunning];
        self.captureSession = nil;
        self.videoInput = nil;
        self.videoOutput = nil;
        [self displayVideoForCoreImage];
    });
}
- (void)displayVideoForCoreImage {
    self.totalFrameTimeForCoreImage = 0.0;
    self.numberOfCoreImageFramesCaptured = 0;
    self.openGLESContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.openGLESContext) {
        NSLog(@"Failed to create ES Context");
    }
    [EAGLContext setCurrentContext:self.openGLESContext];
    self.videoDisplayView = [[GLKView alloc] initWithFrame:self.view.bounds context:self.openGLESContext];
    self.videoDisplayView.contentScaleFactor = [[UIScreen mainScreen] scale];
    [self.view addSubview:self.videoDisplayView];
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:[NSNull null] forKey:kCIContextWorkingColorSpace];
    _coreImageContext = [CIContext contextWithEAGLContext:self.openGLESContext options:options];
    _coreImageFilter = [CIFilter filterWithName:@"CIGammaAdjust"];
    [_coreImageFilter setValue:[NSNumber numberWithFloat:0.75] forKey:@"inputPower"];
    [self startAVFoundationVideoProcessing];
    self.processUsingCPU = NO;
    [self.captureSession startRunning];
    [_captureSession startRunning];
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [_captureSession stopRunning];
        [_videoDisplayView removeFromSuperview];
        _videoDisplayView = nil;
        _captureSession = nil;
        _videoInput = nil;
        _videoOutput = nil;
        self.openGLESContext = nil;
        glDeleteRenderbuffers(1, &_renderBuffer);
        sleep(1);
        [self displayVideoForGPUImage];
    });
}
- (void)displayVideoForGPUImage {
    self.totalFrameTimeForGPUImage = 0.0;
    self.numberOfGPUImageFramesCaptured = 0;
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.runBenchmark = YES;
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.benchmarkedGPUImageFilter = [[GPUImageGammaFilter alloc] init];
    [(GPUImageGammaFilter *)_benchmarkedGPUImageFilter setGamma:0.75];
    [self.videoCamera addTarget:self.benchmarkedGPUImageFilter];
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.filterView];
    [self.benchmarkedGPUImageFilter addTarget:self.filterView];
    [self.videoCamera startCameraCapture];
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.videoCamera stopCameraCapture];
        [_filterView removeFromSuperview];
        self.filterView = nil;
        self.captureSession = nil;
        self.videoInput = nil;
        self.videoOutput = nil;
        [self.delegate finishedTestWithAverageTimesForCPU:(self.totalFrameTimeForCPU * 1000.0 / self.numberOfCPUFramesCaptured) coreImage:(self.totalFrameTimeForCoreImage * 1000.0 / self.numberOfCoreImageFramesCaptured) gpuImage:[self.videoCamera averageFrameDurationDuringCapture]];
        self.videoCamera = nil;
    });
}
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    if (self.processUsingCPU) {
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
        unsigned char * data = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
        size_t bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
        size_t bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
        NSInteger myDataLength = bufferWidth * bufferHeight * 4;
        for (int i = 0; i < myDataLength; i+=4) {
            UInt8 r_pixel = data[i];
            UInt8 g_pixel = data[i+1];
            UInt8 b_pixel = data[i+2];
            
            int outputRed = (r_pixel * .393) + (g_pixel *.769) + (b_pixel * .189);
            int outputGreen = (r_pixel * .349) + (g_pixel *.686) + (b_pixel * .168);
            int outputBlue = (r_pixel * .272) + (g_pixel *.534) + (b_pixel * .131);
            
            if(outputRed>255)outputRed=255;
            if(outputGreen>255)outputGreen=255;
            if(outputBlue>255)outputBlue=255;
            
            data[i] = outputRed;
            data[i+1] = outputGreen;
            data[i+2] = outputBlue;
        }
        elapsedTime = CFAbsoluteTimeGetCurrent() - startTime;
        self.totalFrameTimeForCPU += elapsedTime;
        self.numberOfCPUFramesCaptured ++ ;
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    } else {
        CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
        CIImage *inputImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        inputImage = [inputImage imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI / 2.0)];
        [self.coreImageFilter setValue:inputImage forKey:kCIInputImageKey];
        CIImage *outputImage = [self.coreImageFilter outputImage];
        CGRect s = CGRectMake(0, 0, 480, 640);
        [self.coreImageContext drawImage:outputImage inRect:s fromRect:[inputImage extent]];
        [self.openGLESContext presentRenderbuffer:GL_RENDERBUFFER];
        elapsedTime = CFAbsoluteTimeGetCurrent() - startTime;
        self.totalFrameTimeForCoreImage += elapsedTime;
        self.numberOfCoreImageFramesCaptured ++;
    }
}

@end
