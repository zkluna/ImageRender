//
//  GPUDemoList.m
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/6/28.
//  Copyright © 2021 linggao. All rights reserved.
//

#import "GPUDemoList.h"

@interface GPUDemoList ()

@property (strong, nonatomic) NSArray *demoTitles;
@property (strong, nonatomic) NSArray *subArrTitles;

@end

@implementation GPUDemoList

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GPU Demo";
    self.demoTitles = @[@"Image Filtering 耗时对比", @"Video Filtering 耗时对比", @"简单图片处理", @"Photo", @"Simple Video", @"Mult Ouput", @"ColorTracking", @"Show case Fliter"];
    self.subArrTitles = @[@"ImageFilterBenchmarkVC", @"VideoBenchmarkVC", @"SimpleImageVC", @"PhotoVC", @"SimpleVideoFilterViewController", @"MultViewVC", @"ColorTrackingVC", @"ShowcaseFilterListController"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoTitles.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = self.demoTitles[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *subVCName = self.subArrTitles[indexPath.row];
    UIViewController *vc = (UIViewController *)[[NSClassFromString(subVCName) alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
