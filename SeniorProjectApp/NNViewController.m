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

-(IBAction)playSound:(UIButton *)sender {
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
    
    [[self player] setVolume:slider.value];
}

- (IBAction)filterCutoffChanged:(UISlider*)sender {
    [[self player] setCutoff:sender.value];
    _cutoffLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
}

@end
