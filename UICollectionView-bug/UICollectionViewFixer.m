//
//  UICollectionViewFixer.m
//  UICollectionView-bug
//
//  Created by Alexey Storozhev on 23/01/16.
//  Copyright © 2016 Aleksey Storozhev. All rights reserved.
//

#import "UICollectionViewFixer.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define FIX_ENABLED 0

@implementation UICollectionView(Fix)

#if (FIX_ENABLED)

static NSIndexPath *PatchedIndexPath(NSIndexPath *from, NSIndexPath *to)
{
    for (NSUInteger idx=to.length; idx<from.length; idx++) {
        to = [to indexPathByAddingIndex:[from indexAtPosition:idx]];
    }
    
    return to;
}

+ (void)load {
    
Class cls = objc_lookUpClass("UICollectionViewUpdate"); // NSClassFromString
{
SEL sel = sel_getUid("newIndexPathForSupplementaryElementOfKind:oldIndexPath:"); // NSSelectorFromString
Method m = class_getInstanceMethod(cls, sel);

// у методов первые два аргумента это `self` и `_cmd`,
// далее идут агрументы из интерфейса метода
NSIndexPath *(*realImp)(id, SEL, NSString *, NSIndexPath *) = (void*)method_getImplementation(m);

// У блоков, которые затем должны стать телом метода, нет аргумента с селектором.
// Там хитрая схема, при которой у блока всё равно есть два первых доп. аргумента,
// но они оба равны `self`. т.е. "настоящий" self блока от нас скрыт,
// а на самом деле на месте _self должен был бы быть _cmd.
// Два self были сделаны скорее всего только ради imp_implementationWithBlock

id block = ^(id _self, NSString *kind, NSIndexPath *oldIndexPath) {
    // oldIndexPath мог быть "длинный", например 0-1-2
    // в res окажется правильный новый indexPath, но без "хвоста". нам надо его приклеить обратно
    NSIndexPath *res = realImp(_self, sel, kind, oldIndexPath);
    res = PatchedIndexPath(oldIndexPath, res);
    return res;
};

IMP imp = imp_implementationWithBlock(block);

method_setImplementation(m, imp);
}
    
    {
        SEL sel = sel_getUid("oldIndexPathForSupplementaryElementOfKind:newIndexPath:");
        Method m = class_getInstanceMethod(cls, sel);
        
        NSIndexPath *(*realImp)(id, SEL, NSString *, NSIndexPath *) = (void*)method_getImplementation(m);
        
        method_setImplementation(m, imp_implementationWithBlock(^(id _self, NSString *kind, NSIndexPath *oldIndexPath) {
            return PatchedIndexPath(oldIndexPath, realImp(_self, sel, kind, oldIndexPath));
        }));
    }
}
#endif

@end
