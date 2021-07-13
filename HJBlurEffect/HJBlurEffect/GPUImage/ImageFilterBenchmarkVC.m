//
//  ImageFilterBenchmarkVC.m
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/6/28.
//  Copyright © 2021 linggao. All rights reserved.
//

#import "ImageFilterBenchmarkVC.h"

@interface ImageFilterBenchmarkVC ()

@end

@implementation ImageFilterBenchmarkVC

- (void)runBenchmark {
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];
    if (indexPath.row == 0) {
        [self imageProcessedOnCPU:inputImage];
    } else if (indexPath.row == 1) {
        [self imageProcessedUsingCoreImage:inputImage];
    } else {
        [self imageProcessedUsingGPUImage:inputImage];
    }
    [tableView reloadData];
}
- (UIImage *)imageProcessedOnCPU:(UIImage *)imageToProcess {
    CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
    CGImageRef cgImage = [imageToProcess CGImage];
    CGImageRetain(cgImage);
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CFDataRef bitmapData = CGDataProviderCopyData(provider);
    UInt8 *data = (UInt8 *)CFDataGetBytePtr(bitmapData);
    CGImageRelease(cgImage);
    
    int width = imageToProcess.size.width;
    int height = imageToProcess.size.height;
    NSInteger myDataLength = width * height * 4;
    for (int i = 0; i < myDataLength; i++) {
        UInt8 r_pixel = data[i];
        UInt8 g_pixel = data[i+1];
        UInt8 b_pixel = data[i+2];
        
        int outputRed = (r_pixel * .393) + (g_pixel *.769) + (b_pixel * .189);
        int outputGreen = (r_pixel * .349) + (g_pixel *.686) + (b_pixel * .168);
        int outputBlue = (r_pixel * .272) + (g_pixel *.534) + (b_pixel * .131);
        
        if(outputRed>255) outputRed=255;
        if(outputGreen>255) outputGreen=255;
        if(outputBlue>255) outputBlue=255;
        
        data[i] = outputRed;
        data[i+1] = outputGreen;
        data[i+2] = outputBlue;
    }
    CGDataProviderRef provider2 = CGDataProviderCreateWithData(NULL, data, myDataLength, NULL);
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider2, NULL, NO, renderingIntent);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider2);
    CFRelease(bitmapData);
    
    UIImage *sepiaImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    elapsedTime = CFAbsoluteTimeGetCurrent() - startTime;
    self.processingTimeForCPURoutine = elapsedTime * 1000.f;
    return sepiaImage;
}
- (UIImage *)imageProcessedUsingCoreImage:(UIImage *)imageToProcess {
    CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
    CIImage *inputImage = [[CIImage alloc] initWithCGImage:imageToProcess.CGImage];
    CIFilter *sepiaTone = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey, inputImage, @"inputIntensity", [NSNumber numberWithFloat:1.0], nil];
    CIImage *result = [sepiaTone outputImage];
    CGImageRef resultRef = [self.coreImageContext createCGImage:result fromRect:CGRectMake(0, 0, imageToProcess.size.width, imageToProcess.size.height)];
    UIImage *resultImage = [UIImage imageWithCGImage:resultRef];
    CGImageRelease(resultRef);
    elapsedTime = CFAbsoluteTimeGetCurrent() - startTime;
    self.processingTimeForCoreImageRoutine = elapsedTime * 1000.0;
    return resultImage;
}
- (UIImage *)imageProcessedUsingGPUImage:(UIImage *)imageToProcess {
    CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:imageToProcess];
    GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
    [stillImageSource addTarget:stillImageFilter];
    [stillImageFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
    elapsedTime = CFAbsoluteTimeGetCurrent() - startTime;
    self.processingTimeForGPUImageRoutine = elapsedTime * 1000.0;
    return currentFilteredVideoFrame;
}
- (void)writeImage:(UIImage *)imageToWrite toFile:(NSString *)fileName {
    if (imageToWrite == nil) {
        return;
    }
    NSData *dataForPNGFile = UIImagePNGRepresentation(imageToWrite);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error = nil;
    if (![dataForPNGFile writeToFile:[documentsDirectory stringByAppendingPathComponent:fileName] options:NSAtomicWrite error:&error]) {
        return;
    }
}

@end
