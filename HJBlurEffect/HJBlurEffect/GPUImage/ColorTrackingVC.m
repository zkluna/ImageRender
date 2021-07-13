//
//  ColorTrackingVC.m
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/7/9.
//  Copyright © 2021 linggao. All rights reserved.
//

#import "ColorTrackingVC.h"
#import <QuartzCore/QuartzCore.h>

@interface ColorTrackingVC ()

@end

@implementation ColorTrackingVC

- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        [currentDefaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithFloat:0.89f], @"thresholdColorR",
                                           [NSNumber numberWithFloat:0.78f], @"thresholdColorG",
                                           [NSNumber numberWithFloat:0.0f], @"thresholdColorB",
                                           [NSNumber numberWithFloat:0.7], @"thresholdSensitivity",
                                           nil]];
        thresholdColor.one = [currentDefaults floatForKey:@"thresholdColorR"];
        thresholdColor.two = [currentDefaults floatForKey:@"thresholdColorG"];
        thresholdColor.three = [currentDefaults floatForKey:@"thresholdColorB"];
        _displayMode = PASSTHROUGH_VIDEO;
        _thresholdSensitivity = [currentDefaults floatForKey:@"thresholdSensitivity"];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChildren];
}
- (void)setupChildren {
    CGRect mainScreenFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *primaryView = [[UIView alloc] initWithFrame:mainScreenFrame];
    primaryView.backgroundColor = [UIColor blueColor];
    self.view = primaryView;

    [self configureVideoFiltering];
    [self configureToolbar];
    [self configureTrackingDot];
}

- (void)configureVideoFiltering {
    CGRect mainScreenFrame = [UIScreen mainScreen].bounds;
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, mainScreenFrame.size.width, mainScreenFrame.size.height)];
    [self.view addSubview:_filteredVideoView];
    
    _thresholdFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"Threshold"];
    [_thresholdFilter setFloat:_thresholdSensitivity forUniformName:@"threshold"];
    [_thresholdFilter setFloatVec3:thresholdColor forUniformName:@"inputColor"];
    
    _positionFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"PositionColor"];
    [_positionFilter setFloat:_thresholdSensitivity forUniformName:@"threshold"];
    [_positionFilter setFloatVec3:thresholdColor forUniformName:@"inputColor"];
    CGSize videoPixelSize = CGSizeMake(480.0, 640.0);
    _positionRawData = [[GPUImageRawDataOutput alloc] initWithImageSize:videoPixelSize resultsInBGRAFormat:YES];
    __unsafe_unretained ColorTrackingVC *weakSelf = self;
    [_positionRawData setNewFrameAvailableBlock:^{
        GLubyte *bytesForPositionData = weakSelf.positionRawData.rawBytesForImage;
        CGPoint currentTrackingLocation = [weakSelf centroidFromTexture:bytesForPositionData ofSize:[weakSelf.positionRawData maximumOutputSize]];
//        NSLog(@"Centroid from CPU: %f, %f", currentTrackingLocation.x, currentTrackingLocation.y);
        CGSize currentViewSize = weakSelf.view.bounds.size;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.trackingDot.position = CGPointMake(currentTrackingLocation.x * currentViewSize.width, currentTrackingLocation.y * currentViewSize.height);
        });
    }];
    _positionAverageColor = [[GPUImageAverageColor alloc] init];
    [_positionAverageColor setColorAverageProcessingFinishedBlock:^(CGFloat redComponent, CGFloat greenComponent, CGFloat blueComponent, CGFloat alphaComponent, CMTime frameTime) {
        CGPoint currentTrackingLocation = CGPointMake(1.0 - (greenComponent / alphaComponent), (redComponent / alphaComponent));
        if (isnan(currentTrackingLocation.x) || isnan(currentTrackingLocation.y)) {
//            NSLog(@"NaN in currentTrackingLocation");
            return;
        }
//        NSLog(@"Centroid from GPU: %f, %f", currentTrackingLocation.x, currentTrackingLocation.y);
        //                NSLog(@"Average color: %f, %f, %f, %f", redComponent, greenComponent, blueComponent, alphaComponent);
        CGSize currentViewSize = weakSelf.view.bounds.size;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.trackingDot.position = CGPointMake(currentTrackingLocation.x * currentViewSize.width, currentTrackingLocation.y * currentViewSize.height);
        });
    }];
    _videoRawData = [[GPUImageRawDataOutput alloc] initWithImageSize:videoPixelSize resultsInBGRAFormat:YES];
    [_videoRawData setNewFrameAvailableBlock:^{
        if (weakSelf.shouldReplaceThresholdColor) {
            CGSize currentViewSize = weakSelf.view.bounds.size;
            CGSize rawPixelsSize = [weakSelf.videoRawData maximumOutputSize];
            
            
            CGPoint scaledTouchPoint;
            scaledTouchPoint.x = (weakSelf.currentTouchPoint.x / currentViewSize.width) * rawPixelsSize.width;
            scaledTouchPoint.y = (weakSelf.currentTouchPoint.y / currentViewSize.height) * rawPixelsSize.height;
            
            GPUByteColorVector colorAtTouchPoint = [weakSelf.videoRawData colorAtLocation:scaledTouchPoint];
            
            thresholdColor.one = (float)colorAtTouchPoint.red / 255.0;
            thresholdColor.two = (float)colorAtTouchPoint.green / 255.0;
            thresholdColor.three = (float)colorAtTouchPoint.blue / 255.0;
            //            NSLog(@"Color at touch point: %d, %d, %d, %d", colorAtTouchPoint.red, colorAtTouchPoint.green, colorAtTouchPoint.blue, colorAtTouchPoint.alpha);
            [[NSUserDefaults standardUserDefaults] setFloat:thresholdColor.one forKey:@"thresholdColorR"];
            [[NSUserDefaults standardUserDefaults] setFloat:thresholdColor.two forKey:@"thresholdColorG"];
            [[NSUserDefaults standardUserDefaults] setFloat:thresholdColor.three forKey:@"thresholdColorB"];
            
            [weakSelf.thresholdFilter setFloatVec3:thresholdColor forUniformName:@"inputColor"];
            [weakSelf.positionFilter setFloatVec3:thresholdColor forUniformName:@"inputColor"];
            
            weakSelf.shouldReplaceThresholdColor = NO;
        }
    }];
    [_videoCamera addTarget:_filteredVideoView];
    [_videoCamera addTarget:_videoRawData];
    [_videoCamera startCameraCapture];
}
- (void)configureToolbar {
    UISegmentedControl *displayModeControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Video", nil), NSLocalizedString(@"Threshold", nil), NSLocalizedString(@"Position", nil), NSLocalizedString(@"Track", nil), nil]];
    displayModeControl.segmentedControlStyle = UISegmentedControlStyleBar;
    displayModeControl.selectedSegmentIndex = 0;
    [displayModeControl addTarget:self action:@selector(handleSwitchOfDisplayMode:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:displayModeControl];
    CGRect mainScreenFrame = [[UIScreen mainScreen] applicationFrame];

    displayModeControl.frame = CGRectMake(0.0f, 10.0f, mainScreenFrame.size.width - 20.0f, 30.0f);
    
    NSArray *theToolbarItems = [NSArray arrayWithObjects:item, nil];
    
    UIToolbar *lowerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 44.0f, self.view.frame.size.width, 44.0f)];
    lowerToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lowerToolbar.tintColor = [UIColor blackColor];
    
    [lowerToolbar setItems:theToolbarItems];
    
    [self.view addSubview:lowerToolbar];
}
- (void)configureTrackingDot {
    _trackingDot = [[CALayer alloc] init];
    _trackingDot.bounds = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    _trackingDot.cornerRadius = 20.0f;
    _trackingDot.backgroundColor = [[UIColor blueColor] CGColor];
    
    NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", nil];
    
    _trackingDot.actions = newActions;
    
    _trackingDot.position = CGPointMake(100.0f, 100.0f);
    _trackingDot.opacity = 0.0f;
    
    [self.view.layer addSublayer:_trackingDot];
}
- (void)handleSwitchOfDisplayMode:(id)sender {
    ColorTrackingDisplayMode newDisplayMode = [sender selectedSegmentIndex];
    if (newDisplayMode != _displayMode) {
        _displayMode = newDisplayMode;
        if (_displayMode == OBJECT_TRACKING) {
            _trackingDot.opacity = 1.0f;
        } else {
            _trackingDot.opacity = 0.0f;
        }
        
        [_videoCamera removeAllTargets];
        [_positionFilter removeAllTargets];
        [_thresholdFilter removeAllTargets];
        [_videoCamera addTarget:_videoRawData];
        
        switch(_displayMode) {
            case PASSTHROUGH_VIDEO: {
                [_videoCamera addTarget:_filteredVideoView];
            };
                break;
            case SIMPLE_THRESHOLDING: {
                [_videoCamera addTarget:_thresholdFilter];
                [_thresholdFilter addTarget:_filteredVideoView];
            };
                break;
            case POSITION_THRESHOLDING: {
                [_videoCamera addTarget:_positionFilter];
                [_positionFilter addTarget:_filteredVideoView];
            }; break;
            case OBJECT_TRACKING: {
                [_videoCamera addTarget:_filteredVideoView];
                [_videoCamera addTarget:_positionFilter];
//                [positionFilter addTarget:positionRawData];
                [_positionFilter addTarget:_positionAverageColor];
            }; break;
        }
    }
}

- (CGPoint)centroidFromTexture:(GLubyte *)pixels ofSize:(CGSize)textureSize; {
    CGFloat currentXTotal = 0.0f, currentYTotal = 0.0f, currentPixelTotal = 0.0f;
    if ([GPUImageContext supportsFastTextureUpload]) {
        for (NSUInteger currentPixel = 0; currentPixel < (textureSize.width * textureSize.height); currentPixel++) {
            currentXTotal += (CGFloat)pixels[(currentPixel * 4) + 2] / 255.0f;
            currentYTotal += (CGFloat)pixels[(currentPixel * 4) + 1] / 255.0f;
            currentPixelTotal += (CGFloat)pixels[(currentPixel * 4) + 3] / 255.0f;
        }
    } else {
        for (NSUInteger currentPixel = 0; currentPixel < (textureSize.width * textureSize.height); currentPixel++) {
            currentXTotal += (CGFloat)pixels[currentPixel * 4] / 255.0f;
            currentYTotal += (CGFloat)pixels[(currentPixel * 4) + 1] / 255.0f;
            currentPixelTotal += (CGFloat)pixels[(currentPixel * 4) + 3] / 255.0f;
        }
    }
    return CGPointMake((1.0 - currentYTotal / currentPixelTotal), currentXTotal / currentPixelTotal);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _currentTouchPoint = [[touches anyObject] locationInView:self.view];
    _shouldReplaceThresholdColor = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event; {
    CGPoint movedPoint = [[touches anyObject] locationInView:self.view];
    CGFloat distanceMoved = sqrt( (movedPoint.x - _currentTouchPoint.x) * (movedPoint.x - _currentTouchPoint.x) + (movedPoint.y - _currentTouchPoint.y) * (movedPoint.y - _currentTouchPoint.y) );
    
    _thresholdSensitivity = distanceMoved / 160.0f;
    [[NSUserDefaults standardUserDefaults] setFloat:_thresholdSensitivity forKey:@"thresholdSensitivity"];

    [_thresholdFilter setFloat:_thresholdSensitivity forUniformName:@"threshold"];
    [_positionFilter setFloat:_thresholdSensitivity forUniformName:@"threshold"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {}

@end
