//
//  ViewController.h
//  TouchMusic
//
//  Created by Cassidy Pangell on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController <UIAccelerometerDelegate>{
    
    UILabel *touchStatus;
    UILabel *methodStatus;
    UILabel *tapStatus;
    UILabel *xyPoint;
    UIButton *playButton;
    UIView *touchesView;
    
    UIAccelerometer *accelerometer;
    
    AudioComponentInstance toneUnit;
    
@public
	double frequency;
	double sampleRate;
	double theta;
    
    CGFloat redPoint, bluePoint, greenPoint;
}

@property (strong, nonatomic) IBOutlet UILabel *touchStatus;
@property (strong, nonatomic) IBOutlet UILabel *methodStatus;
@property (strong, nonatomic) IBOutlet UILabel *tapStatus;
@property (strong, nonatomic) IBOutlet UILabel *xyPoint;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic, retain) UIView *touchesView;
@property (nonatomic, retain) UIAccelerometer *accelerometer;

-(void) updateColor: (CGPoint *)touchPoint;
-(void) colorChange;
-(IBAction)togglePlay:(UIButton *)selectedButton;

@end
