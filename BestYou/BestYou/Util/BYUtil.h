//
//  BYUtil.h
//  BestYou
//
//  Created by 胡阳 on 2020/4/30.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BYUtil : NSObject

+ (void)saveImage:(UIImage *)image;

+ (void)saveImageData:(NSData *)imageData;

+ (NSArray *)allFilterList;

@end

NS_ASSUME_NONNULL_END
