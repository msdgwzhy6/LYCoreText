//
//  LYLabel.m
//  ViewControllerTest
//
//  Created by 李言 on 14-8-8.
//  Copyright (c) 2014年 ___李言___. All rights reserved.
//

#import "LYRichLabel.h"
#import <CoreText/CoreText.h>
@implementation LYRichLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       // rangeArr = [[NSMutableArray alloc] init];
        Emoji=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"plist"]];
    }
    return self;
}
void RunDelegateDeallocCallback( void* refCon ){
}
/**
 *	@brief	上升 回调
 *
 *	@param 	refCon
 *
 *	@return	高度
 */
CGFloat RunDelegateGetAscentCallback( void *refCon )
{
    NSString *imageName = (__bridge NSString *)refCon;
    if ([UIImage imageNamed:imageName]) {
        return 25;
    }
    return 0;
}
/**
 *	@brief	下降回调
 *
 *	@param 	refCon
 *
 *	@return 高度
 */
CGFloat RunDelegateGetDescentCallback(void *refCon)
{
     NSString *imageName = (__bridge NSString *)refCon;
    if ([UIImage imageNamed:imageName]) {
        return 0;
    }
    return 0;
}


/**
 *	@brief	宽度回调
 *
 *	@param 	refCon
 *
 *	@return	宽度
 */
CGFloat RunDelegateGetWidthCallback(void *refCon)
{
    NSString *imageName = (__bridge NSString *)refCon;
    if ([UIImage imageNamed:imageName]) {
        return 25;
    }
    return 0;
}

/**
 *	@brief	构建NSMutableAttributedString
 *
 *	@param 	string 	字符串
 *	@param 	array 	数组
 *
 *	@return	NSMutableAttributedString
 */
-(NSMutableAttributedString *)bulidAttributeString:(NSString * )string andarray:(NSMutableArray *)array
{
  
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string] ;
    UIFont *font = self.font;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    [attributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, [attributedString length])];
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)self.textColor.CGColor range:NSMakeRange(0, [attributedString length])];
    
     [self  getImageRange:string andArray:array];
    
       NSInteger charIndex = 0;
    for ( int   i  =  0; i<[array count]; i++) {
        NSString *ImageName = [NSString stringWithFormat:@"%@",[Emoji objectForKey:[array objectAtIndex:i]]];
        
        UIImage *img = [UIImage imageNamed:ImageName];
        CTRunDelegateCallbacks imageCallbacks;
        imageCallbacks.version = kCTRunDelegateVersion1; //必须指定，否则不会生效，没有回调产生。
        imageCallbacks.dealloc = RunDelegateDeallocCallback;
        imageCallbacks.getAscent = RunDelegateGetAscentCallback;
        imageCallbacks.getDescent = RunDelegateGetDescentCallback;
        imageCallbacks.getWidth = RunDelegateGetWidthCallback;
        
        NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "];//空格用于给图片留位置
        [imageAttributedString addAttribute:@"imageName" value:ImageName range:NSMakeRange(0, 1)];
        CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, (__bridge void *)(ImageName));
        [imageAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:NSMakeRange(0, 1)];
        CFRelease(runDelegate);
        
        NSString *string = [array objectAtIndex:i];
        NSRange  range ;
        
        if ([string hasPrefix:@"["] &&[string hasSuffix:@"]"] && img) {
            range = NSMakeRange(charIndex,string.length);
            charIndex ++;
            [attributedString deleteCharactersInRange:range];
        }else{
            range = NSMakeRange(charIndex,string.length);
            charIndex = charIndex + string.length+1;
        }
        [attributedString insertAttributedString:imageAttributedString atIndex:range.location];
        
    }
    //  换行模式
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    
    CTParagraphStyleSetting settings[] = {
        lineBreakMode
    };
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 1);
    
    
    // 构建属性
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(__bridge id)style forKey:(id)kCTParagraphStyleAttributeName ];
    
    // 将属性添加到  attributedstring
    [attributedString addAttributes:attributes range:NSMakeRange(0, [attributedString length])];
    
    return attributedString;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);//设置字形变换矩阵为CGAffineTransformIdentity，也就是说每一个字形都不做图形变换
    CGAffineTransform flipVertical = CGAffineTransformMake(1,0,0,-1,0,self.bounds.size.height);
    CGContextConcatCTM(context, flipVertical);//将当前context的坐标系进行flip
    if (!self.text) {
        return;
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableAttributedString *attributedString = [self bulidAttributeString:self.text andarray:array];
    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)attributedString);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect bounds = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
    CGPathAddRect(path, NULL, bounds);
    
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter,CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(ctFrame, context);
    
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[i];
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
            CGRect runRect;
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
            runRect=CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runRect.size.width, runAscent + runDescent);
            
            NSString *imageName = [attributes objectForKey:@"imageName"];
            
            //图片渲染逻辑
            if (imageName) {
                UIImage *image = [UIImage imageNamed:imageName];
                if (image) {
                    CGRect imageDrawRect;
                    imageDrawRect.size = CGSizeMake(25, 25);
                    imageDrawRect.origin.x = runRect.origin.x + lineOrigin.x;
                    imageDrawRect.origin.y = lineOrigin.y-5;
                    CGContextDrawImage(context, imageDrawRect, image.CGImage);
                }
            }
            
        }
        
    }
    
    CFRelease(ctFrame);
    CFRelease(path);
    CFRelease(ctFramesetter);
 
    
}

/**
 *	@brief	获取字符串高度
 *
 *	@param 	string 	字符串
 *	@param 	width 	宽度
 *	@param 	doneBlock 	完成的回调
 */
- (void)lblSizeEndChangedWithNewString:(NSString *)string  WidthValue:(float) width EndBlock:(void(^)(CGFloat height))doneBlock
;
{
    __block int total_height = 0;
      NSMutableArray *array = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
        NSMutableAttributedString *str = [self bulidAttributeString:string andarray:array];
        dispatch_sync(dispatch_get_main_queue(), ^{
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)str);    //string 为要计算高度的NSAttributedString
            CGRect drawingRect = CGRectMake(0, 0, width, 1000);  //这里的高要设置足够大
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddRect(path, NULL, drawingRect);
            CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
            CGPathRelease(path);
            CFRelease(framesetter);
            
            NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
            
            CGPoint origins[[linesArray count]];
            CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
            
            int line_y = (int) origins[[linesArray count] -1].y;  //最后一行line的原点y坐标
            
            CGFloat ascent;
            CGFloat descent;
            CGFloat leading;
            
            CTLineRef line = (__bridge CTLineRef) [linesArray objectAtIndex:[linesArray count]-1];
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            
            total_height = 1000- line_y + (int) ascent ;    //+1为了纠正descent转换成int小数点后舍去的值
            
            CFRelease(textFrame);
            
            doneBlock(total_height);
            
        });
        
    });

}



-(void)setText:(NSString *)text{

    [super setText:text];


}

/**
 *	@brief  递归筛选字符串
 *
 *	@param 	message 	要筛选的字符串   
 *  @param  array       传入的数组
 */
-(void)getImageRange:(NSString*)message andArray: (NSMutableArray*)array
 {
    NSRange range=[message rangeOfString:@"["];
    NSRange range1=[message rangeOfString:@"]"];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0 ) {
        
        if (range1.location<range.location) {
            [array addObject:[message substringToIndex:range1.location+1]];
            NSString *str = [message substringFromIndex:range1.location+1];
            [self getImageRange:str andArray:array];
        
            return;
        }
        if (range.location > 0) {
            
            if ([Emoji objectForKey:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]]) {//如果是表情 存入
                  [array addObject:[message substringToIndex:range.location ]];//存入@"["之前的
                 [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];//存入表情
                NSString *str=[message substringFromIndex:range1.location+1];//截取
                [self getImageRange:str andArray:array];
                return;
            }else{
                [array addObject:[message substringToIndex:range.location +1]];//不是表情 存入 包括 @"[" 及之前的
                NSString *str = [message substringFromIndex:range.location+1];
                [self getImageRange:str andArray:array];
                return;
            }
           
       
           
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            
            //排除文字是“”的
            if (![nextstr isEqualToString:@""] ) {
                
                if ([Emoji objectForKey:nextstr]) {
                    
                    [array addObject:nextstr];
                    
                    NSString *str=[message substringFromIndex:range1.location+1];
                    [self getImageRange:str andArray:array];
                    
                    return;
                }else{
                    [array addObject:[message substringToIndex:range.location+1]];
                    
                    NSString *str=[message substringFromIndex:range.location+1];
                    [self getImageRange:str andArray:array];
                    
                    return;
                }
                
                
                
                return;
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        [array addObject:message];
       
    }
}



@end
