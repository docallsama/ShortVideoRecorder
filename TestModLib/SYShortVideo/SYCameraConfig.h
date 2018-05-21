//
//  SYCameraConfig.h
//  SoYoungMobile40
//
//  Created by lichao on 2018/4/3.
//  Copyright © 2018年 soyoung. All rights reserved.
//

#ifndef SYCameraConfig_h
#define SYCameraConfig_h

// 摄像头的类型
typedef NS_ENUM(BOOL, ECameraType) {
    ECameraTypeFrontFacing, // 前置摄像头
    ECameraTypeRearFacing,  // 后置摄像头
};

// 闪光灯的类型
typedef NS_ENUM(NSInteger, EFlashType) {
    EFlashTypeClose,    // 关闭闪光灯
    EFlashTypeOpen,     // 打开闪光灯
    //    EFlashTypeAutomatic,  // 自动
    EFlashTypeAll,      // 占位
};

#endif /* SYCameraConfig_h */
