//
//  NNViewController.m
//  SeniorProjectApp
//
//  Created by Nate Norberg on 3/19/14.
//  Copyright (c) 2014 Nate Norberg. All rights reserved.
//

#import "NNViewController.h"

#define kFilterMinimumFrequency 100
#define kFilterMaximumFrequency 20000

@interface NNViewController ()

@end

@implementation NNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _player = [[NNPlayer alloc] init];
    self.volume = 1.0;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setVolume:(double)volume {
    if (volume > 1) {
        _volume = 1;
    }
    else if (volume < 0) {
        _volume = 0;
    }
    else {
        _volume = volume;
    }
    
    [[self player] setVolume:_volume];
    _volumeLabel.text = [NSString stringWithFormat:@"%d", (int)(_volume * 100)];
}

-(void)setPanning:(double)panning {
    if (panning > 1) {
        _panning = 1;
    }
    else if (panning < -1) {
        _panning = -1;
    }
    else {
        _panning = panning;
    }
    
    [[self player] setPanning:_panning];
    _panningLabel.text = [NSString stringWithFormat:@"%f", _panning];
}

-(void)setCenterFrequency:(double)centerFrequency {
    if (centerFrequency > 22050)
        _centerFrequency = 22050;
    else if (centerFrequency < 100)
        _centerFrequency = 100;
    else
        _centerFrequency = centerFrequency;
    
    [[self player] setCenterFrequency:_centerFrequency];
    _centerFrequencyLabel.text = [NSString stringWithFormat:@"%d", (int)_centerFrequency];
}

-(void)setBandwidth:(double)bandwidth {
    if (bandwidth > kFilterMaximumFrequency) {
        _bandwidth = kFilterMaximumFrequency;
    }
    if (bandwidth < kFilterMinimumFrequency) {
        _bandwidth = kFilterMinimumFrequency;
    }
    else {
        _bandwidth = bandwidth;
    }
    
    [[self player] setBandwidth:_bandwidth];
    _bandwidthLabel.text = [NSString stringWithFormat:@"%d", (int)_bandwidth];
}

-(IBAction)playSound:(id)sender {
    if (![[self player] isPlaying]) {
        [[self player] playSound];
        [[self playButton] setTitle:@"Stop" forState:UIControlStateNormal];
        [[self playButton] setTintColor:[UIColor redColor]];
    }
    else {
        [[self player] stopSound];
        [[self playButton] setTitle:@"Play" forState:UIControlStateNormal];
        [[self playButton] setTintColor:[[UIColor alloc] initWithRed:0 green:0.5 blue:0 alpha:1]];
    }
}

- (IBAction)volumeChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    
    [self setVolume:slider.value];
}

- (IBAction)pinchDetected:(UIPinchGestureRecognizer *)sender {
    CGFloat scale =
    [(UIPinchGestureRecognizer *)sender scale];
    CGFloat velocity =
    [(UIPinchGestureRecognizer *)sender velocity];
    
    NSString *resultString = [[NSString alloc] initWithFormat:
                              @"Pinch - scale = %f\n velocity = %f",
                              scale, velocity];
    _statusLabel.text = resultString;
    
    double bandwidth = (scale * 600);
    self.bandwidth = bandwidth;
    
}

- (IBAction)panDetected:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender translationInView:self.touchPanel];
    double yChange = - point.y;
    double volumeChange = yChange / 5000.0;
    
    if ([sender numberOfTouches] == 2)
        [self setVolume:[self volume] + volumeChange];
    
    _statusLabel.text = [NSString stringWithFormat:@"Panning: %f", -point.y];
    
    if ([sender numberOfTouches] == 1) {
        double xChange = point.x;
        double frequencyChange = xChange;
        self.centerFrequency = self.centerFrequency + frequencyChange;
    }
}

- (IBAction)rotationDectected:(UIRotationGestureRecognizer *)sender {
    CGFloat rotation = [sender rotation];
    _statusLabel.text = [NSString stringWithFormat:@"Rotation: %f", rotation];
    
    double panning = rotation * 0.5;
    self.panning = panning;
}

- (IBAction)switchSound:(id)sender {
}
 
@end
