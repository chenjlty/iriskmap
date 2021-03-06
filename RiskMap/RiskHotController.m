//
//  RiskHotController.m
//  RiskMap
//
//  Created by steven on 7/14/13.
//  Copyright (c) 2013 laka. All rights reserved.
//

#import "AppDelegate.h"
#import "RiskHotController.h"
#import "DBUtils.h"
#import "Matrix.h"
#import "VectorDetail.h"
#import "Score.h"
#import "Vector.h"
#import "MyLongPressGestureRecognizer.h"

int MAX_SIZE = 35 ;

@interface RiskHotController ()

@end

@implementation RiskHotController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    BOOL shouldAutorotate = NO;
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        shouldAutorotate = YES;
    }
    
    return shouldAutorotate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.redImage = [UIImage imageNamed:@"redball.png"] ;
    self.blueImage = [UIImage imageNamed:@"blueball.png"] ;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate] ;
    self.matrixArray = [DBUtils getProjectMatrix:appDelegate.currProjectMap] ;
    self.vectorArray = [DBUtils getVector:appDelegate.currProjectMap] ;
    self.matrixTitleArray = [DBUtils getProjectMatrixTitle:appDelegate.currProjectMap] ;
    self.currMatrix = 0 ;
    if(isIpad){
        MAX_SIZE = 100 ;
    }
    self.isManage = NO ;
    
    Project *project = [DBUtils getProjectInfo:appDelegate.currProjectMap] ;
    if(!project.show_after){
        self.switchButton.hidden = YES ;
    }
    if(!project.show_sort){
        self.sortButton.hidden = YES ;
    }
    
    [self showMatrixMap] ;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showMatrixMap
{
    
    //清空
    NSArray *subViews = [self.hotView subviews] ;
    for(int i = 0; i < subViews.count; i++){
        UIView *view = [subViews objectAtIndex:i] ;
        [view removeFromSuperview] ;
    }
    
    NSString *title = [self.matrixTitleArray objectAtIndex:self.currMatrix] ;
    
    self.maxX = 0 ;
    self.maxY = 0 ;
    
    for(int i = 0; i < self.matrixArray.count; i++){
        Matrix *matrix = [self.matrixArray objectAtIndex:i] ;
        if([title isEqualToString:matrix.matrix_title]){
            if(self.maxX < [matrix.xIndex intValue]){
                self.maxX = [matrix.xIndex intValue] ;
            }
            if(self.maxY < [matrix.yIndex intValue]){
                self.maxY = [matrix.yIndex intValue] ;
            }
        }
    }
    
    self.maxX++ ;
    self.maxY++ ;
    
    //绘制矩阵 先计算矩阵的大小
    if(isIpad){
        self.mSize = 600/self.maxY ;
    }else{
        self.mSize = 170/self.maxY ;
    }
    
    /*
    if(self.mSize > MAX_SIZE){
        self.mSize = MAX_SIZE ;
    }
    */
    
    //开始绘制矩形
    for(int i = 0; i < self.matrixArray.count; i++){
        Matrix *matrix = [self.matrixArray objectAtIndex:i] ;
        if([title isEqualToString:matrix.matrix_title]){
            int xIndex = [matrix.xIndex intValue] ;
            int yIndex = [matrix.yIndex intValue] ;
            yIndex = self.maxY - yIndex  - 1;
            int x = 80 + self.mSize*xIndex + xIndex;
            int y = (ScreenHeight - 64)/2.0 + self.mSize*self.maxY/2.0 - yIndex*self.mSize - yIndex - self.mSize;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(x, y, self.mSize, self.mSize) ;
            [button setEnabled:NO] ;
            //NSLog(@"#### %@", matrix.levelType) ;
            if(matrix.Color == -65536){
                [button setBackgroundColor:[UIColor redColor]] ;
            }else if(matrix.Color == -256){
                [button setBackgroundColor:[UIColor yellowColor]] ;
            }else if(matrix.Color == -16744448){
                [button setBackgroundColor:[UIColor greenColor]] ;
            }else {
                [button setBackgroundColor:[UIColor grayColor]] ;
            }
            //[button setTitle:matrix.levelType forState:UIControlStateNormal] ;
            [self.hotView addSubview:button] ;
            int fontSize = 10 ;
            if(isIpad){
                fontSize = 12 ;
            }
            if(xIndex == 0){
                //最左边的矩阵
                NSMutableArray *yVector = [DBUtils getProjectVectorDetail:matrix.matrix_y] ;
                NSLog(@"---- %@", matrix.matrix_y) ;
                VectorDetail *yv = [yVector objectAtIndex:yIndex] ;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, y + self.mSize/2 - 10, 40, 20)];
                label.numberOfLines = 1;
                label.textAlignment = UITextAlignmentCenter;
                [label setText:[NSString stringWithFormat:@"%@", yv.levelTitle]] ;
                [label setTextColor:[UIColor blueColor]] ;
                [label setFont:[UIFont fontWithName:@"Arial" size:fontSize]] ;
                [label setBackgroundColor:[UIColor clearColor]] ;
                [self.hotView addSubview:label] ;
                
                NSArray *scores = [yv.score componentsSeparatedByString:@"-"] ;
                UILabel *label01 = [[UILabel alloc] initWithFrame:CGRectMake(40, y + self.mSize - 10, 40, 20)];
                label01.numberOfLines = 1;
                label01.textAlignment = UITextAlignmentCenter;
                [label01 setText:[NSString stringWithFormat:@"%@", scores[0]]] ;
                [label01 setFont:[UIFont fontWithName:@"Arial" size:fontSize]] ;
                [label01 setBackgroundColor:[UIColor clearColor]] ;
                if([@"0" isEqualToString:scores[0]]){
                    if(isIpad){
                        label01.frame = CGRectOffset(label01.frame, 0, self.mSize/5) ;
                    }else{
                        label01.frame = CGRectOffset(label01.frame, 0, self.mSize/3) ;
                    }
                }
                [self.hotView addSubview:label01] ;
                
                UILabel *label02 = [[UILabel alloc] initWithFrame:CGRectMake(40, y - 10, 40, 20)];
                label02.numberOfLines = 1;
                label02.textAlignment = UITextAlignmentCenter;
                [label02 setText:[NSString stringWithFormat:@"%@", scores[1]]] ;
                [label02 setFont:[UIFont fontWithName:@"Arial" size:fontSize]] ;
                [label02 setBackgroundColor:[UIColor clearColor]] ;
                [self.hotView addSubview:label02] ;
                
                
                NSLog(@"---- %d, %d", yIndex, self.maxX) ;
                if(yIndex == (int)(self.maxY/2)){
                    UILabel *label03 = [[UILabel alloc] initWithFrame:CGRectMake(5 , y + self.mSize/2 - 10, 40, 40)];
                    label03.textAlignment = UITextAlignmentCenter;
                    NSString *title = @"" ;
                    for(int m = 0; m < self.vectorArray.count; m++){
                        Vector *v = [self.vectorArray objectAtIndex:m] ;
                        if([v.vectorId isEqualToString:matrix.matrix_y]){
                            title = v.title ;
                        }
                    }
                    label03.lineBreakMode = UILineBreakModeWordWrap; 
                    label03.numberOfLines = 0 ;
                    NSString *theTitle = [title substringWithRange:NSMakeRange(0, 1)] ;
                    for(int i = 1; i < title.length; i++){
                        theTitle = [NSString stringWithFormat:@"%@\n%@", theTitle, [title substringWithRange:NSMakeRange(i, 1)]];
                    }
                    NSLog(@"####**** %@", theTitle) ;
                    [label03 setText:[NSString stringWithFormat:@"%@", theTitle]] ;
                    [label03 setFont:[UIFont fontWithName:@"Arial" size:fontSize]] ;
                    [label03 setBackgroundColor:[UIColor clearColor]] ;
                    [self.hotView addSubview:label03] ;
                }

            }
            if(yIndex == 0){
                //最下边的矩阵
                NSMutableArray *xVector = [DBUtils getProjectVectorDetail:matrix.matrix_x] ;
                VectorDetail *xv = [xVector objectAtIndex:xIndex] ;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y + self.mSize + 5 - 10, self.mSize, 40)];
                label.numberOfLines = 1;
                label.textAlignment = UITextAlignmentCenter;
                [label setText:[NSString stringWithFormat:@"%@", xv.levelTitle]] ;
                [label setFont:[UIFont fontWithName:@"Arial" size:fontSize]] ;
                [label setTextColor:[UIColor blueColor]] ;
                label.textAlignment = UITextAlignmentCenter;
                [label setBackgroundColor:[UIColor clearColor]] ;
                [self.hotView addSubview:label] ;
                
                NSArray *scores = [xv.score componentsSeparatedByString:@"-"] ;
                
                if(![@"0" isEqualToString:scores[0]]){
                }
                
                UILabel *label01 = [[UILabel alloc] initWithFrame:CGRectMake(x - self.mSize/2, y + self.mSize + 5 - 10, self.mSize, 40)];
                label01.numberOfLines = 1;
                label01.textAlignment = UITextAlignmentCenter;
                [label01 setText:[NSString stringWithFormat:@"%@", scores[0]]] ;
                [label01 setFont:[UIFont fontWithName:@"Arial" size:fontSize]] ;
                label01.textAlignment = UITextAlignmentCenter;
                [label01 setBackgroundColor:[UIColor clearColor]] ;
                if(![@"0" isEqualToString:scores[0]]){
                    [self.hotView addSubview:label01] ;
                }
                
                UILabel *label02 = [[UILabel alloc] initWithFrame:CGRectMake(x + self.mSize/2, y + self.mSize + 5 - 10, self.mSize, 40)];
                label02.numberOfLines = 1;
                label02.textAlignment = UITextAlignmentCenter;
                [label02 setText:[NSString stringWithFormat:@"%@", scores[1]]] ;
                [label02 setFont:[UIFont fontWithName:@"Arial" size:fontSize]] ;
                label02.textAlignment = UITextAlignmentCenter;
                [label02 setBackgroundColor:[UIColor clearColor]] ;
                [self.hotView addSubview:label02] ;
                
                if(xIndex == (int)(self.maxX/2)){
                    UILabel *label03 = [[UILabel alloc] initWithFrame:CGRectMake(x, y + self.mSize + 5 + 10, self.mSize, 40)];
                    label03.textAlignment = UITextAlignmentCenter;
                    NSString *title = @"" ;
                    for(int m = 0; m < self.vectorArray.count; m++){
                        Vector *v = [self.vectorArray objectAtIndex:m] ;
                        if([v.vectorId isEqualToString:matrix.matrix_x]){
                            title = v.title ;
                        }
                    }
                    [label03 setText:[NSString stringWithFormat:@"%@", title]] ;
                    [label03 setFont:[UIFont fontWithName:@"Arial" size:fontSize]] ;
                    [label03 setBackgroundColor:[UIColor clearColor]] ;
                    [self.hotView addSubview:label03] ;
                }
            }
        }
    }
    
    //开始绘制点
    Matrix *matrix = [self.matrixArray objectAtIndex:self.currMatrix] ;
    NSMutableArray *xArray = [DBUtils getRiskScore:matrix.matrix_x] ;
    NSLog(@"#### [%d][%@]", xArray.count, matrix.matrix_x) ;
    NSMutableArray *yArray = [DBUtils getRiskScore:matrix.matrix_y] ;
    NSLog(@"#### [%d][%@]", yArray.count, matrix.matrix_y) ;
    int maxWidth = ScreenWidth ;
    for(int i = 0; i < xArray.count; i++){
        Score *xScore = [xArray objectAtIndex:i] ;
        Score *yScore = [yArray objectAtIndex:i] ;
        double x = 0 ;
        double y = 0 ;
        if(self.isManage){
            //遍历找该属于的点
            NSMutableArray *xVector = [DBUtils getProjectVectorDetail:matrix.matrix_x] ;
            NSMutableArray *yVector = [DBUtils getProjectVectorDetail:matrix.matrix_y] ;
            for(int i = 0; i < xVector.count; i++){
                VectorDetail *xv = [xVector objectAtIndex:i] ;
                NSArray *scores = [xv.score componentsSeparatedByString:@"-"] ;
                double begin = [[scores objectAtIndex:0] doubleValue] ;
                double end = [[scores objectAtIndex:1] doubleValue] ;
                if(xScore.scoreEnd < end && xScore.scoreEnd >= begin){
                    x = 80 + self.mSize*([xv.sort intValue] - 1) + [xv.sort intValue] - 1 + self.mSize*((xScore.scoreEnd - begin)/(end - begin));
                    NSLog(@"####SCORE x [%d][%d][%f]", [xv.sort intValue], self.mSize, (xScore.scoreEnd - begin)/(end - begin)) ;
                    NSLog(@"####SCORE x [%f][%f][%f][%@][%f]", xScore.scoreEnd, begin, end, xv.sort, x) ;
                }
            }
            for(int i = 0; i < yVector.count; i++){
                VectorDetail *yv = [yVector objectAtIndex:i] ;
                NSArray *scores = [yv.score componentsSeparatedByString:@"-"] ;
                double begin = [[scores objectAtIndex:0] doubleValue] ;
                double end = [[scores objectAtIndex:1] doubleValue] ;
                if(yScore.scoreEnd < end && yScore.scoreEnd >= begin){
                    y = (ScreenHeight - 64)/2.0 + self.mSize*self.maxY/2.0 - (self.mSize*([yv.sort intValue] - 1) + [yv.sort intValue] - 1 + self.mSize*((yScore.scoreEnd - begin)/(end - begin)));
                    NSLog(@"####SCORE y [%d][%d][%f]", [yv.sort intValue], self.mSize, (yScore.scoreEnd - begin)/(end - begin)) ;
                    NSLog(@"####SCORE y [%f][%f][%f][%@][%f]", yScore.scoreEnd, begin, end, yv.sort, y) ;
                }
            }
        }else{
            //遍历找该属于的点
            NSMutableArray *xVector = [DBUtils getProjectVectorDetail:matrix.matrix_x] ;
            NSMutableArray *yVector = [DBUtils getProjectVectorDetail:matrix.matrix_y] ;
            for(int i = 0; i < xVector.count; i++){
                VectorDetail *xv = [xVector objectAtIndex:i] ;
                NSArray *scores = [xv.score componentsSeparatedByString:@"-"] ;
                double begin = [[scores objectAtIndex:0] doubleValue] ;
                double end = [[scores objectAtIndex:1] doubleValue] ;
                if(xScore.scoreBefore < end && xScore.scoreBefore >= begin){
                    x = 80 + self.mSize*([xv.sort intValue] - 1) + [xv.sort intValue] - 1 + self.mSize*((xScore.scoreBefore - begin)/(end - begin));
                    NSLog(@"####SCORE x [%d][%d][%f]", [xv.sort intValue], self.mSize, (xScore.scoreBefore - begin)/(end - begin)) ;
                    NSLog(@"####SCORE x [%f][%f][%f][%@][%f]", xScore.scoreBefore, begin, end, xv.sort, x) ;
                }
            }
            for(int i = 0; i < yVector.count; i++){
                VectorDetail *yv = [yVector objectAtIndex:i] ;
                NSArray *scores = [yv.score componentsSeparatedByString:@"-"] ;
                double begin = [[scores objectAtIndex:0] doubleValue] ;
                double end = [[scores objectAtIndex:1] doubleValue] ;
                if(yScore.scoreBefore < end && yScore.scoreBefore >= begin){
                    y = (ScreenHeight - 64)/2.0 + self.mSize*self.maxY/2.0 - (self.mSize*([yv.sort intValue] - 1) + [yv.sort intValue] - 1 + self.mSize*((yScore.scoreBefore - begin)/(end - begin))) ;
                    NSLog(@"####SCORE y [%d][%d][%f]", [yv.sort intValue], self.mSize, (yScore.scoreBefore - begin)/(end - begin)) ;
                    NSLog(@"####SCORE y [%f][%f][%f][%@][%f]", yScore.scoreBefore, begin, end, yv.sort, y) ;
                }
            }
        }
        //绘制Y
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if(isIpad){
            button.frame = CGRectMake(x - 10, y - 10, 20, 20) ;
        }else{
            button.frame = CGRectMake(x - 5, y - 5, 10, 10) ;
        }
        [button setBackgroundImage:self.redImage forState:UIControlStateNormal] ;
        [button setEnabled:NO] ;
        [self.hotView addSubview:button] ;
        button.tag = 100 + i ;
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate] ;
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        if(isIpad){
            button2.frame = CGRectMake(self.mSize*self.maxX + 100 + 320*(i/20), 52 + 30*(i%20), 300, 20) ;
        }else{
            button2.frame = CGRectMake(self.mSize*self.maxX + 100 + 200*(i/10), 43 + 17*(i%10), 180, 15) ;
        }
        if(button2.frame.origin.x + button2.frame.size.width > maxWidth){
            maxWidth = button2.frame.origin.x + button2.frame.size.width ;
        }
        [button2 setEnabled:YES] ;
        if(isIpad){
            button2.titleLabel.font = [UIFont systemFontOfSize:14];
        }else{
            button2.titleLabel.font = [UIFont systemFontOfSize:10];
        }
        [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal] ;
        [button2 setTitle:[DBUtils getRisk:appDelegate.currProjectMap RiskId:xScore.riskid] forState:UIControlStateNormal] ;
        [button2 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft] ;
        [button2 addTarget:self action:@selector(showRiskDot:) forControlEvents:UIControlEventTouchUpInside];
        
        //添加长按事件
        MyLongPressGestureRecognizer *gr =  [[MyLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:) context:xScore.riskid];
        [button2 addGestureRecognizer:gr];
        gr.context = [xScore.riskid copy] ;
        [gr release];
        
        [self.hotView addSubview:button2] ;
        button2.tag = 200 + i ;
    }
    NSLog(@"123123 %d", maxWidth) ;
    self.scrollView.contentSize = CGSizeMake(maxWidth, ScreenHeight - 64) ;
    self.hotView.frame = CGRectMake(0,0,maxWidth, ScreenHeight - 64) ;
}

- (IBAction) showRiskDot:(id)sender
{
    //先重置所有的BUTTON
    Matrix *matrix = [self.matrixArray objectAtIndex:self.currMatrix] ;
    NSMutableArray *xArray = [DBUtils getRiskScore:matrix.matrix_x] ;
    for(int i = 0; i < xArray.count; i++){
        UIButton *b1 = (UIButton *)[self.hotView viewWithTag:(i + 100)] ;
        UIButton *b2 = (UIButton *)[self.hotView viewWithTag:(i + 200)] ;
        [b1 setBackgroundImage:self.redImage forState:UIControlStateNormal] ;
        [b2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal] ;
    }
    
    UIButton *button1 = (UIButton *)sender ;
    UIButton *button2 = (UIButton *)[self.hotView viewWithTag:(button1.tag - 100)] ;
    UIImage *currImage = [button2 backgroundImageForState:UIControlStateNormal] ;
    [button1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal] ;
    if(currImage == self.redImage){
        [button2 setBackgroundImage:self.blueImage forState:UIControlStateNormal] ;
    }else{
        [button2 setBackgroundImage:self.redImage forState:UIControlStateNormal] ;
    }
}

- (IBAction) gotoLastPageButtonAction:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate] ;
    [appDelegate gotoLastPage] ;
}

- (IBAction) gotoRiskSortButtonAction:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate] ;
    appDelegate.currMatrix = self.currMatrix ;
    appDelegate.isManage = self.isManage ;
    [appDelegate gotoRiskSortPage] ;
}

- (IBAction) switchButtonAction:(id)sender
{
    self.isManage = !self.isManage ;
    if(self.isManage){
        [self.switchButton setTitle:@"管理后" forState:UIControlStateNormal] ;
    }else{
        [self.switchButton setTitle:@"管理前" forState:UIControlStateNormal] ;
    }
    [self showMatrixMap] ;
}

- (IBAction) selectHotButtonAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"风险矩阵列表"
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:nil];
    actionSheet.delegate = self ;
    for(int i = 0; i < self.matrixTitleArray.count; i++){
        [actionSheet addButtonWithTitle:[self.matrixTitleArray objectAtIndex:i]] ;
    }
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    //actionSheet.cancelButtonIndex = actionSheet.numberOfButtons;
    [actionSheet showInView:self.view];
}

- (void)handleLongPress:(MyLongPressGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        NSLog(@"######## %@", gestureRecognizer.context) ;
        
        NSString *text = @"" ;
        
        Matrix *matrix = [self.matrixArray objectAtIndex:self.currMatrix] ;
        
        NSString *yTitle = nil ;
        NSString *xTitle = nil ;
        
        for(int m = 0; m < self.vectorArray.count; m++){
            Vector *v = [self.vectorArray objectAtIndex:m] ;
            if([v.vectorId isEqualToString:matrix.matrix_y]){
                yTitle = v.title ;
            }
            if([v.vectorId isEqualToString:matrix.matrix_x]){
                xTitle = v.title ;
            }
        }
        
        NSMutableArray *xArray = [DBUtils getRiskScore:matrix.matrix_x] ;
        NSMutableArray *yArray = [DBUtils getRiskScore:matrix.matrix_y] ;
        
        for(int i = 0 ; i < xArray.count; i++){
            Score *xScore = [xArray objectAtIndex:i] ;
            Score *yScore = [yArray objectAtIndex:i] ;
            if([xScore.riskid isEqualToString:gestureRecognizer.context]){
                if(self.isManage){
                    text = [NSString stringWithFormat:@"%@%@ %.2f\n", text, xTitle, xScore.scoreEnd] ;
                }else{
                    text = [NSString stringWithFormat:@"%@%@ %.2f\n", text, xTitle, xScore.scoreBefore] ;
                }
            }
            if([yScore.riskid isEqualToString:gestureRecognizer.context]){
                if(self.isManage){
                    text = [NSString stringWithFormat:@"%@%@ %.2f\n", text, yTitle, yScore.scoreEnd] ;
                }else{
                    text = [NSString stringWithFormat:@"%@%@ %.2f\n", text, yTitle, yScore.scoreBefore] ;
                }
            }
        }
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate] ;
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:[DBUtils getRisk:appDelegate.currProjectMap RiskId:gestureRecognizer.context] message:text delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.hotView ;
}

#pragma mark -
#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"#### actionSheet") ;
    NSLog(@"#### actionSheet [%d]", buttonIndex) ;
    if(buttonIndex < self.matrixTitleArray.count){
        self.currMatrix = buttonIndex ;
        [self showMatrixMap] ;
    }
}
- (void)actionSheetCancel:(UIActionSheet *)actionSheet{
    NSLog(@"#### actionSheetCancel") ;
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"#### didDismissWithButtonIndex") ;
}
-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"#### willDismissWithButtonIndex") ;
}

@end
