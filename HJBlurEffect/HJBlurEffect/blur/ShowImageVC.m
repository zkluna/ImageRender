//
//  ShowImageVC.m
//  HJBlurEffect
//
//  Created by rubick on 2018/10/29.
//  Copyright © 2018 linggao. All rights reserved.
//

#import "ShowImageVC.h"
#import <GPUImage/GPUImage.h>
#import <Accelerate/Accelerate.h>
#import <CoreImage/CoreImage.h>
#import <CoreFoundation/CoreFoundation.h>

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

@interface ShowImageVC ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ShowImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.filterName;
    [self setUpImageView];
    [self setUpFilterEffect];
}
- (void)setUpImageView {
    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.image = [UIImage imageNamed:@"img1.jpg"];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.clipsToBounds = YES;
    [self.view addSubview:self.imageView];
}
- (void)setUpFilterEffect {
    switch (self.index.section) {
        case 0: {
            [self toolBarStyle];            
        }
            break;
        case 1: {
            [self visualEffectViewStyle];
        }
            break;
        case 2: {
            UIImage *image = [UIImage imageNamed:@"img1.jpg"];
            self.imageView.image = [self coreBlurImage:image withBlurNumber:5 withIndex:self.index.row];
        }
            break;
        case 3: {
            UIImage *image = [UIImage imageNamed:@"img1.jpg"];
            self.imageView.image = [self gpu_imageStyleWithImage:image];
        }
            break;
        case 4: {
            UIImage *image = [UIImage imageNamed:@"img1.jpg"];
            self.imageView.image = [self boxblurImage:image withBlurNumber:5];
        }
            break;
    }
}
// 实现毛玻璃效果
#pragma mark - vImage属于Accelerate.Framework Accelerate主要是用来做数字信号处理、图像处理相关的向量、矩阵预算的库。图像可以认为是由向量或者矩阵数据构成的，Accelerate里既然提供了高效的数学运算API，自然就能方便我们对图像做各种各样的处理 ，模糊算法使用的是vImageBoxConvolve_ARGB8888这个函数。
- (UIImage *)boxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur {
    if(blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    CGImageRef img = image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    // 从CGImage中获取数据
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //设置从CGImage获取对象的属性
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if(error){
        NSLog(@"error from convolution %ld", error);
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate( outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up CGContextRelease(ctx)
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return returnImage;
}
#pragma mark - CPUImage开源库（比CoreImage好一点）good
- (UIImage *)gpu_imageStyleWithImage:(UIImage *)image {
    GPUImageGaussianBlurFilter *filter = [[GPUImageGaussianBlurFilter alloc] init];
    filter.blurRadiusInPixels = 5.0;
    UIImage *blurImage = [filter imageByFilteringImage:image];
    return blurImage;
}
#pragma mark - CoreImage提供大量的滤镜（Filter）（渲染速度慢，吃内存）well
- (UIImage *)coreBlurImage:(UIImage *)image withBlurNumber:(CGFloat)blur withIndex:(NSInteger)index {
    NSArray *temp = @[@"CIBoxBlur",@"CIDiscBlur",@"CIGaussianBlur",@"CIMaskedVariableBlur",@"CIMedianFilter",@"CIMotionBlur",@"CINoiseReduction",@"CIZoomBlur"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    // 设置filter
    CIFilter *filter = [CIFilter filterWithName:temp[index]];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    if(index == 2){
        [filter setValue:@(blur) forKey:@"inputRadius"];
    }
    // 图片模糊
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef outImage = [context createCGImage:result fromRect:[result extent]];
    UIImage *blurImage = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return blurImage;
}
#pragma mark - iOS8后新增UIVisualEffectView来实现毛玻璃效果 not bad
- (void)visualEffectViewStyle {
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = CGRectMake(0, 0, ScreenW/2, ScreenH);
    [self.imageView addSubview:effectView];
}
#pragma mark - iOS7之前系统类提供UIToolbar来是实现 bad
- (void)toolBarStyle {
    CGRect toolBarRect = CGRectMake(0, 0, ScreenW/2, ScreenH);
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:toolBarRect];
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.translucent = YES;
    [self.imageView addSubview:toolbar];
}

@end
