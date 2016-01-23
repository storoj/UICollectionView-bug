//
//  Runtime-Samples.h
//  UICollectionView-bug
//
//  Created by Alexey Storozhev on 23/01/16.
//  Copyright © 2016 Aleksey Storozhev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestClass : NSObject

- (void)hello;
- (void)helloWithName:(NSString *)name;
- (NSInteger)addX:(NSInteger)x toY:(NSInteger)y;

+ (void)hook;
+ (void)test;

@end

