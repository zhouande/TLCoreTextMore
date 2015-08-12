//
//  NSMutableAttributedString+CTFrameRef.m
//  TLAttributedLabel
//
//  Created by andezhou on 15/8/8.
//  Copyright (c) 2015年 周安德. All rights reserved.
//

#import "NSMutableAttributedString+CTFrameRef.h"

static CGFloat const kMaxFloat = 10000.0f;

@implementation NSMutableAttributedString (CTFrameRef)

#pragma mark - NSRange / CFRange
NSRange NSRangeFromCFRange(CFRange range) {
    return NSMakeRange((NSUInteger)range.location, (NSUInteger)range.length);
}

#pragma mark - CoreText CTLine/CTRun utils
BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range) {
    NSRange runRange = NSRangeFromCFRange(CTRunGetStringRange(run));
    NSRange intersectedRange = NSIntersectionRange(runRange, range);
    return (intersectedRange.length <= 0);
}

BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range) {
    NSRange lineRange = NSRangeFromCFRange(CTLineGetStringRange(line));
    NSRange intersectedRange = NSIntersectionRange(lineRange, range);
    return (intersectedRange.length <= 0);
}

CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin) {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    
    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
    
    return CGRectMake(lineOrigin.x + xOffset - leading,
                      lineOrigin.y - descent,
                      width + leading,
                      height);
}

CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin) {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    
    return CGRectMake(lineOrigin.x,
                      lineOrigin.y - descent,
                      width,
                      height);
}

CGRect CTRunGetTypographicBoundsForLinkRect(CTLineRef line, NSRange range, CGPoint lineOrigin) {
    CGRect rectForRange = CGRectZero;
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runs);
    
    for (CFIndex k = 0; k < runCount; k++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, k);
        
        if (CTRunContainsCharactersFromStringRange(run, range)) {
            continue;
        }
        
        CGRect linkRect = CTRunGetTypographicBoundsAsRect(run, line, lineOrigin);
        
        linkRect.origin.y = roundf(linkRect.origin.y);
        linkRect.origin.x = roundf(linkRect.origin.x);
        linkRect.size.width = roundf(linkRect.size.width);
        linkRect.size.height = roundf(linkRect.size.height);
        
        rectForRange = CGRectIsEmpty(rectForRange) ? linkRect : CGRectUnion(rectForRange, linkRect);
    }
    
    return rectForRange;
}

#pragma mark -
#pragma mark 获取CTFrameRef
- (CTFrameRef)prepareFrameRefWithWidth:(CGFloat)width {
    // 创建 CTFramesetterRef 实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    
    // 获得要缓制的区域的高度
    CGSize restrictSize = CGSizeMake(width, kMaxFloat);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    
    CTFrameRef frameRef = [self createFrameWithFramesetter:framesetter width:width height:coreTextSize.height];
    
    return frameRef;
}

- (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter
                                   width:(CGFloat)width
                                  height:(CGFloat)height {
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, width, height));
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), pathRef, NULL);
    CFRelease(pathRef);
    
    return frameRef;
}

#pragma mark -
#pragma mark 获取label高度
- (CGFloat)boundingHeightForWidth:(CGFloat)width {
    return [self boundingHeightForWidth:width
                          numberOfLines:0];
}

- (CGFloat)boundingHeightForWidth:(CGFloat)width
                    numberOfLines:(NSUInteger)numberOfLines {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    
    CFRange range = CFRangeMake(0, 0);
    if (numberOfLines > 0 && framesetter) {
        
        CTFrameRef frameRef = [self createFrameWithFramesetter:framesetter width:width height:MAXFLOAT];
        CFArrayRef lines = CTFrameGetLines(frameRef);
        
        if (nil != lines && CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN(numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        CFRelease(frameRef);
    }
    
    // range表示计算绘制文字的范围，当值为zero时表示绘制全部文字
    CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, NULL, CGSizeMake(width, MAXFLOAT), NULL);
    
    return newSize.height;
}

@end
