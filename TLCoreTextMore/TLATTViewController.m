//
//  TLATTViewController.m
//  TLAttributedLabel
//
//  Created by andezhou on 15/8/12.
//  Copyright (c) 2015年 周安德. All rights reserved.
//

#import "TLATTViewController.h"
#import "TLAttributedLabel.h"

@interface TLATTViewController () <TLAttributedLabelDelegate>

@property (nonatomic, strong) TLAttributedLabel *label;

@end

@implementation TLATTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"view";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _label = [[TLAttributedLabel alloc] initWithFrame:CGRectMake(10, 100, [UIScreen mainScreen].bounds.size.width - 20, 200)];
    _label.backgroundColor = [UIColor clearColor];
    _label.delegate = self;
    _label.numberOfLines = 3;
    [_label setText:@"2014年4月，有网友曝光了一组奶茶妹妹章泽天ss与京东老总刘强东的约会照。4月7日，刘强东微博发声，称“我们每个人都有选择和决定自己生活的权利。小天是我见过最单纯善良的人，很遗憾自己没能保护好她。感谢大家关心，只求以后可以正常牵手而行。祝大家幸福！”"];
    [_label
     setOpenString:@"［查看更多］" closeString:@"［点击收起］" font:[UIFont systemFontOfSize:16] textColor:[UIColor blueColor]];
    
    CGSize size = [_label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, MAXFLOAT)];
    _label.frame = CGRectMake(10, 100, size.width, size.height);
    
    [self.view addSubview:_label];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark -
#pragma mark TLAttributedLabelDelegate
- (void)displayView:(TLAttributedLabel *)label openHeight:(CGFloat)height {
    CGRect frame = _label.frame;
    frame.size.height = height;
    _label.frame = frame;
}

- (void)displayView:(TLAttributedLabel *)label closeHeight:(CGFloat)height {
    CGRect frame = _label.frame;
    frame.size.height = height;
    _label.frame = frame;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
