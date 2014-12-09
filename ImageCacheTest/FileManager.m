//
//  FileManager.m
//  Slide
//
//  Created by zhangYuan on 14-4-30.
//  Copyright (c) 2014年 EZ. All rights reserved.
//

#import "FileManager.h"

#import <UIKit/UIKit.h>
@implementation FileManager

#pragma mark - Interface

+ (void)writeToFileWithImage: (NSData*)data URL: (NSString*)url
{
    NSString *fileName = [FileManager fileNameFromURL: url];
    NSString *cachesDirectory = [FileManager getCachesDirctory];
    NSString *imgPath = [cachesDirectory stringByAppendingPathComponent: fileName];
    [data writeToFile: imgPath options: NSDataWritingAtomic error: nil];
}

+ (NSData*)imageFromURL: (NSString*)url
{

    NSString *fileName = [FileManager fileNameFromURL: url];
    
    NSString *cachesDirectory = [FileManager getCachesDirctory];
    NSString *path = [cachesDirectory stringByAppendingPathComponent: fileName];
    
    if ([[self class] imageSizeForURL:url])
    {
        NSData *data = [NSData dataWithContentsOfFile: path];
        if (data && data.length)
        {
            return data;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

+ (BOOL)imageIsExistAtURL:(NSString *)url
{
    NSString *fileName = [FileManager fileNameFromURL: url];
    NSString *cachesDirectory = [FileManager getCachesDirctory];
    NSString *path = [cachesDirectory stringByAppendingPathComponent: fileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {

        return YES;
    }
    return NO;

}

+ (NSValue*)imageSizeForURL: (NSString*)url
{
    NSString *fileName = [FileManager fileNameFromURL: url];
    
    NSString *cachesDirectory = [FileManager getCachesDirctory];
    NSString *path = [cachesDirectory stringByAppendingPathComponent: fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: path])
    {
        NSData *imgData = [NSData dataWithContentsOfFile: path];

        UIImage *img = [UIImage imageWithData: imgData];
        return [NSValue valueWithCGSize: img.size];
    }
    else
    {
        return nil;
    }
}

+ (BOOL)removeFileWithURL: (NSString*)url
{
    NSString *fileName = [FileManager fileNameFromURL: url];
    
    NSString *cachesDirectory = [FileManager getCachesDirctory];
    NSString *path = [cachesDirectory stringByAppendingPathComponent: fileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath: path])
    {
        [[NSFileManager defaultManager] removeItemAtPath: path error: nil];
        
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (void)cleanWithCachesDirectory
{
    NSString *cachesDirectory = [FileManager getCachesDirctory];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath: cachesDirectory error: NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject]))
    {
        [fileManager removeItemAtPath: [cachesDirectory stringByAppendingPathComponent: filename] error: NULL];
    }
}

+ (void)cleanWithTemporaryDirectory
{
    NSString *tmpDir = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath: tmpDir error: NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject]))
    {
        [fileManager removeItemAtPath: [tmpDir stringByAppendingPathComponent: filename] error: NULL];
    }
}

#pragma mark - Private

+ (NSString*)getCachesDirctory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex: 0];
    NSString *cachesDirectory = [documentDirectory stringByAppendingPathComponent: @"/Caches/ImageCache"];

    if (![[NSFileManager defaultManager] fileExistsAtPath: cachesDirectory])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath: cachesDirectory withIntermediateDirectories: NO attributes: nil error: nil];
    }
    
    return cachesDirectory;
}

+ (NSString*)fileNameFromURL: (NSString*)url
{
    url = [url stringByReplacingOccurrencesOfString: @"http://" withString: @""];
    url = [url stringByReplacingOccurrencesOfString: @"." withString: @"_"];
    return [url stringByReplacingOccurrencesOfString: @"/" withString: @"_"];
}

@end
