//
//  LYLabel.m
//  ViewControllerTest
//
//  Created by 李言 on 14-8-8.
//  Copyright (c) 2014年 ___李言___. All rights reserved.
//

#import "LYLabel.h"
#import <CoreText/CoreText.h>
@implementation LYLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        rangeArr = [[NSMutableArray alloc] init];
    }
    return self;
}


-(void)getImageRange:(NSString*)message andArray: (NSMutableArray*)array {
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
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str andArray:array];
            return;
           // finalMessage = str;
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                
                [self getImageRange:str andArray:array];
                return;
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        [array addObject:message];
       
        //finalMessage = message;
    }
}


void RunDelegateDeallocCallback( void* refCon ){
}
CGFloat RunDelegateGetAscentCallback( void *refCon ){
    NSString *imageName = (__bridge NSString *)refCon;
    return [UIImage imageNamed:imageName].size.height;
}
CGFloat RunDelegateGetDescentCallback(void *refCon){
    return 0;
}
CGFloat RunDelegateGetWidthCallback(void *refCon){
    NSString *imageName = (__bridge NSString *)refCon;
    return [UIImage imageNamed:imageName].size.width;
}
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect (context, CGRectMake (0, 200, 200, 100 ));
    CGContextSetRGBFillColor (context, 0, 0, 1, .5);
    CGContextFillRect (context, CGRectMake (0, 200, 100, 200));
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);//设置字形变换矩阵为CGAffineTransformIdentity，也就是说每一个字形都不做图形变换
    CGAffineTransform flipVertical = CGAffineTransformMake(1,0,0,-1,0,self.bounds.size.height);
    CGContextConcatCTM(context, flipVertical);//将当前context的坐标系进行flip


    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text] ;
    UIFont *font = self.font;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    [attributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, [attributedString length])];
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)self.textColor.CGColor range:NSMakeRange(0, [attributedString length])];

    NSDictionary *Emoji=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"plist"]];
    NSMutableArray *array = [[NSMutableArray alloc] init];
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          [self  getImageRange:self.text andArray:array];
        
          dispatch_async(dispatch_get_main_queue(), ^{
              NSLog(@"%@",array);
              for ( int   i  =  0; i<[array count]; i++) {
                  NSString *taobaoImageName = [NSString stringWithFormat:@"%@",[Emoji objectForKey:[array objectAtIndex:i]]];
        
                  UIImage *img = [UIImage imageNamed:taobaoImageName];
                  CTRunDelegateCallbacks imageCallbacks;
                  imageCallbacks.version = kCTRunDelegateVersion1; //必须指定，否则不会生效，没有回调产生。
                  imageCallbacks.dealloc = RunDelegateDeallocCallback;
                  imageCallbacks.getAscent = RunDelegateGetAscentCallback;
                  imageCallbacks.getDescent = RunDelegateGetDescentCallback;
                  imageCallbacks.getWidth = RunDelegateGetWidthCallback;

                  NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "];//空格用于给图片留位置
                  [imageAttributedString addAttribute:@"imageName" value:taobaoImageName range:NSMakeRange(0, 1)];
                  CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, (__bridge void *)(taobaoImageName));
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

              CTParagraphStyleSetting lineBreakMode;
              CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;
              lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
              lineBreakMode.value = &lineBreak;
              lineBreakMode.valueSize = sizeof(CTLineBreakMode);
              
              CTParagraphStyleSetting settings[] = {
                  lineBreakMode
              };
              
              CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 1);
              
              
              // build attributes
              NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(__bridge id)style forKey:(id)kCTParagraphStyleAttributeName ];
              
              // set attributes to attributed string
              [attributedString addAttributes:attributes range:NSMakeRange(0, [attributedString length])];
              
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
                              imageDrawRect.size = image.size;
                              imageDrawRect.origin.x = runRect.origin.x + lineOrigin.x;
                              imageDrawRect.origin.y = lineOrigin.y; 
                              CGContextDrawImage(context, imageDrawRect, image.CGImage); 
                          } 
                      } 
                  } 
              } 
              CFRelease(ctFrame); 
              CFRelease(path); 
              CFRelease(ctFramesetter);

          });
      });
   
    }
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
