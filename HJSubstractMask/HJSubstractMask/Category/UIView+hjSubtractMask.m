//
//  UIView+hjSubtractMask.m
//  HJSubstractMask
//
//  Created by rubick on 2018/12/4.
//  Copyright © 2018 LG. All rights reserved.
//

#import "UIView+hjSubtractMask.h"

@implementation UIView (hjSubtractMask)

- (void)setSubtractMaskView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), view.frame.origin.x, view.frame.origin.y);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = [self subtractMaskImageWithImage:image];
    UIView *maskView = [[UIView alloc] init];
    maskView.frame = self.bounds;
    maskView.layer.contents = (__bridge id)(image.CGImage);
    self.maskView = maskView;
}
- (UIImage *)subtractMaskImageWithImage:(UIImage *)image {
    CGImageRef originalMaskImage = [image CGImage];
    float width = CGImageGetWidth(originalMaskImage);
    float height = CGImageGetHeight(originalMaskImage);
    
    int strideLength = width+3;
    unsigned char * alphaData = calloc(strideLength * height, sizeof(unsigned char));
    CGContextRef alphaOnlyContext = CGBitmapContextCreate(alphaData, width, height, 8, strideLength, NULL, kCGImageAlphaOnly);
    CGContextDrawImage(alphaOnlyContext, CGRectMake(0, 0, width, height), originalMaskImage);
    for(int y=0; y<height; y++) {
        for(int x=0; x<width; x++) {
            unsigned char val = alphaData[y*strideLength+x];
            val = 255 - val;
            alphaData[y*strideLength+x] = val;
        }
    }
    CGImageRef alphaMaskImage = CGBitmapContextCreateImage(alphaOnlyContext);
    UIImage *result = [UIImage imageWithCGImage:alphaMaskImage];
    CGImageRelease(alphaMaskImage);
    CGContextRelease(alphaOnlyContext);
    free(alphaData);
    return result;
}
- (UIView *)subtractMaskView {
    return self.maskView;
}

@end
