//
//  BYUtil.m
//  BestYou
//
//  Created by 胡阳 on 2020/4/30.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "BYUtil.h"

#import <Toast/Toast.h>
#import <Photos/Photos.h>
#import <SVProgressHUD/SVProgressHUD.h>

@implementation BYUtil

+ (void)saveImage:(UIImage *)image
{
    if (!image) {
        NSLog(@"to be saved image can not be nil");
        return;
    }
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if (data) {
        [self saveImageData:data];
    } else {
        NSLog(@"convert UIImage to NSData failed!");
    }
}

+ (void)saveImageData:(NSData *)imageData
{
    [SVProgressHUD show];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
                [SVProgressHUD dismissWithCompletion:^{
                    [keyWindow makeToast:@"保存照片成功!" duration:1.0 position:CSToastPositionCenter];
                }];
            });
        }
    }];
}

+ (BOOL)isMainThread
{
    return [[NSThread currentThread] isMainThread];
}

@end
