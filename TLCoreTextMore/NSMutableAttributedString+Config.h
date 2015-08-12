//
//  NSMutableAttributedString+Config.h
//  TLAttributedLabel
//
//  Created by andezhou on 15/8/8.
//  Copyright (c) 2015年 周安德. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (Config)

// 设置颜色
- (void)setTextColor:(UIColor *)color;
- (void)setTextColor:(UIColor *)color range:(NSRange)range;

// 设置字体
- (void)setFont:(UIFont *)font;
- (void)setFont:(UIFont *)font range:(NSRange)range;

// 设置属性
- (NSMutableAttributedString *)setAttributedsWithLineSpacing:(CGFloat)lineSpacing
                                            paragraphSpacing:(CGFloat)paragraphSpacing
                                               textAlignment:(CTTextAlignment)textAlignment
                                               lineBreakMode:(CTLineBreakMode)lineBreakMode;

@end
