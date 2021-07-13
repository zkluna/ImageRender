//
//  VideoBenchmarkVC.h
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/6/29.
//  Copyright © 2021 linggao. All rights reserved.
//

#import "BenchmarkList.h"
#import "VideoFilterDisplayVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoBenchmarkVC : BenchmarkList <VideoFilteringCallback>

@property (strong, nonatomic) VideoFilterDisplayVC *videoFilteringDisplayVC;

@end

NS_ASSUME_NONNULL_END
