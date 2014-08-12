//
//  LYLabel.h
//  ViewControllerTest
//
//  Created by 李言 on 14-8-8.
//  Copyright (c) 2014年 ___李言___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYRichLabel : UILabel
{

    
  
    
    NSDictionary *Emoji;
  
    
}



/**
 *	@brief	计算高度
 *
 *	@param 	string 	<#string description#>
 */
- (void)lblSizeEndChangedWithNewString:(NSString *)string  WidthValue:(float) width EndBlock:(void(^)(CGFloat height))doneBlock;


@end