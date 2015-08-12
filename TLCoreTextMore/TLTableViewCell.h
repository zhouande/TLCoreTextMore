//
//  TLTableViewCell.h
//  TLAttributedLabel
//
//  Created by andezhou on 15/8/12.
//  Copyright (c) 2015年 周安德. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TLAttributedLabel;
@class TLTableViewCell;
@class TLModel;

static CGFloat const kMargin = 10.f;
static NSUInteger const numberOfLines = 5;

@protocol TLTableViewCellDelegate <NSObject>

- (void)tableViewCell:(TLTableViewCell *)cell model:(TLModel *)model numberOfLines:(NSUInteger)numberOfLines;

@end

@interface TLTableViewCell : UITableViewCell

@property (nonatomic, weak) id<TLTableViewCellDelegate> delegate;
@property (nonatomic, strong) TLModel *model;
@property (nonatomic, strong) TLAttributedLabel *label;

@end
