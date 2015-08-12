//
//  TLTableViewController.m
//  TLAttributedLabel
//
//  Created by andezhou on 15/8/12.
//  Copyright (c) 2015年 周安德. All rights reserved.
//

#import "TLTableViewController.h"
#import "TLTableViewCell.h"
#import "TLAttributedLabel.h"
#import "TLModel.h"

static NSString *const identifier = @"UITableViewCell";

@interface TLTableViewController () <TLTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableDictionary *offscreenCell;

@end

@implementation TLTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"table";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[TLTableViewCell class] forCellReuseIdentifier:identifier];
    self.tableView.tableHeaderView = [UIView new];

    NSString *str = @"2014年4月，123123asadasd1`2123123有网友曝光了一组奶123123asadasd1`2123123茶妹妹章泽天ss与京东老总刘强东的约会照。4月7日，刘强东微博发声，称“我们每个人都有选择和决定自己生活的权利。小天是我见过最单纯善良的人，很遗憾自己没能保护好她。感谢大家关心，只求以后可以正常牵手而行。祝大家幸福！”";
    
    self.offscreenCell = [NSMutableDictionary dictionary];
    self.dataList = [NSMutableArray arrayWithCapacity:20];
    for (NSUInteger idx = 0; idx < 70; idx ++) {
        NSUInteger length = rand() % 80 + str.length - 80;
        NSString *title = [str substringToIndex:length];
//        NSLog(@"idx==%zi %@", idx, title);

        TLModel *model = [[TLModel alloc] init];
        model.title = title;
        model.numberOfLines = numberOfLines;
        model.state = TLNormalState;
        [_dataList addObject:model];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;
    
//    if (indexPath.row % 2) {
//        cell.backgroundColor = [UIColor redColor];
//    }else {
//        cell.backgroundColor = [UIColor orangeColor];
//    }
    
    [cell setModel:_dataList[indexPath.row]];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TLTableViewCell *cell = [self.offscreenCell objectForKey:identifier];
    if(!cell){
        cell = [[TLTableViewCell alloc] init];
        [self.offscreenCell setObject:cell forKey:identifier];
    }
    
    TLModel *model = _dataList[indexPath.row];
    [cell.label setText:model.title];
    cell.label.state = model.state;
    cell.label.numberOfLines = model.numberOfLines;
    
    CGSize size = [cell.label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 2*kMargin, MAXFLOAT)];
    
    return size.height + 2*kMargin;
}

#pragma mark -
#pragma mark TLTableViewCellDelegate
- (void)tableViewCell:(TLTableViewCell *)cell model:(TLModel *)model numberOfLines:(NSUInteger)numberOfLines {
    model.numberOfLines = numberOfLines;

    if (numberOfLines == 0) {
        model.state = TLOpenState;
    }else {
        model.state = TLCloseState;
    }
    
    [self.tableView reloadData];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
