//
//  BaseBlurListVC.m
//  HJBlurEffect
//
//  Created by rubick on 2018/10/30.
//  Copyright © 2018 linggao. All rights reserved.
//

#import "BaseBlurListVC.h"
#import "ImpTypeHeader.h"
#import "ShowImageVC.h"

@interface BaseBlurListVC ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *typeTitles;
@property (strong, nonatomic) NSArray *impMethodList;

@end

@implementation BaseBlurListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"滤镜列表";
    self.typeTitles = @[@"UIToolbar",@"UIVisualEffect",@"CoreImage",@"GPUImage",@"Accelerate"];
    self.impMethodList = @[@[@"UIToolbar"],@[@"UIVisualEffect"],@[@"CIBoxBlur",@"CIDiscBlur",@"CIGaussianBlur",@"CIMaskedVariableBlur",@"CIMedianFilter",@"CIMotionBlur",@"CINoiseReduction",@"CIZoomBlur"],@[@"GPUImage"],@[@"Accelerate"]];
    [self setUpTableView];
}
- (void)setUpTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.tableView registerClass:[ImpTypeHeader class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([ImpTypeHeader class])];
}
#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.typeTitles.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *temp = self.impMethodList[section];
    return temp.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ImpTypeHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([ImpTypeHeader class])];
    header.typeName = self.typeTitles[section];
    return header;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    NSArray *temp = self.impMethodList[indexPath.section];
    cell.textLabel.text = temp[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ShowImageVC *vc = [[ShowImageVC alloc] init];
    vc.index = indexPath;
    NSArray *temp = self.impMethodList[indexPath.section];
    vc.filterName = temp[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
