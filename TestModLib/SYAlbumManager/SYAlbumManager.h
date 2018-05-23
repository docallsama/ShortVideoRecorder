//
//  SYAlbumManager.h
//  TestModLib
//
//  Created by 谢艺欣 on 2018/5/23.
//  Copyright © 2018年 Jeakon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYAlbumModel.h"

@interface SYAlbumManager : NSObject

+ (instancetype)manager;

- (BOOL)authorizationStatusAuthorized;
- (void)requestAuthorizationWithCompletion:(void (^)())completion;

- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<SYAssetModel *> *models))completion;

@end
