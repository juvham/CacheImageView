//
//  UIImageView+Cache.m
//  ImageCacheTest
//
//  Created by Juvham on 14/12/2.
//  Copyright (c) 2014年 GouMin. All rights reserved.
//

#import "UIImageView+Cache.h"
#import "FileManager.h"
#import <objc/runtime.h>

#ifdef dispatch_main_sync_safe//(block)

#else
#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread])\
{\
block();\
}\
else\
{\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#endif
@interface PBImageCache : NSCache <PBImageCache>

@end

@interface UIImageView (_Cache)


@property (nonatomic ,setter = pb_setImageRequestOperation:) NSOperation *pb_imageRequestOperation;

@end

@implementation UIImageView (_Cache)

+ (NSOperationQueue *)pb_sharedImageRequestOperationQueue {
    static NSOperationQueue *_pb_sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pb_sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _pb_sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });

    return _pb_sharedImageRequestOperationQueue;
}

- (NSOperation*)pb_imageRequestOperation {
    return (NSOperation *)objc_getAssociatedObject(self, @selector(pb_imageRequestOperation));
}

- (void)pb_setImageRequestOperation:(NSOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, @selector(pb_imageRequestOperation), imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

static inline NSString * ImageCacheKeyFromURLRequest(NSURL *url) {
    return [url absoluteString];
}

@implementation PBImageCache

-(UIImage *)cachedImageForRequest:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)policy
{
    switch (policy) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
            break;

        default:
            break;
    }

    UIImage *image = [self objectForKey:ImageCacheKeyFromURLRequest(url)];

    NSLog(@"----////----%@",image);
    return image;
}
- (void)cacheImage:(UIImage *)image forRequest:(NSURL *)url
{
    if (image && url) {

        [self setObject:image forKey:ImageCacheKeyFromURLRequest(url)];
    }
}
@end

@implementation UIImageView (Cache)

+ (id<PBImageCache>)sharedImageCache
{
    static PBImageCache *_pb_defaultImageCache = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        _pb_defaultImageCache = [[PBImageCache alloc] init];

        [[NSNotificationCenter  defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *__unused note) {

            [_pb_defaultImageCache removeAllObjects];
        }];
    });

    NSLog(@"%@",self);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"

    NSLog(@"image %@",_pb_defaultImageCache);
    return objc_getAssociatedObject(self, @selector(sharedImageCache)) ?: _pb_defaultImageCache;


#pragma clang diagnostic pop
}

+ (void)setSharedImageCache:(id <PBImageCache>)imageCache {
    objc_setAssociatedObject(self, @selector(sharedImageCache), imageCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark -

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];

}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{

    [self setImageWithURL:url placeholderImage:placeholderImage cachePolicy:0];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage cachePolicy:(NSURLRequestCachePolicy)policy
{
    [self setImageWithURLRequest:url placeholderImage:placeholderImage cachePolicy:policy success:nil failure:nil];
}

- (void)setImageWithURLRequest:(NSURL *)url placeholderImage:(UIImage *)placeholderImage cachePolicy:(NSURLRequestCachePolicy)policy success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, UIImage *))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *))failure
{
    [self cancelImageRequestOperation];

    __weak __typeof(self)weakSelf = self;

    UIImage *cachedImage = [[[self class] sharedImageCache] cachedImageForRequest:url cachePolicy:policy];

    if (cachedImage) {

        if (success) {
            success(nil ,nil ,cachedImage);
        } else {

            dispatch_main_sync_safe(^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                strongSelf.image = cachedImage;
            });
        }

        self.pb_imageRequestOperation = nil;

    } else {

        if (placeholderImage) {
            dispatch_main_sync_safe(^{

                __strong __typeof(weakSelf)strongSelf = weakSelf;
                strongSelf.image = placeholderImage;

            });
        }

        NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];

        switch (policy) {
            case NSURLRequestReloadIgnoringCacheData:
            case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            {
                [blockOperation addExecutionBlock:^{
                    __strong __typeof (weakSelf) strongSelf = weakSelf;
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        if (success) {
                            success(nil,nil,image);
                        } else {
                            dispatch_main_sync_safe(^{
                                __strong __typeof(weakSelf)strongSelf = weakSelf;
                                strongSelf.image = image;
                            });
                        }
                        [[[strongSelf class] sharedImageCache] cacheImage:image forRequest:url];
                    } else {
                        if (failure) {
                            failure(nil,nil,[NSError errorWithDomain:[url absoluteString] code:10001 userInfo:@{@"error":@"can not download picture from this URl"} ]);
                        }
                    }
                    strongSelf.pb_imageRequestOperation = nil;
                }];
            }
                break;

            default:
            {
                [blockOperation addExecutionBlock:^{

                    __strong __typeof(weakSelf) strongSelf = weakSelf;

                    NSData *imageData = [FileManager imageFromURL:[url absoluteString]];
                    UIImage *image = [UIImage imageWithData:imageData];

                    if (image) {
                        if (success) {
                            success(nil,nil,image);
                        } else {
                            dispatch_main_sync_safe(^{
                                __strong __typeof(weakSelf)strongSelf = weakSelf;
                                strongSelf.image = image;
                            });
                        }

                        [[[strongSelf class] sharedImageCache] cacheImage:image forRequest:url];

                    } else {
                        NSData *data = [NSData dataWithContentsOfURL:url];
                        if (data.length) {
                            [FileManager writeToFileWithImage: data URL: [url absoluteString]];
                            UIImage *image = [UIImage imageWithData:data];

                            if (image) {

                                if (success) {
                                    success(nil,nil,image);
                                } else {
                                    dispatch_main_sync_safe(^{
                                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                                        strongSelf.image = image;
                                    });
                                }

                                [[[strongSelf class] sharedImageCache] cacheImage:image forRequest:url];
                            } else {

                                if (failure) {
                                    failure(nil,nil,[NSError errorWithDomain:[url absoluteString] code:10001 userInfo:@{@"error":@"can not download picture from this URl"} ]);
                                }
                            }
                        }
                    }

                    strongSelf.pb_imageRequestOperation = nil;
                }];

            }
                break;
        }

        self.pb_imageRequestOperation = blockOperation;


        [[[self class] pb_sharedImageRequestOperationQueue] addOperation:self.pb_imageRequestOperation];

    }

}
- (void)cancelImageRequestOperation
{
    [self.pb_imageRequestOperation cancel];
    
    self.pb_imageRequestOperation = nil;
}
@end
