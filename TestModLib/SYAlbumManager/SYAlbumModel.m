//
//  SYAlbumModel.m
//  TestModLib
//
//  Created by 谢艺欣 on 2018/5/23.
//  Copyright © 2018年 Jeakon. All rights reserved.
//

#import "SYAlbumModel.h"
#import "SYAlbumManager.h"

@implementation SYAssetModel

+ (instancetype)modelWithAsset:(id)asset type:(SYAssetModelMediaType)type{
    SYAssetModel *model = [[SYAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(SYAssetModelMediaType)type timeLength:(NSString *)timeLength {
    SYAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end

@implementation SYAlbumModel

- (void)setResult:(id)result {
    _result = result;
    BOOL allowPickingImage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sy_allowPickingImage"] isEqualToString:@"1"];
    BOOL allowPickingVideo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sy_allowPickingVideo"] isEqualToString:@"1"];
    
    [[SYAlbumManager manager] getAssetsFromFetchResult:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage completion:^(NSArray<SYAssetModel *> *models) {
        _models = models;
        if (_selectedModels) {
            
        }
    }];
}

@end
