//
//  SecondViewController.m
//  ViewControllerTest
//
//  Created by 李言 on 14-8-7.
//  Copyright (c) 2014年 ___李言___. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()
  
@property (nonatomic , strong) EmojiTextView  * mytextView;
@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
       
       
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    
    label = [[LYRichLabel alloc] initWithFrame:CGRectZero];
   //  label.backgroundColor = [UIColor greenColor];
    label.textColor = [UIColor blackColor];
    label.font= [UIFont  systemFontOfSize:15];
   // [label sizeToFit];
    [self.view addSubview:label];
    NSString *string = @"这里是展示的[高兴]~~";
    [label lblSizeEndChangedWithNewString:string WidthValue:320 EndBlock:^(CGFloat height) {
        
        label.frame = CGRectMake(0, 0, 320, height);
    }];

    label.text = string;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(200, 220, 40, 40) ;
    btn.backgroundColor= [UIColor blueColor];
    [btn setTitle:@"切换" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(faceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
     _mytextView = [[EmojiTextView alloc] initWithFrame:CGRectMake(0, 250, 320, 60)];
    //textfield.borderStyle =UITextBorderStyleLine;
    _mytextView.delegate = self;
    _mytextView.backgroundColor= [UIColor redColor];
    NSDictionary *facemap = [NSDictionary dictionaryWithContentsOfFile:
                [[NSBundle mainBundle] pathForResource:@"Emoji"
                                                ofType:@"plist"]];
    _mytextView.emojiNameArray = [facemap allKeys];
    [self.view addSubview:_mytextView];
    
    if (!faceView) {
        faceView = [[FaceView alloc] init];
        faceView.autoresizingMask = UIViewAutoresizingNone;
        faceView.delegate = self;

        
    }

}


-(void)backFace{


    [self.mytextView removePartTextStringWithStartRangeLocation:self.mytextView.selectedRange.location];



}

-(void)ClickFaceName:(NSString *)faceName{

    NSUInteger index = self.mytextView.selectedRange.location;
    NSMutableString *string = [[NSMutableString alloc] initWithString:self.mytextView.text ];
    
    [string insertString:faceName atIndex:self.mytextView.selectedRange.location];
   // [string appendString:faceName];
    
    self.mytextView.text =string;
    [self textViewDidChange:_mytextView];
    
    NSRange range;
    range.location = index + faceName.length;
    range.length = 0;
    self.mytextView.selectedRange = range;
    

}

-(void)faceBtnClick:(UIButton *)sender{

    if (!isFacebord) {
        [_mytextView resignFirstResponder];
        _mytextView.inputView=faceView;
       [UIView animateWithDuration:3 animations:^{
    
       } completion:^(BOOL finished) {
             [_mytextView becomeFirstResponder];
       }];
        
      
       isFacebord=YES;
    
     
    }else{
        
        [_mytextView resignFirstResponder];
        _mytextView.inputView = nil;
        isFacebord=NO;
        [UIView animateWithDuration:3 animations:^{
            
            
            
        } completion:^(BOOL finished) {
       [_mytextView becomeFirstResponder];
        }];
      
        
       
    
    }

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
   
  
    
    if ([text isEqualToString:@"\n"]) {
        
        [_mytextView resignFirstResponder];//隐藏键盘
        

        
        }

    return YES;

}

- (void)textViewDidChange:(UITextView *)textView{
   
    
   [label lblSizeEndChangedWithNewString:textView.text WidthValue:320 EndBlock:^(CGFloat height) {
       
       label.frame = CGRectMake(0, 0, 320, height);
   }];
    label.text = textView.text;
}


-(void)loaddata{
 
   [super loaddata];
  
 
  

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
