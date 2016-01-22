//
//  UICollectionViewTreeLayout.m
//  UICollectionView-bug
//
//  Created by Alexey Storozhev on 22/01/16.
//  Copyright © 2016 Aleksey Storozhev. All rights reserved.
//

#import "UICollectionViewTreeLayout.h"

static CGPoint CGPointAddPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

static void NodeVisitor(Node *node, NSIndexPath *p, CGPoint o, NSMutableArray *acc) {
    [node.children enumerateObjectsUsingBlock:^(NodeChild * _Nonnull child, NSUInteger idx, BOOL * _Nonnull stop) {
        const CGPoint origin = CGPointAddPoint(o, child.origin);
        NSIndexPath *indexPath = [p indexPathByAddingIndex:idx];
        
        UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:@"kind1"
                                                                                                                 withIndexPath:indexPath];
        attrs.frame = (CGRect){ .origin = origin, .size = child.node.size };
        attrs.zIndex = [indexPath length];
        [acc addObject:attrs];
        
        NodeVisitor(child.node, indexPath, origin, acc);
    }];
}

@implementation UICollectionViewTreeLayout
{
    NSDictionary *_itemAttributesMap;
    NSDictionary *_supplementaryAttributesMap;
    NSArray *_attributes;
    CGSize _contentSize;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    NSMutableArray *attrs = [NSMutableArray array];
    
    UICollectionView *collectionView = self.collectionView;
    id<UICollectionViewDelegateTreeLayout> delegate = (id)collectionView.delegate;
    
    
    CGFloat y = 10;
    for (NSInteger i=0; i<[collectionView numberOfItemsInSection:0]; i++) {
        CGPoint origin = CGPointMake(10, y);
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        Node *node = [delegate collectionView:collectionView layout:self nodeForIndexPath:indexPath];
        
        {
            UICollectionViewLayoutAttributes *cellAttrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            cellAttrs.frame = (CGRect){ .origin = origin, .size = node.size };
            [attrs addObject:cellAttrs];
            
            UICollectionViewLayoutAttributes *supAttrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:@"kind2" withIndexPath:indexPath];
            supAttrs.frame = CGRectInset((CGRect){ .origin = origin, .size = node.size }, 20, 20);
            supAttrs.zIndex = 1;
            [attrs addObject:supAttrs];
        }
        
        {
            NodeVisitor(node, indexPath, origin, attrs);
        }
        
        y += node.size.height + 10;
    }
    
    NSMutableDictionary *itemAttributesMap = [NSMutableDictionary dictionary];
    NSMutableDictionary *supplementaryAttributesMap = [NSMutableDictionary dictionary];
    [attrs enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL * _Nonnull stop) {
        
        switch (attribute.representedElementCategory) {
            case UICollectionElementCategoryCell:
                itemAttributesMap[attribute.indexPath] = attribute;
                break;
                
            case UICollectionElementCategorySupplementaryView:
                supplementaryAttributesMap[attribute.indexPath] = attribute;
                break;
                
            case UICollectionElementCategoryDecorationView:
                break;
        }
    }];
    
    _attributes = [attrs copy];
    _itemAttributesMap = [itemAttributesMap copy];
    _supplementaryAttributesMap = [supplementaryAttributesMap copy];
    
    _contentSize = CGSizeMake(collectionView.bounds.size.width, 300);
}

- (CGSize)collectionViewContentSize {
    return _contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return _attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    return _supplementaryAttributesMap[indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _itemAttributesMap[indexPath];
}
//
//- (NSArray<NSIndexPath *> *)indexPathsToInsertForSupplementaryViewOfKind:(NSString *)elementKind {
//}
//
//- (NSArray<NSIndexPath *> *)indexPathsToDeleteForSupplementaryViewOfKind:(NSString *)elementKind {
//
//}

- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
}

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
}

@end
