//
//  FileManager.h
//  Slide
//
//  Created by zhangYuan on 14-4-30.
//  Copyright (c) 2014年 EZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (void)writeToFileWithImage: (NSData*)data URL: (NSString*)url;
+ (NSData*)imageFromURL: (NSString*)url;
+ (NSValue*)imageSizeForURL: (NSString*)url;
+ (BOOL)removeFileWithURL: (NSString*)url;
+ (void)cleanWithCachesDirectory;
+ (void)cleanWithTemporaryDirectory;
+ (BOOL)imageIsExistAtURL:(NSString *)url;
@end
