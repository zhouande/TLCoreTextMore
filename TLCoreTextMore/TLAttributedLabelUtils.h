//
//  TLAttributedLabelUtils.h
//  TLMove
//
//  Created by andezhou on 15/7/29.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
@interface TLAttributedLabelUtils : NSObject

/**
 *  将点击的位置转换成字符串的偏移量，如果没有找到，则返回-1
 */
+ (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point ctFrame:(CTFrameRef)ctFrame;

@end
