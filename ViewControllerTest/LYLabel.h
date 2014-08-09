//
//  LYLabel.h
//  ViewControllerTest
//
//  Created by 李言 on 14-8-8.
//  Copyright (c) 2014年 ___李言___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYLabel : UILabel
{
    NSString *finalMessage;
    NSMutableArray *rangeArr;
    
    long  charIndex;
    
    long  currnetCharIndex;
}
-(void)setRichText:(NSString *)text;
@end
