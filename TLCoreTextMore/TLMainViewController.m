//
//  ViewController.m
//  TLAttributedLabel
//
//  Created by andezhou on 15/8/8.
//  Copyright (c) 2015年 周安德. All rights reserved.
//

#import "TLMainViewController.h"
#import "TLATTViewController.h"
#import "TLTableViewController.h"

static NSString *const identifier = @"UITableViewCell";

@interface TLMainViewController ()

@property (nonatomic, strong) NSArray *dataList;

@end

@implementation TLMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataList = @[@"view", @"tableView"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    self.tableView.tableFooterView = [UIView new];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _dataList[indexPath.row];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        TLATTViewController *attVC = [[TLATTViewController alloc] init];
        [self.navigationController pushViewController:attVC animated:YES];
    }else {
        TLTableViewController *tableVC = [[TLTableViewController alloc] init];
        [self.navigationController pushViewController:tableVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
