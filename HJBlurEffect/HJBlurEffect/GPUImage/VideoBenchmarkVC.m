//
//  VideoBenchmarkVC.m
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/6/29.
//  Copyright © 2021 linggao. All rights reserved.
//

#import "VideoBenchmarkVC.h"

@interface VideoBenchmarkVC ()

@end

@implementation VideoBenchmarkVC

- (void)runBenchmark {
    self.videoFilteringDisplayVC = [[VideoFilterDisplayVC alloc] init];
    _videoFilteringDisplayVC.delegate = self;
    [self presentModalViewController:_videoFilteringDisplayVC animated:YES];
}
- (void)finishedTestWithAverageTimesForCPU:(CGFloat)cpuTime coreImage:(CGFloat)coreImageTime gpuImage:(CGFloat)gpuImageTime {
    [self dismissModalViewControllerAnimated:YES];
    self.processingTimeForCPURoutine = cpuTime;
    self.processingTimeForCoreImageRoutine = coreImageTime;
    self.processingTimeForGPUImageRoutine = gpuImageTime;
    [self.tableView reloadData];
}

@end
