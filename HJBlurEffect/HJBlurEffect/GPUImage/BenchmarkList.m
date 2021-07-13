//
//  BenchmarkList.m
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/6/28.
//  Copyright © 2021 linggao. All rights reserved.
//

#import "BenchmarkList.h"

#define CellIdentifier @"StillImageBenchmarkCell"
typedef enum {
    GPUIMAGE_BENCHMARK_CPU = 0,
    CPUIMAGE_BENCHMARK_COREIMAGE,
    GPUIMAGE_BENCHMARK_GPUIMAGE,
} GPUImageBenchmarkSection;

@interface BenchmarkList ()

@end

@implementation BenchmarkList

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.frame.size.width, 60.f)];
    self.tableView.tableFooterView = [UIView new];
    UIButton *benchmarkBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    benchmarkBtn.frame = CGRectMake(60.f, 20.f, 200.f, 40.f);
    [benchmarkBtn setTitle:@"Run Benchmark" forState:UIControlStateNormal];
    [benchmarkBtn addTarget:self action:@selector(runBenchmark) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    [self.tableView.tableHeaderView addSubview:benchmarkBtn];
}
- (void)runBenchmark {
    
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Processing times";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:50.0f/255.0f green:79.0f/255.0f blue:133.0f/255.0f alpha:1.0f];
        cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
    }
    
    NSArray *temp = @[@"CPU", @"Core Image", @"GPUImage"];
    cell.textLabel.text = temp[indexPath.row];
    switch (indexPath.row) {
        case GPUIMAGE_BENCHMARK_CPU: {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f ms", _processingTimeForCPURoutine];
            break;
        }
        case CPUIMAGE_BENCHMARK_COREIMAGE: {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f ms", _processingTimeForCoreImageRoutine];
            break;
        }
        case GPUIMAGE_BENCHMARK_GPUIMAGE: {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f ms", _processingTimeForGPUImageRoutine];
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

@end
