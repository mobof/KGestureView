//
//  ViewController.m
//  KGestureViewDemo
//
//  Created by 熊清 on 2020/8/31.
//  Copyright © 2020 格尔软件. All rights reserved.
//

#import "ViewController.h"
#import <KGestureView/KGestureView.h>

@interface ViewController ()
@property (weak,nonatomic) IBOutlet KGestureView *gestureView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _gestureView.mode = GESTURE_MODEL_REGIST;
    // Do any additional setup after loading the view.
}


@end
