//
//  TLAttributedLabel.m
//  TLAttributedLabel
//
//  Created by andezhou on 15/8/8.
//  Copyright (c) 2015年 周安德. All rights reserved.
//

#import "TLAttributedLabel.h"
#import "NSMutableAttributedString+Config.h"
#import "NSMutableAttributedString+CTFrameRef.h"
#import "TLAttributedLabelUtils.h"

static NSString* const kEllipsesCharacter = @"\u2026";

@interface TLAttributedLabel ()

@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, strong) NSMutableAttributedString *attributedOpenString, *attributedCloseString;

@property (nonatomic, assign) CTFrameRef frameRef;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) BOOL isSelected;

@end

@implementation TLAttributedLabel

#pragma mark -
#pragma mark lifecycle
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configSettings];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configSettings];
    }
    return self;
}

- (void)configSettings {
    _numberOfLines     = 0;
    _lineSpacing       = 3.0f;
    _paragraphSpacing  = 10.0f;
    _font              = [UIFont systemFontOfSize:16.0f];
    _textColor         = [UIColor blackColor];
    _textAlignment     = kCTTextAlignmentLeft;
    _lineBreakMode     = kCTLineBreakByWordWrapping | kCTLineBreakByCharWrapping;
    
    _attributedOpenString  = [[NSMutableAttributedString alloc] init];
    _attributedCloseString = [[NSMutableAttributedString alloc] init];
}

#pragma mark -
#pragma mark set and get
- (void)setNumberOfLines:(NSInteger)numberOfLines {
    _numberOfLines = numberOfLines;
//    _state =TLNormalState;
}
- (void)setFont:(UIFont *)font {
    if (font != _font) {
        _font = font;
        [_attributedString setFont:font];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (textColor != _textColor) {
        _textColor = textColor;
        [_attributedString setTextColor:textColor];
    }
}

- (void)setFrame:(CGRect)frame {
    if (!CGRectEqualToRect(self.frame, frame)) {
        if (_frameRef) {
            CFRelease(_frameRef);
            _frameRef = nil;
        }
        if ([NSThread isMainThread]) {
            [self setNeedsDisplay];
        }
    }
    
    [super setFrame:frame];
    _width = frame.size.width;
}

#pragma mark - 设置文本
- (void)setText:(NSString *)text {
    NSAttributedString *attributedText = [self attributedString:text];
    [self setAttributedText:attributedText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];

    // 设置文字排版方式
    [_attributedString setAttributedsWithLineSpacing:_lineSpacing
                                    paragraphSpacing:_paragraphSpacing
                                       textAlignment:_textAlignment
                                       lineBreakMode:_lineBreakMode];
    
    [self setNeedsDisplay];
}

- (NSMutableAttributedString *)attributedString:(NSString *)text {
    return [self attributedString:text font:_font textColor:_textColor];
}

- (NSMutableAttributedString *)attributedString:(NSString *)text
                                           font:(UIFont *)font
                                      textColor:(UIColor *)textColor {
    if (!text && !text.length) {
        return nil;
    }
    
    // 初始化NSMutableAttributedString
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString setFont:font];
    [attributedString setTextColor:textColor];
    
    return attributedString;
}

// 添加展开和收起
- (void)setOpenString:(NSString *)openString
          closeString:(NSString *)closeString {
    [self setOpenString:openString
            closeString:closeString
                   font:self.font
              textColor:self.textColor];
}

- (void)setOpenString:(NSString *)openString
          closeString:(NSString *)closeString
                 font:(UIFont *)font
            textColor:(UIColor *)textColor {
    self.attributedOpenString = [self attributedString:openString font:font textColor:textColor];
    self.attributedCloseString = [self attributedString:closeString font:font textColor:textColor];
    
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark 计算展开状态下的AttString 
- (NSMutableAttributedString *)openAttString {
    NSMutableAttributedString *attString = [self attributedString:[NSString stringWithFormat:@"%@%@", _attributedString.string, @"\n"]];
    
    NSMutableAttributedString *closeString = [_attributedCloseString mutableCopy];
    [closeString setAttributedsWithLineSpacing:self.lineSpacing
                              paragraphSpacing:self.paragraphSpacing
                                 textAlignment:kCTTextAlignmentCenter
                                 lineBreakMode:self.lineBreakMode];
    [attString appendAttributedString:closeString];
    
    return attString;
}

#pragma mark -
#pragma mark 获取label的size
- (CGSize)sizeThatFits:(CGSize)size {
    self.width = size.width;
    
    if (!_attributedString) {
        return CGSizeZero;
    }
    
    CGFloat height = 0;
    // 3.1绘制展开状态
    if (_state == TLOpenState) {
        // 获取初始行数
        CFIndex count = [self initialNumberOfLines];

        // 获取添加［点击收起］后的attString
        NSMutableAttributedString *lineAttString = [_attributedString mutableCopy];
        [lineAttString appendAttributedString:_attributedCloseString];
        
        CTFrameRef lineFrameRef = [lineAttString prepareFrameRefWithWidth:self.width];
        CFIndex lineCount = CFArrayGetCount(CTFrameGetLines(lineFrameRef));
        
        // 同行显示
        if (count == lineCount) {
            height = [lineAttString boundingHeightForWidth:_width];
        }
        // 分行显示
        else {
            NSMutableAttributedString *attString = [self openAttString];
            height = [attString boundingHeightForWidth:_width];
        }

    }
    // 3.2绘制关闭状态和第一次进入
    else {
        // _numberOfLines行情况下文字的高度
        height = [_attributedString boundingHeightForWidth:_width
                                                     numberOfLines:_numberOfLines];
    }
    
    return CGSizeMake(self.width, height);;
}

// 获取当前需要展示的行数
- (NSUInteger)currentNumberOfLines {
    CFArrayRef lines = CTFrameGetLines(_frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    
    return _numberOfLines > 0 ? MIN(_numberOfLines, lineCount) : lineCount;
}

// 获取初始行数
- (NSUInteger)initialNumberOfLines {
    NSMutableAttributedString *attributedString = [_attributedString mutableCopy];
    CTFrameRef frameRef = [attributedString prepareFrameRefWithWidth:self.width];
    NSUInteger count = CFArrayGetCount(CTFrameGetLines(frameRef));
    
    return count;
}

#pragma mark -
#pragma mark 点击事件相应
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    
    // 检查是否选中链接
    CFIndex index = [TLAttributedLabelUtils touchContentOffsetInView:self atPoint:point ctFrame:_frameRef];
    
    if (NSLocationInRange(index, self.range)) {
        self.isSelected = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    
    CFIndex index = [TLAttributedLabelUtils touchContentOffsetInView:self atPoint:point ctFrame:_frameRef];

    if (self.isSelected && NSLocationInRange(index, self.range) && self.numberOfLines >= 0) {
        self.isSelected = NO;
        // 更改当前状态
        if (self.state == TLCloseState) {
            self.state = TLOpenState;
            
            // 代理重新设置高度
            CGSize size = [self sizeThatFits:CGSizeMake(_width, MAXFLOAT)];
            if ([self.delegate respondsToSelector:@selector(displayView:openHeight:)]) {
                [self.delegate displayView:self openHeight:size.height];
            }
        }
        else {
            self.state = TLCloseState;
            
            // 代理重新设置高度
            CGSize size = [self sizeThatFits:CGSizeMake(_width, MAXFLOAT)];
            if ([self.delegate respondsToSelector:@selector(displayView:closeHeight:)]) {
                [self.delegate displayView:self closeHeight:size.height];
            }
        }
        
        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark drawRect
- (void)drawRect:(CGRect)rect {
    if (!_attributedString) {
        return;
    }

    // 1.获取图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 2.将坐标系上下翻转
    CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
    CGContextConcatCTM(context, transform);

    // 3.绘制
    // 3.1绘制展开状态
    if (_state == TLOpenState) {
        [self drawOpenContext:context];
    }
    // 3.2绘制关闭状态和第一次进入
    else {
        [self drawCloseContext:context attributedString:_attributedString];
    }
}

- (void)drawOpenContext:(CGContextRef)context {
    CFIndex count = [self initialNumberOfLines];
    
    NSMutableAttributedString *lineAttString = [_attributedString mutableCopy];
    [lineAttString appendAttributedString:_attributedCloseString];
    
    CTFrameRef lineFrameRef = [lineAttString prepareFrameRefWithWidth:self.width];
    CFIndex lineCount = CFArrayGetCount(CTFrameGetLines(lineFrameRef));

    if (count == lineCount) {
        CGPathRef path = CTFrameGetPath(lineFrameRef);
        CFArrayRef lines = CTFrameGetLines(lineFrameRef);
        CGRect rect = CGPathGetBoundingBox(path);

        CGPoint lineOrigins[lineCount];
        CTFrameGetLineOrigins(lineFrameRef, CFRangeMake(0, lineCount), lineOrigins);
        
        for (CFIndex lineIndex = 0; lineIndex < lineCount; lineIndex++) {

            CGPoint lineOrigin = lineOrigins[lineIndex];
            lineOrigin.y =  self.frame.size.height + (lineOrigin.y - rect.size.height);
            
            CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
            
            CTLineDraw(line, context);
            
            CFRelease(line);
        }
        
        self.range = [lineAttString.string rangeOfString:_attributedCloseString.string];
        self.state = TLOpenState;
        self.frameRef = [lineAttString prepareFrameRefWithWidth:self.width];
    }
    else {
        NSMutableAttributedString *attString = [self openAttString];
        [self drawCloseContext:context attributedString:attString];
    }
}

- (void)drawCloseContext:(CGContextRef)context attributedString:(NSMutableAttributedString *)attString {
    self.frameRef = [attString prepareFrameRefWithWidth:self.width];

    CGPathRef path = CTFrameGetPath(_frameRef);
    CGRect rect = CGPathGetBoundingBox(path);
    CFArrayRef lines = CTFrameGetLines(_frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);

    NSInteger numberOfLines = lineCount;
    if ([attString isEqualToAttributedString:_attributedString]) {
        // 获取需要展示的行数
        numberOfLines = _numberOfLines > 0 ? MIN(_numberOfLines, lineCount) : lineCount;
    }
    // 换行显示［点击收起］
    else {
        self.state = TLOpenState;
        self.range = [attString.string rangeOfString:_attributedCloseString.string];
    }
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0, numberOfLines), lineOrigins);
    NSAttributedString *attributedString = attString;
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        lineOrigin.y =  self.frame.size.height + (lineOrigin.y - rect.size.height);
        
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        BOOL shouldDrawLine = YES;

        if (lineIndex == numberOfLines - 1) {
            CFRange lastLineRange = CTLineGetStringRange(line);

            if (lastLineRange.location + lastLineRange.length < (CFIndex)attributedString.length) {
                CTLineTruncationType truncationType = kCTLineTruncationEnd;
                NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
                
                NSDictionary *tokenAttributes = [attributedString attributesAtIndex:truncationAttributePosition
                                                                     effectiveRange:NULL];
                NSMutableAttributedString *tokenString = [[NSMutableAttributedString alloc] initWithString:kEllipsesCharacter
                                                                                  attributes:tokenAttributes];
                [tokenString appendAttributedString:_attributedOpenString];
                
                CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)tokenString);
                
                NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                
                if (lastLineRange.length > 0) {
                    unichar lastCharacter = [[truncationString string] characterAtIndex:lastLineRange.length - 1];
                    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:lastCharacter]) {
                        [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
                    }
                }
                [truncationString appendAttributedString:tokenString];

                // 替换
                CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
                CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, _width, truncationType, truncationToken);
                if (!truncatedLine) {
                    truncatedLine = CFRetain(truncationToken);
                }
                CFRelease(truncationLine);
                CFRelease(truncationToken);
                
                CTLineDraw(truncatedLine, context);
                NSUInteger truncatedCount =  CTLineGetGlyphCount(truncatedLine);
                
                // 获取当前显示的文字
                NSMutableAttributedString *showString = [[attString attributedSubstringFromRange:NSMakeRange(0, lastLineRange.location + truncatedCount - tokenString.length)] mutableCopy];
                [showString appendAttributedString:tokenString];
                
                // 获取绘制后的新属性
                self.range = [showString.string rangeOfString:_attributedOpenString.string];
                self.state = TLCloseState;
                self.frameRef = [showString prepareFrameRefWithWidth:_width];

                CFRelease(truncatedLine);

                shouldDrawLine = NO;
            }
        }
        
        if (shouldDrawLine) {
            CTLineDraw(line, context);
        }
    }
}

- (void)setFrameRef:(CTFrameRef)frameRef {
    if (_frameRef != frameRef) {
        if (_frameRef != nil) {
            CFRelease(_frameRef);
        }
        CFRetain(frameRef);
        _frameRef = frameRef;
    }
}

- (void)dealloc {
    if (_frameRef != nil) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
