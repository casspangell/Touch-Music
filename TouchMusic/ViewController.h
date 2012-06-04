//
//  ViewController.h
//  TouchMusic
//
//  Created by Cassidy Pangell on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    
    UILabel *touchStatus;
    UILabel *methodStatus;
    UILabel *tapStatus;
    UILabel *xyPoint;

    UIView *touchesView;
}

@property (strong, nonatomic) IBOutlet UILabel *touchStatus;
@property (strong, nonatomic) IBOutlet UILabel *methodStatus;
@property (strong, nonatomic) IBOutlet UILabel *tapStatus;
@property (strong, nonatomic) IBOutlet UILabel *xyPoint;
@property (nonatomic, retain) UIView *touchesView;

-(void) updateColor: (CGPoint *)touchPoint;

@end
