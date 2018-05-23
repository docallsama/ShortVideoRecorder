//
//  SYAlbumManager.m
//  TestModLib
//
//  Created by 谢艺欣 on 2018/5/23.
//  Copyright © 2018年 Jeakon. All rights reserved.
//

#import "SYAlbumManager.h"
#import <Photos/Photos.h>

@interface SYAlbumManager ()

@property (nonatomic, strong) PHPhotoLibrary *photoLibrary;

@end

@implementation SYAlbumManager

static SYAlbumManager *manager;
static dispatch_once_t onceToken;

+ (instancetype)manager {
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (PHPhotoLibrary *)photoLibrary {
    if (_photoLibrary == nil) {
        _photoLibrary = [[PHPhotoLibrary alloc] init];
    }
    return _photoLibrary;
}

- (BOOL)authorizationStatusAuthorized {
    NSInteger status = [PHPhotoLibrary authorizationStatus];
    
    if (status == 0) {
        [self requestAuthorizationWithCompletion:nil];
    }
    
    return status == 3;
}

- (void)requestAuthorizationWithCompletion:(void (^)())completion {
    void (^callCompletionBlock)() = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            callCompletionBlock();
        }];
    });
    
}

/// Get Assets 获得照片数组
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<SYAssetModel *> *))completion {

    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
    
    PHFetchResult *tempResult = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    [tempResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.estimatedAssetCount > 0) {
            
            SYAssetModel *model = [self getAssetModelWith:obj];
            [assetArray addObject:model];
            
        }
        NSLog(@"obj count -> %zd \n obj name -> %@", obj.estimatedAssetCount, obj.localizedTitle);
    }];
    
    NSLog(@"result -> %@",tempResult);
}

///  Get asset at index 获得下标为index的单个照片
///  if index beyond bounds, return nil in callback 如果索引越界, 在回调中返回 nil
- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(SYAssetModel *))completion {
    
}

- (SYAssetModel *)getAssetModelWith:(id)obj {
    SYAssetModel *model = [[SYAssetModel alloc] init];
    
//    if ([obj isKindOfClass:[PHAssetCollection class]]) {
//
//        SYAssetModel *model = [SYAssetModel modelWithAsset:obj type:<#(SYAssetModelMediaType)#>]
//    } else {
//
//    }
    return model;
}

@end
