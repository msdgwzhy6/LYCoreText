//
//  FaceView.m
//  ViewControllerTest
//
//  Created by 李言 on 14-8-11.
//  Copyright (c) 2014年 ___李言___. All rights reserved.
//

#import "FaceView.h"
#import "FaceDetailView.h"
@interface FaceView()
{
    int totalPage;
    UIScrollView * scroll;
}
@property (nonatomic,strong) NSArray * viewArr;
@end
@implementation FaceView

- (id)initWithFrame:(CGRect)frame
{

    
    self = [super initWithFrame:frame];
    if (self) {
          self.frame = CGRectMake(0, 0, 320, FaceKeyBoardHeight);
        // Initialization code
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"Emoji"
                                                    ofType:@"plist"]];
        totalPage = (int)([_faceMap count]/27+1);
   
        
        scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:scroll];
        scroll.pagingEnabled = YES;
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.delegate = self;
        
        NSMutableArray * array = [NSMutableArray array];
        for (int i=0;i<3 ;i++ )
        {
            CGRect eveRect = CGRectMake(0+i*scroll.bounds.size.width, 0, scroll.bounds.size.width, scroll.bounds.size.height);
            FaceDetailView * aView = [[FaceDetailView alloc] initWithFrame:eveRect];
            [scroll addSubview:aView];
            [array addObject:aView];
            
            aView.ClickFaceButton  =^(NSString * facename){
            
                [self.delegate ClickFaceName:facename];
            };
            
            aView.BackFace = ^{
                [self.delegate backFace];
            
            };
            

        }
        //添加PageControl
        grayPageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(110, self.bounds.size.height-20, 100, 20)];
        
        [grayPageControl addTarget:self
                            action:@selector(pageChange:)
                  forControlEvents:UIControlEventValueChanged];
        
        grayPageControl.numberOfPages = totalPage;
        grayPageControl.currentPage = 0;
        grayPageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        grayPageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        [self addSubview:grayPageControl];
        

        self.viewArr = array;
        [self prepareForPage:0];

        scroll.contentSize = CGSizeMake(scroll.bounds.size.width*totalPage, scroll.bounds.size.height);

    }
    return self;
}

-(void)pageChange:(id)sender{
    

    [scroll  setContentOffset:CGPointMake( grayPageControl.currentPage * scroll.bounds.size.width,0) animated:YES];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    int page = scrollView.contentOffset.x/scrollView.bounds.size.width;
    grayPageControl.currentPage= page;
    
    [self prepareForPage:page];
    [self prepareForPage:page-1];
    [self prepareForPage:page+1];

}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    int page = scrollView.contentOffset.x/scrollView.bounds.size.width;

    

}
-(void)prepareForPage:(int)page
{
    if (page<0)
    {
        return;
    }
    if (page>totalPage-1)
    {
        return;
    }
    
    int viewNum = page%3;
    //去处相应的view
    
    
    FaceDetailView * detail = [self.viewArr objectAtIndex:viewNum];
    if (detail.tag==page+300)
    {
        return;
    }
    detail.tag = page+300;
    
    [detail layOutFaceView:page];
    
    detail.frame  = CGRectMake(self.bounds.size.width*page, 0, self.bounds.size.width, self.bounds.size.height);
    
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
