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
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sound playing"
//                                                    message:@"You pressed the play button"
//                                                   delegate:nil cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil, nil];
//    [alert show];
    [[self player] playSound];
}

@end
