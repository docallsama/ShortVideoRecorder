//
//  SYShortVideoRecorder.h
//  TestModLib
//
//  Created by 谢艺欣 on 2018/5/21.
//  Copyright © 2018年 Jeakon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYShortVideoRecorder : NSObject

/**
    所有视频的总时长
 */
@property (nonatomic, assign) CGFloat maxDuration;

/**
    预览用的view
 */
@property (nonatomic, strong, readonly) UIView *previewView;

/**
 处于录制状态时为 true
 */
@property (nonatomic, readonly) BOOL isRecording;

/**
    初始化使用的方法
 */
- (instancetype)initWithVideoConfiguration:(NSDictionary *)videoConfiguration audioConfiguration:(NSDictionary *)audioConfiguration;

/**
    翻转摄像头
 */
- (void)toggleCamera;

/**
    停止视频采集流
 */
- (void)stopCaptureSession;

/**
    开始视频采集流
 */
- (void)startCaptureSession;

/**
    开始录制视频
 */
- (void)startRecording;

/**
    停止录制视频
 */
- (void)stopRecording;

/**
    删除上一个录制的视频段
 */
- (void)deleteLastFile;

/**
    获取所有录制的视频段的地址
 */
- (NSArray<NSURL *> *__nullable)getAllFilesURL;

@end
