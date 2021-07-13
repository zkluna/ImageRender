//
//  ImageHelper.m
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/6/29.
//  Copyright © 2021 linggao. All rights reserved.
//

#import "ImageHelper.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@implementation ImageHelper

- (UIImage *)drawImageWithImage:(UIImage *)originImage {
    CGImageRef cgimage = [originImage CGImage];
    size_t width = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    unsigned char *data = calloc(width * height * 4, sizeof(unsigned char));
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = width * 4;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);
    for (size_t i = 0; i < height; i++) {
        for (size_t j = 0; j < width; j++) {
            size_t pixelIndex = i * width * 4 + j * 4;
            unsigned char red = data[pixelIndex];
            unsigned char green = data[pixelIndex + 1];
            unsigned char blue = data[pixelIndex + 2];
            red = 0;
            data[pixelIndex] = red;
            data[pixelIndex + 1] = green;
            data[pixelIndex + 2] = blue;
        }
    }
    cgimage = CGBitmapContextCreateImage(context);
    return [UIImage imageWithCGImage:cgimage];
}

@end
