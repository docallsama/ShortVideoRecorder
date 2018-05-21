//
//  SYShortVideoRecorder.m
//  TestModLib
//
//  Created by 谢艺欣 on 2018/5/21.
//  Copyright © 2018年 Jeakon. All rights reserved.
//

#import "SYShortVideoRecorder.h"
#import "SYCameraConfig.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface SYShortVideoRecorder() <AVCaptureFileOutputRecordingDelegate> {
    
}

@property (nonatomic, assign) CGFloat lastDuratioin;    //剩余可拍摄的时长
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, assign) ECameraType cameraType;   // 摄像头类型
@property (nonatomic, weak) AVCaptureDevice *activeCamera;  // 当前使用的相机设备
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput; //视频输出

@property (nonatomic, strong) NSMutableArray *localFilesArray;  //本地视频数组

@end

@implementation SYShortVideoRecorder

- (instancetype)initWithVideoConfiguration:(NSDictionary *)videoConfiguration audioConfiguration:(NSDictionary *)audioConfiguration {
    self = [super init];
    if (self) {
        _captureSession = [[AVCaptureSession alloc] init];
        _cameraType = ECameraTypeRearFacing;
        _lastDuratioin = 60.0f;
        _localFilesArray = [[NSMutableArray alloc] init];
        
        [self configCaptureSessionInput];
        [self configCaptureSessionAudioInput];
        [self configCaptureSessionOutput];
        [self configVideoPreviewView];
        
    }
    return self;
}

//配置拍摄流
- (void)configCaptureSessionInput {
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    // 获取当前的摄像头
    for (AVCaptureDevice *device in AVCaptureDevice.devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            switch (self.cameraType) {
                case ECameraTypeRearFacing:
                    if ([device position] == AVCaptureDevicePositionBack) {
                        _activeCamera = device;
                    }
                    break;
                case ECameraTypeFrontFacing:
                    if ([device position] == AVCaptureDevicePositionFront) {
                        _activeCamera = device;
                    }
                    break;
            }
        }
    }
    
    NSError *error = nil;
    BOOL deviceAvailability = YES;
    
    // 获取当前摄像头的输入流
    AVCaptureDeviceInput *cameraDevieInput = [AVCaptureDeviceInput deviceInputWithDevice:_activeCamera error:&error];
    // 权限判断 && 为会话提供的摄像头输入的流
    if (!error && [self.captureSession canAddInput:cameraDevieInput]) {
        [self.captureSession addInput:cameraDevieInput];
    } else {
        deviceAvailability = NO;
    }
    
}

//配置音频输入流
- (void)configCaptureSessionAudioInput {
    NSError *error = nil;
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    AVCaptureDeviceInput *audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    if (!error && [self.captureSession canAddInput:audioCaptureDeviceInput]) {
        [self.captureSession addInput:audioCaptureDeviceInput];
    }
}

//配置输出流
- (void)configCaptureSessionOutput {
    
//    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    CMTime maxDuration = CMTimeMake(_lastDuratioin, 1);
    self.movieOutput.maxRecordedDuration = maxDuration;
    AVCaptureConnection *connection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
//    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
//    if (connection.isActive) {
//        NSLog(@"satate success");
//    } else {
//        NSLog(@"satate fail");
//    }
    
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    else {
        // Handle the failure.
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        [device lockForConfiguration:nil];
        device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        [device unlockForConfiguration];
    }
}

//配置预览流
- (void)configVideoPreviewView {
    _previewView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.previewView.bounds;
    [self.previewView.layer addSublayer:self.previewLayer];
    
    [self addObserver:self forKeyPath:@"previewView.frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)toggleCamera {
    
}

- (void)stopCaptureSession
{
    [self.captureSession stopRunning];
}

- (void)startCaptureSession
{
    [self.captureSession startRunning];
}

- (void)startRecording {
    NSURL *fileURL = [self getNewFileURL];
    [self.localFilesArray addObject:fileURL];
    [self.movieOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
}

- (void)stopRecording {
    [self.movieOutput stopRecording];
}

- (BOOL)isRecording {
    return self.movieOutput.isRecording;
}

- (void)deleteLastFile {
    if (self.localFilesArray.count == 0) {
        return;
    }
    NSURL *fileURL = self.localFilesArray.lastObject;
    [self deleteFileWithURL:fileURL];
}

- (NSArray *)getAllFilesURL {
    return [self.localFilesArray copy];
}

#pragma mark - file method

//获取一个文件URL
- (NSURL *)getNewFileURL {
    NSArray *doumenetPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [[doumenetPaths objectAtIndex:0] stringByAppendingPathComponent:@"com.SYShortVideo"];
    NSString *videoDir = [documentDir stringByAppendingPathComponent:@"tmpVideo"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:videoDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:videoDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *timeStr = [formatter stringFromDate:[NSDate date]];
    NSString *path = [videoDir stringByAppendingPathComponent:[NSString stringWithFormat:@"V_%@.mov",timeStr]];
    return [NSURL fileURLWithPath:path];
}

//删除文件
- (void)deleteFileWithURL:(NSURL *)fileURL {
    
}

#pragma mark - delegates

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    NSLog(@"output complete in -> %@",outputFileURL);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"previewView.frame"]) {
        self.previewLayer.frame = [change[NSKeyValueChangeNewKey] CGRectValue];
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"previewView.frame"];
}

@end
