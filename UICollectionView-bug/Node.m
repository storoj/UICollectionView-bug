//
// Created by Alexey Storozhev on 22/01/16.
// Copyright (c) 2016 Aleksey Storozhev. All rights reserved.
//

#import "Node.h"

static NodeChild *NodeGetChildAtIndexPath(Node *node, NSIndexPath *indexPath) {
    NSUInteger i = 0;
    const NSUInteger n = [indexPath length];
    
    NodeChild *res = nil;
    while (node != nil && i < n) {
        res = node.children[[indexPath indexAtPosition:i]];
        node = [res node];
    }
    
    return res;
}

@implementation Node
@end

@implementation NodeChild

- (instancetype)initWithNode:(Node *)node atPoint:(CGPoint)point {
    self = [super init];
    if (self) {
        _node = node;
        _origin = point;
    }
    return self;
}

+ (instancetype)childWithNode:(Node *)node {
    return [[self alloc] initWithNode:node atPoint:CGPointZero];
}

+ (instancetype)childWithNode:(Node *)node atPoint:(CGPoint)point {
    return [[self alloc] initWithNode:node atPoint:point];
}

@end

@implementation Node(IndexPath)

- (NodeChild *)childAtIndexPath:(NSIndexPath *)indexPath {
    return NodeGetChildAtIndexPath(self, indexPath);
}

@end
