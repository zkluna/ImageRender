//
//  UIImage+Extend.h
//  HJBlurEffect
//
//  Created by rubick on 2018/10/30.
//  Copyright © 2018 linggao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extend)

/** 图片旋转 */
- (UIImage *)imageRotateInDegree:(float)degree;

/** 图片裁剪 */
- (UIImage *)imageCutSize:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
