//
//  ViewController.m
//  TestModLib
//
//  Created by 谢艺欣 on 2018/5/21.
//  Copyright © 2018年 Jeakon. All rights reserved.
//

#import "ViewController.h"
#import "SYShortVideoRecorder.h"

#define PLS_BaseToolboxView_HEIGHT 64
#define PLS_SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define PLS_SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)

@interface ViewController ()

@property (nonatomic, strong)SYShortVideoRecorder *shortVideoRecorder;
@property (nonatomic, strong)UIView *recordControlView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupVideoRecorder];
    [self setupTopControlView];
    [self setupRecordControlView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.shortVideoRecorder startCaptureSession];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.shortVideoRecorder stopCaptureSession];
}

#pragma mark - 配置

- (void)setupVideoRecorder {
    self.shortVideoRecorder = [[SYShortVideoRecorder alloc] initWithVideoConfiguration:nil audioConfiguration:nil];
    self.shortVideoRecorder.previewView.frame = CGRectMake(0, 0, PLS_SCREEN_WIDTH, PLS_SCREEN_HEIGHT);
    [self.view addSubview:self.shortVideoRecorder.previewView];
}

- (void)setupRecordControlView {
    self.recordControlView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.recordControlView];
    
    self.recordControlView.frame = CGRectMake(0, PLS_SCREEN_HEIGHT - 60, PLS_SCREEN_WIDTH, 40);
    
    UIButton *recordButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [recordButton addTarget:self action:@selector(onClickRecordButton:) forControlEvents:UIControlEventTouchUpInside];
    [recordButton setTitle:@"录制" forState:UIControlStateNormal];
    [self.recordControlView addSubview:recordButton];
}

- (void)setupTopControlView {
    
}

#pragma mark - target

- (void)onClickRecordButton:(UIButton *)sender {
    if (self.shortVideoRecorder) {
        [self.shortVideoRecorder stopRecording];
    } else {
        [self.shortVideoRecorder startRecording];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
