//
//  TLAttributedLabel.h
//  TLAttributedLabel
//
//  Created by andezhou on 15/8/8.
//  Copyright (c) 2015年 周安德. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TLAttributedLabel;
typedef NS_ENUM(NSInteger, TLSwitchState) {
    TLNormalState,
    TLOpenState,
    TLCloseState
};

@protocol TLAttributedLabelDelegate <NSObject>

@required
- (void)displayView:(TLAttributedLabel *)label openHeight:(CGFloat)height;
- (void)displayView:(TLAttributedLabel *)label closeHeight:(CGFloat)height;

@end

@interface TLAttributedLabel : UIView

@property (nonatomic, weak) id<TLAttributedLabelDelegate> delegate;

@property (nonatomic, strong)    UIFont *font;                   //字体
@property (nonatomic, strong)    UIColor *textColor;             //文字颜色
@property (nonatomic, assign)    CTTextAlignment textAlignment;  //文字排版样式
@property (nonatomic, assign)    CTLineBreakMode lineBreakMode;  //LineBreakMode
@property (nonatomic, assign)    CGFloat lineSpacing;            //行间距
@property (nonatomic, assign)    CGFloat paragraphSpacing;       //段间距
@property (nonatomic, assign)    NSInteger   numberOfLines;      //行数

@property (nonatomic, assign)    TLSwitchState state;

//大小
- (CGSize)sizeThatFits:(CGSize)size;

//普通文本
- (void)setText:(NSString *)text;

//属性文本
- (void)setAttributedText:(NSAttributedString *)attributedText;

// 添加展开关闭按钮
- (void)setOpenString:(NSString *)openString
          closeString:(NSString *)closeString;

- (void)setOpenString:(NSString *)openString
          closeString:(NSString *)closeString
                 font:(UIFont *)font
            textColor:(UIColor *)textColor;

@end
