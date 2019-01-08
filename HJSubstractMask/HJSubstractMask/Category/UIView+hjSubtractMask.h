//
//  UIView+hjSubtractMask.h
//  HJSubstractMask
//
//  Created by rubick on 2018/12/4.
//  Copyright © 2018 LG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (hjSubtractMask)

/** 设置镂空遮罩层，寄宿层有更新的时候，要手动调用setter方法 */
- (void)setSubtractMaskView:(UIView *)view;

/** 镂空遮罩视图 */
- (UIView *)subtractMaskView;

@end

NS_ASSUME_NONNULL_END
