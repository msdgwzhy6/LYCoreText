//
//  EmojiTextView.m
//  emoji
//
//  Created by Apple on 14-8-11.
//
//

#import "EmojiTextView.h"
@interface EmojiTextView()<UITextViewDelegate>
{
    id<UITextViewDelegate>  _emojiDelegate;
}
@end
@implementation EmojiTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        _delegate = self;
        self.delegate = self;
    }
    return self;
}
-(void)removePartTextStringWithStartRangeLocation:(NSInteger)location
{
//    return;
    
    if (location<1)
    {
        return;
    }
    NSRange range = NSMakeRange(location-1,1);
//    NSString * selectStr =  [self.text substringWithRange:range];
    
    BOOL remove = [self.delegate textView:self shouldChangeTextInRange:range replacementText:@""];
    if (!remove)
    {
        return;
    }
    
    
    range = NSMakeRange(self.selectedRange.location-1, 1);
    self.text = [self.text stringByReplacingCharactersInRange:range withString:@""];
    self.selectedRange = NSMakeRange(range.location, 0);
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(textViewDidChange:)])
    {
        [self.delegate textViewDidChange:self];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:nil];
    
    
}

-(void)setDelegate:(id<UITextViewDelegate>)delegate
{
    if (delegate==self)
    {
        [super setDelegate:delegate];
        return;
    }
    _emojiDelegate = delegate;
}
#pragma mark - privateMethods
-(NSString *)singlePartStringInTextViewWithEndPointLocation:(NSInteger)endPt
{
    //当删除单一]时
    NSString * total = self.text;
    if ([total length]<=endPt)
    {
        return nil;
    }
    
    NSString * eveStr = [total substringWithRange:NSMakeRange(endPt, 1)];
    if ([eveStr isEqualToString:@"]"])
    {
        NSInteger maxLenth  =  8;
        if (endPt<maxLenth)
        {
            maxLenth = endPt;
        }
        NSString * effectStr = [total substringWithRange:NSMakeRange(endPt-maxLenth,maxLenth)];
        NSArray * leftArr = [effectStr componentsSeparatedByString:@"["];
        if (leftArr&&[leftArr count]>1)
        {
            NSString * leftStr = [leftArr lastObject];

            return leftStr;
        }
    }

    
    return nil;
}

#pragma mark - UITextViewDelegate

//自定义的修改
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.length==1&&[text length]==0)
    {
        //进行删除操作
        NSString * partStr = [self singlePartStringInTextViewWithEndPointLocation:range.location];
        NSInteger endPt = range.location;
        
        //当存在时
        if (partStr)
        {
            BOOL result = YES;
            BOOL effective = NO;
            
            NSString *compareStr = [NSString stringWithFormat:@"[%@]",partStr];
            if ([self.emojiNameArray containsObject:compareStr])
            {
                effective = YES;
            }
            
            //当包含有效的数据时，此时应让子类判定新的字符串
            if (effective)
            {
                NSInteger start = endPt;
                NSRange newRange = NSMakeRange(start - [partStr length]-1 ,[partStr length]+2);
                
                if (_emojiDelegate&&[_emojiDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
                {
                    result = [_emojiDelegate textView:textView shouldChangeTextInRange:newRange replacementText:text];
                }
                
                //移除  表情串
                if (result)
                {//当确定要删除的字符串时,返回NO，自己实现删除
                    
                    NSRange select = self.selectedRange;
                    NSRange removeRange = NSMakeRange(newRange.location, newRange.length-1);
                    
                    self.text = [self.text stringByReplacingCharactersInRange:removeRange withString:text];
                    //及时改变selectRange
                    self.selectedRange = NSMakeRange(select.location-removeRange.length, 0);
                    
                    return YES;
                }
                
                return result;
            }
        }
    }
    if (_emojiDelegate&&[_emojiDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
    {
        return [_emojiDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (_emojiDelegate&&[_emojiDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)])
    {
        return [_emojiDelegate textViewShouldBeginEditing:textView];
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (_emojiDelegate&&[_emojiDelegate respondsToSelector:@selector(textViewShouldEndEditing:)])
    {
        [_emojiDelegate textViewShouldEndEditing:textView];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (_emojiDelegate&&[_emojiDelegate respondsToSelector:@selector(textViewDidBeginEditing:)])
    {
        [_emojiDelegate textViewDidBeginEditing:textView];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (_emojiDelegate&&[_emojiDelegate respondsToSelector:@selector(textViewDidEndEditing:)])
    {
        [_emojiDelegate textViewDidEndEditing:textView];
    }
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (_emojiDelegate&&[_emojiDelegate respondsToSelector:@selector(textViewDidChange:)])
    {
        [_emojiDelegate textViewDidChange:textView];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{

    if (_emojiDelegate&&[_emojiDelegate respondsToSelector:@selector(textViewDidChangeSelection:)])
    {
        [_emojiDelegate textViewDidChangeSelection:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    
    if (_emojiDelegate&&[_emojiDelegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)])
    {
        return  [_emojiDelegate textView:textView shouldInteractWithURL:URL inRange:characterRange];
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange{
    
    if (_emojiDelegate&&[_emojiDelegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)])
    {
        return  [_emojiDelegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    }
    return YES;
}

#pragma mark -

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
