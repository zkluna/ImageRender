//
//  BenchmarkList.h
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/6/28.
//  Copyright © 2021 linggao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BenchmarkList : UITableViewController

@property (assign, nonatomic) CGFloat processingTimeForCPURoutine;
@property (assign, nonatomic) CGFloat processingTimeForCoreImageRoutine;
@property (assign, nonatomic) CGFloat processingTimeForGPUImageRoutine;

- (void)runBenchmark;

@end

NS_ASSUME_NONNULL_END
