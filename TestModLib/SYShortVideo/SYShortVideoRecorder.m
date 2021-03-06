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
        
//        [self deleteAllFiles];
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
    
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
        
        AVCaptureConnection *connection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoStabilizationSupported]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
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

- (NSInteger)getFilesCount {
    return self.localFilesArray.count;
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

//获取本地文件夹下全部视频文件以供清除
- (NSArray *)getLocalAllFiles {
    NSArray *doumenetPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [[doumenetPaths objectAtIndex:0] stringByAppendingPathComponent:@"com.SYShortVideo"];
    NSString *videoDir = [documentDir stringByAppendingPathComponent:@"tmpVideo"];
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filesArray = [fileManager contentsOfDirectoryAtPath:videoDir error:&error];
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (NSString *fileName in filesArray) {
        NSURL *path = [NSURL fileURLWithPath:[videoDir stringByAppendingPathComponent:fileName]];
        [resultArray addObject:path];
    }
    if (!error) {
        return resultArray;
    } else {
        return @[];
    }
}

//通过路径删除文件
- (void)deleteFileWithURL:(NSURL *)fileURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:[fileURL path]];
    NSError *error = nil;
    if (existed) {
        [fileManager removeItemAtURL:fileURL error:&error];
    }
}

- (void)deleteAllFiles {
    NSArray *filesArray = [self getLocalAllFiles];
    for (NSURL *fileUrl in filesArray) {
        [self deleteFileWithURL:fileUrl];
    }
}

- (void)convertVideo:(NSURL *)fileURL {
    // 通过文件的 url 获取到这个文件的资源
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    // 用 AVAssetExportSession 这个类来导出资源中的属性
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    // 压缩视频
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) { // 导出属性是否包含低分辨率
        // 通过资源（AVURLAsset）来定义 AVAssetExportSession，得到资源属性来重新打包资源 （AVURLAsset, 将某一些属性重新定义
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetLowQuality];
        // 设置导出文件的存放路径
        NSString *outPutPath = [[fileURL absoluteString] stringByReplacingOccurrencesOfString:@".mov" withString:@".mp4"];
        exportSession.outputURL = [NSURL URLWithString:outPutPath];
        
        // 是否对网络进行优化
        exportSession.shouldOptimizeForNetworkUse = true;
        
        // 转换成MP4格式
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        // 开始导出,导出后执行完成的block
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            // 如果导出的状态为完成
            if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更新一下显示包的大小
                    NSLog(@"convert finish");
                });
            } else {
                NSLog(@"error -> %@",exportSession.error);
            }
        }];
    }
}

#pragma mark - delegates

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    NSLog(@"output complete in -> %@",outputFileURL);
    
    [self convertVideo:outputFileURL];
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
