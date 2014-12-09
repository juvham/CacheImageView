//
//  PBImageOperation.h
//  ImageCacheTest
//
//  Created by Juvham on 14/12/9.
//  Copyright (c) 2014年 GouMin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBImageOperation : NSOperation

- (void)setCompletionBlockWithSuccess:(void (^)(PBImageOperation *operation, id responseObject))success
                              failure:(void (^)(PBImageOperation *operation, NSError *error))failure;

@end
