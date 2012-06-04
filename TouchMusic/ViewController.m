//
//  ViewController.m
//  TouchMusic
//
//  Created by Cassidy Pangell on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize touchStatus, methodStatus, tapStatus, xyPoint, touchesView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    touchesView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 440)];
    touchesView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:touchesView];
}

-(void) updateColor: (CGPoint *)touchPoint{
    

}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUInteger touchCount = [touches count];
    NSUInteger tapCount = [[touches anyObject] tapCount];
    methodStatus.text = @"touchesBegan";
    touchStatus.text = [NSString stringWithFormat:
                        @"%d touches", touchCount];
    tapStatus.text = [NSString stringWithFormat:
                      @"%d taps", tapCount];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];

    CGFloat pointX = point.x;
    CGFloat pointY = point.y;

    xyPoint.text = [NSString stringWithFormat:@"%@", NSStringFromCGPoint(point)];
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUInteger touchCount = [touches count];
    NSUInteger tapCount = [[touches anyObject] tapCount];
    methodStatus.text = @"touchesMoved";
    touchStatus.text = [NSString stringWithFormat:
                        @"%d touches", touchCount];
    tapStatus.text = [NSString stringWithFormat:
                      @"%d taps", tapCount];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    CGFloat pointX = point.x;
    CGFloat pointY = point.y;
    
    NSLog(@"move:%f %f", pointX,pointY);
    touchesView.backgroundColor = [[UIColor alloc] initWithRed:(point.x/255.f) green:(point.y/255.f) blue:(0/255.f) alpha:1];
     
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUInteger touchCount = [touches count];
    NSUInteger tapCount = [[touches anyObject] tapCount];
    methodStatus.text = @"touchesEnded";
    touchStatus.text = [NSString stringWithFormat:
                        @"%d touches", touchCount];
    tapStatus.text = [NSString stringWithFormat:
                      @"%d taps", tapCount];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    NSLog(@"%@", NSStringFromCGPoint(point));
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
