//
//  NNViewController.m
//  SeniorProjectApp
//
//  Created by Nate Norberg on 3/19/14.
//  Copyright (c) 2014 Nate Norberg. All rights reserved.
//

#import "NNViewController.h"

@interface NNViewController ()

@end

@implementation NNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _player = [[NNPlayer alloc] init];
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

- (IBAction)filterCutoffChanged:(UISlider*)sender {
    [[self player] setCutoff:sender.value];
    _cutoffLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
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
    
    double cutoff = (scale * 4500) - 1200;
    [[self player] setCutoff:cutoff];
    _cutoffLabel.text = [NSString stringWithFormat:@"%d", (int)cutoff];
    
}

- (IBAction)panDetected:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender translationInView:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];
    double change = - point.y;
    double volumeChange = change / 5000.0;
    
    [self setVolume:[self volume] + volumeChange];
    
    _statusLabel.text = [NSString stringWithFormat:@"Panning: %f", -point.y];
}
 
@end
