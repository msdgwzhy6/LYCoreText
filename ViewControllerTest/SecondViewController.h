//
//  SecondViewController.h
//  ViewControllerTest
//
//  Created by 李言 on 14-8-7.
//  Copyright (c) 2014年 ___李言___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "LYRichLabel.h"
#import "FaceView.h"
#import "EmojiTextView.h"
@interface SecondViewController : RootViewController<UITextViewDelegate,getFaceDelegete>
{

    NSArray *array ;
    
    LYRichLabel *label;
    
  
    FaceView *faceView;
  //  FaceBoard *faceBoard;
    BOOL isFacebord;

}

@end
