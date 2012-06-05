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
@synthesize touchStatus, methodStatus, tapStatus, xyPoint, touchesView, accelerometer, accelX, accelY, accelZ;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
    touchesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    touchesView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:touchesView];
    
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.updateInterval = .1;
    self.accelerometer.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    NSLog(@"Raw:(%f, %f, %f)", ABS(acceleration.x), ABS(acceleration.y), ABS(acceleration.z));
    
    CGFloat redPoint = ABS(acceleration.x); 
    CGFloat greenPoint = ABS(acceleration.y);
    CGFloat bluePoint = ABS(acceleration.z);
    
     NSLog(@"Accel:(%f, %f, %f)", redPoint, greenPoint, bluePoint);
    touchesView.backgroundColor = [[UIColor alloc] initWithRed:redPoint green:greenPoint blue:bluePoint alpha:1];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUInteger touchCount = [touches count];
    NSUInteger tapCount = [[touches anyObject] tapCount];
    methodStatus.text = @"touchesBegan";
    touchStatus.text = [NSString stringWithFormat:
                        @"%d touches", touchCount];
    tapStatus.text = [NSString stringWithFormat:
                      @"%d taps", tapCount];
    
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

    //fNSLog(@"move:%f %f %f", (point.x/255.f),(point.y/255.f),(point.x/255.f));
    
    CGFloat redPoint = ((point.x*.79)/255.f); //255/320 = .79
    CGFloat greenPoint = ((point.y*.55)/255.f);//255/480 = .53
    CGFloat bluePoint = (point.x/255.f);
    
    if(redPoint <= 0){
        redPoint = 0.0;
    }
    if(greenPoint <= 0){
        greenPoint = 0.0;
    }
    if(bluePoint <= 0){
        bluePoint = 0.0;
    }
    
    NSLog(@"points: %f, %f, %f (%f,%f)", redPoint, greenPoint, bluePoint, point.x, point.y);
    touchesView.backgroundColor = [[UIColor alloc] initWithRed:redPoint green:greenPoint blue:bluePoint alpha:1];
     
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
    
   // NSLog(@"%@", NSStringFromCGPoint(point));
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


@end
