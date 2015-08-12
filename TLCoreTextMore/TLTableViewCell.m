//
//  TLTableViewCell.m
//  TLAttributedLabel
//
//  Created by andezhou on 15/8/12.
//  Copyright (c) 2015年 周安德. All rights reserved.
//

#import "TLTableViewCell.h"
#import "TLAttributedLabel.h"
#import "TLModel.h"

@interface TLTableViewCell () <TLAttributedLabelDelegate>
@end

@implementation TLTableViewCell

#pragma mark -
#pragma mark init methods
- (TLAttributedLabel *)label {
    if (!_label) {
        _label = [[TLAttributedLabel alloc] init];
        _label.delegate = self;
        _label.backgroundColor = [UIColor clearColor];
        [_label setOpenString:@"［查看更多］" closeString:@"［点击收起］" font:[UIFont systemFontOfSize:16] textColor:[UIColor blueColor]];
    }
    return _label;
}

#pragma mark -
#pragma mark lifecycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.label];
    }
    return self;
}

- (void)setModel:(TLModel *)model {
    _model = model;
    
    [_label setText:model.title];
    _label.state = model.state;
    _label.numberOfLines = model.numberOfLines;
    CGSize size = [_label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 2*kMargin, MAXFLOAT)];
    _label.frame = CGRectMake(kMargin, kMargin, size.width, size.height);
}

#pragma mark -
#pragma mark TLAttributedLabelDelegate
- (void)displayView:(TLAttributedLabel *)label openHeight:(CGFloat)height {
    if ([self.delegate respondsToSelector:@selector(tableViewCell:model:numberOfLines:)]) {
        [self.delegate tableViewCell:self model:_model numberOfLines:0];
    }
}

- (void)displayView:(TLAttributedLabel *)label closeHeight:(CGFloat)height {
    if ([self.delegate respondsToSelector:@selector(tableViewCell:model:numberOfLines:)]) {
        [self.delegate tableViewCell:self model:_model numberOfLines:numberOfLines];
    }
}

@end
