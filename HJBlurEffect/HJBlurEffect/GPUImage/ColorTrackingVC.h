//
//  ColorTrackingVC.h
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/7/9.
//  Copyright © 2021 linggao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    PASSTHROUGH_VIDEO,
    SIMPLE_THRESHOLDING,
    POSITION_THRESHOLDING,
    OBJECT_TRACKING,
} ColorTrackingDisplayMode;

@interface ColorTrackingVC : UIViewController {
    GPUVector3 thresholdColor;
}

@property (strong, nonatomic) CALayer *trackingDot;
@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;
@property (strong, nonatomic) GPUImageFilter *thresholdFilter;
@property (strong, nonatomic) GPUImageFilter *positionFilter;
@property (strong, nonatomic) GPUImageRawDataOutput *positionRawData;
@property (strong, nonatomic) GPUImageRawDataOutput *videoRawData;
@property (strong, nonatomic) GPUImageAverageColor *positionAverageColor;
@property (strong, nonatomic) GPUImageView *filteredVideoView;
@property (assign, nonatomic) ColorTrackingDisplayMode displayMode;
@property (assign, nonatomic) BOOL shouldReplaceThresholdColor;
@property (assign, nonatomic) CGPoint currentTouchPoint;
@property (assign, nonatomic) GLfloat thresholdSensitivity;

- (void)configureVideoFiltering;
- (void)configureToolbar;
- (void)configureTrackingDot;
- (CGPoint)centroidFromTexture:(GLubyte *)pixles ofSize:(CGSize)textureSize;

@end

NS_ASSUME_NONNULL_END
