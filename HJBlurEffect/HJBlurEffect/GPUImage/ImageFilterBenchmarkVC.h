//
//  ImageFilterBenchmarkVC.h
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/6/28.
//  Copyright © 2021 linggao. All rights reserved.
//

#import "BenchmarkList.h"
#import <GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageFilterBenchmarkVC : BenchmarkList

@property (strong, nonatomic) CIContext *coreImageContext;

- (UIImage *)imageProcessedOnCPU:(UIImage *)imageToProcess;
- (UIImage *)imageProcessedUsingCoreImage:(UIImage *)imageToProcess;
- (UIImage *)imageProcessedUsingGPUImage:(UIImage *)imageToProcess;
- (void)writeImage:(UIImage *)imageToWrite toFile:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
