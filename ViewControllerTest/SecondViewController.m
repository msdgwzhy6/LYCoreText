//
//  SecondViewController.m
//  ViewControllerTest
//
//  Created by 李言 on 14-8-7.
//  Copyright (c) 2014年 ___李言___. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
       
              NSLog(@"%s",__FUNCTION__);
       
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%s",__FUNCTION__);
    
    label = [[LYLabel alloc] initWithFrame:self.view.bounds];
   // label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor redColor];
    label.font= [UIFont  systemFontOfSize:24];
    label.text = @"[眼睛]是]罚[点]啥][好的]`234[ 324[好的]1[好 dsfasd的]423[][][][[[]fdf]][[][234234";
    [self.view addSubview:label];
}

-(void)loaddata{
 
   [super loaddata];
    NSLog(@"%s",__FUNCTION__);
 
    array = [NSArray array];
    NSLog(@"%@",array);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
