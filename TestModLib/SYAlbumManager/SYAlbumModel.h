//
//  SYAlbumModel.h
//  TestModLib
//
//  Created by 谢艺欣 on 2018/5/23.
//  Copyright © 2018年 Jeakon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SYAssetModelMediaTypePhoto = 0,
    SYAssetModelMediaTypeLivePhoto,
    SYAssetModelMediaTypePhotoGif,
    SYAssetModelMediaTypeVideo,
    SYAssetModelMediaTypeAudio
} SYAssetModelMediaType;

@class PHAsset;
@interface SYAssetModel : NSObject

@property (nonatomic, strong) id asset;             ///< PHAsset or ALAsset
@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo, default is No
@property (nonatomic, assign) SYAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

/// Init a photo dataModel With a asset
/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(id)asset type:(SYAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(id)asset type:(SYAssetModelMediaType)type timeLength:(NSString *)timeLength;

@end


@class PHFetchResult;
@interface SYAlbumModel : NSObject

@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) id result;             ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;

@property (nonatomic, assign) BOOL isCameraRoll;

@end
