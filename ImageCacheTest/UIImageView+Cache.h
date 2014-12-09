//
//  UIImageView+Cache.h
//  ImageCacheTest
//
//  Created by Juvham on 14/12/2.
//  Copyright (c) 2014年 GouMin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PBImageCache <NSObject>

- (UIImage *)cachedImageForRequest:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)policy;

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURL *)url;

@end

@interface UIImageView (Cache)

+ (id <PBImageCache>)sharedImageCache;

+ (void)setSharedImageCache:(id <PBImageCache>)imageCache;

- (void)setImageWithURL:(NSURL *)url;

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage cachePolicy:(NSURLRequestCachePolicy)policy;

- (void)setImageWithURLRequest:(NSURL *)url
              placeholderImage:(UIImage *)placeholderImage
                   cachePolicy:(NSURLRequestCachePolicy)policy
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (void)cancelImageRequestOperation;

- (void)loadUrl;

@end
