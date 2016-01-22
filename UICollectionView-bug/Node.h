//
// Created by Alexey Storozhev on 22/01/16.
// Copyright (c) 2016 Aleksey Storozhev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class NodeChild;
@interface Node : NSObject
@property (nonatomic, strong) NSArray <NodeChild *> *children;
@property (nonatomic, assign) CGSize size;
@end

@interface NodeChild : NSObject
@property (nonatomic, strong) Node *node;
@property (nonatomic, assign) CGPoint origin;

- (instancetype)initWithNode:(Node *)node atPoint:(CGPoint)point;
+ (instancetype)childWithNode:(Node *)node;
+ (instancetype)childWithNode:(Node *)node atPoint:(CGPoint)point;

@end

@interface Node(IndexPath)
- (NodeChild *)childAtIndexPath:(NSIndexPath *)indexPath;
@end
