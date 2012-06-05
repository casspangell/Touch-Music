//
//  ViewController.m
//  TouchMusic
//
//  Created by Cassidy Pangell on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()

@end

OSStatus RenderTone(
                    void *inRefCon, 
                    AudioUnitRenderActionFlags 	*ioActionFlags, 
                    const AudioTimeStamp 		*inTimeStamp, 
                    UInt32 						inBusNumber, 
                    UInt32 						inNumberFrames, 
                    AudioBufferList 			*ioData)

{
	// Fixed amplitude is good enough for our purposes
	const double amplitude = 0.25;
    
	// Get the tone parameters out of the view controller
	ViewController *viewController =
    (ViewController *)inRefCon;
	double theta = viewController->theta;
	double theta_increment = 2.0 * M_PI * viewController->frequency / viewController->sampleRate;
    
	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++) 
	{
		buffer[frame] = sin(theta) * amplitude;
		
		theta += theta_increment;
		if (theta > 2.0 * M_PI)
		{
			theta -= 2.0 * M_PI;
		}
	}
	
	// Store the theta back in the view controller
	viewController->theta = theta;
    
	return noErr;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	ViewController *viewController =
    (ViewController *)inClientData;
	
	[viewController stop];
}

@implementation ViewController
@synthesize touchStatus, methodStatus, tapStatus, xyPoint, touchesView, accelerometer, playButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //TOUCH
    touchesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    touchesView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:touchesView];
    
    playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    playButton.frame = CGRectMake(85, 350, 150, 50);
    [playButton addTarget:self action:@selector(togglePlay:) forControlEvents:UIControlEventTouchDown];
    [playButton setTitle:NSLocalizedString(@"Play", nil) forState:0];
    [touchesView addSubview:playButton];
    
    //ACCELEROMETER
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.updateInterval = .1;
    self.accelerometer.delegate = self;
    
    //SOUND
    sampleRate = 44100;
    
	OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, self);
	if (result == kAudioSessionNoError)
	{
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	}
	AudioSessionSetActive(true);
}

#pragma mark - Sound



- (void)createToneUnit
{
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	NSAssert1(toneUnit, @"Error creating unit: %ld", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = self;
	err = AudioUnitSetProperty(toneUnit, 
                               kAudioUnitProperty_SetRenderCallback, 
                               kAudioUnitScope_Input,
                               0, 
                               &input, 
                               sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %ld", err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;	
	streamFormat.mBytesPerFrame = four_bytes_per_float;		
	streamFormat.mChannelsPerFrame = 1;	
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %ld", err);
}


-(void)colorChange{

    redPoint = redPoint * 200;
    greenPoint = greenPoint * 300;
    bluePoint = bluePoint * 750;
    
    NSLog(@"Color Change:(%f, %f, %f)", redPoint, greenPoint, bluePoint);
    
    frequency = (redPoint) + (greenPoint) + (bluePoint);
    
    
    
    NSLog(@"%@", [NSString stringWithFormat:@"%4.1f Hz", frequency]);
}

- (IBAction)togglePlay:(UIButton *)selectedButton
{
	if (toneUnit)
	{
		AudioOutputUnitStop(toneUnit);
		AudioUnitUninitialize(toneUnit);
		AudioComponentInstanceDispose(toneUnit);
		toneUnit = nil;
		
		[selectedButton setTitle:NSLocalizedString(@"Play", nil) forState:0];
	}
	else
	{
		[self createToneUnit];
		
		// Stop changing parameters on the unit
		OSErr err = AudioUnitInitialize(toneUnit);
		NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
		
		// Start playback
		err = AudioOutputUnitStart(toneUnit);
		NSAssert1(err == noErr, @"Error starting unit: %ld", err);
		
		[selectedButton setTitle:NSLocalizedString(@"Stop", nil) forState:0];
	}
}

- (void)stop
{
	if (toneUnit)
	{
        NSLog(@"stop");
		[self togglePlay:playButton];
	}
}

#pragma mark - Accelerometer

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    NSLog(@"Raw:(%f, %f, %f)", ABS(acceleration.x), ABS(acceleration.y), ABS(acceleration.z));
    
     redPoint = ABS(acceleration.x); 
     greenPoint = ABS(acceleration.y);
     bluePoint = ABS(acceleration.z);
    
    touchesView.backgroundColor = [[UIColor alloc] initWithRed:redPoint green:greenPoint blue:bluePoint alpha:1];
    [self colorChange];
}


#pragma mark - Touches

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
    
     redPoint = ((point.x*.79)/255.f); // 255/320 = .79
     greenPoint = ((point.y*.55)/255.f);// 255/480 = .53
     bluePoint = (point.x/255.f);
    
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
    AudioSessionSetActive(false);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
