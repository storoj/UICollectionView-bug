//
//  Runtime-Samples.m
//  UICollectionView-bug
//
//  Created by Alexey Storozhev on 23/01/16.
//  Copyright © 2016 Aleksey Storozhev. All rights reserved.
//

#import "Runtime-Samples.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation TestClass

- (void)hello {
    NSLog(@"Hello world!");
}

- (void)helloWithName:(NSString *)name {
    NSLog(@"Hello %@!", name);
}

- (NSInteger)addX:(NSInteger)x toY:(NSInteger)y {
    return x + y;
}

+ (void)test {
    TestClass *obj = [TestClass new];
    NSLog(@"-[TestClass hello]");
    [obj hello];
    
    NSLog(@"-[TestClass helloWithName:]");
    [obj helloWithName:@"Storoj"];
    
    NSLog(@"-[TestClass addX:3 toY:5]");
    NSLog(@"%ld", [obj addX:3 toY:5]);
}

static void TestClassHelloWithName(id self, SEL _cmd, NSString *name) {
    NSLog(@"DIE %@!", name);
}

- (void)updated_hello {
    NSLog(@"HELLO WORLD!!!");
}

+ (void)hook {
    Class cls = [TestClass class];
    
    {
        Method m1 = class_getInstanceMethod(cls, @selector(hello));
        Method m2 = class_getInstanceMethod(cls, @selector(updated_hello));

        method_exchangeImplementations(m1, m2);
    }
    
    {
        Method m = class_getInstanceMethod(cls, @selector(helloWithName:));
        method_setImplementation(m, (IMP)TestClassHelloWithName);
    }
    
    {
        SEL sel = @selector(addX:toY:);
        Method m = class_getInstanceMethod(cls, sel);
        IMP imp = method_getImplementation(m);
        // typedef void (*IMP)(void /* id, SEL, ... */ ); 

        id impBlock = ^NSInteger(id _self, NSInteger x, NSInteger y) {
            NSInteger origValue = ((NSInteger(*)(id, SEL, NSInteger, NSInteger))imp)(_self, sel, x*2, y-3);
            return origValue * 2;
        };
        method_setImplementation(m, imp_implementationWithBlock(impBlock));
    }
}

@end


/** 
 Implementation of such simple class
 
@interface HardcoreClass : NSObject
@property (nonatomic, strong, getter=nameGetter, setter=nameSetter:) NSString *name;
@end
*/

static void CreateHardcoreClass(void) __attribute__((constructor)) {

    /*
     Type Encodings – https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
     ObjC Runtime Reference - https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ObjCRuntimeRef/
     */
    
    Class cls = objc_allocateClassPair(objc_lookUpClass("NSObject"), "HardcoreClass", 0);
    class_addIvar(cls, "_name", sizeof(id), log2(sizeof(id)), @encode(NSInteger));
    Ivar nameIvar = class_getInstanceVariable(cls, "_name");

    const objc_property_attribute_t attrs[] = {
        { .name = "N" }, //nonatomic
        { .name = "&" }, // strong
        { .name = "G", .value = "nameGetter" },
        { .name = "S", .value = "nameSetter:" },
    };
    class_addProperty(cls, "name", attrs, 4);
    
    id getterBlock = ^id(id _self){
        return object_getIvar(_self, nameIvar);
    };
    IMP getterImp = imp_implementationWithBlock(getterBlock);
    class_addMethod(cls, sel_getUid("nameGetter"), getterImp, "@:@");

    id setterBlock = ^void(id _self, NSString *name){
        object_setIvar(_self, nameIvar, name);
    };
    IMP setterImp = imp_implementationWithBlock(setterBlock);
    class_addMethod(cls, sel_getUid("nameSetter:"), setterImp, "@:@");

    objc_registerClassPair(cls);

    id hardcoreObject = [objc_lookUpClass("HardcoreClass") new]; //class_createInstance(cls, 0);

    ((void(*)(id, SEL, id))objc_msgSend)(hardcoreObject, sel_getUid("nameSetter:"), @"-=HARD=-");
    NSString *name = ((id(*)(id, SEL))objc_msgSend)(hardcoreObject, sel_getUid("nameGetter"));
    NSLog(@"hardcore name: %@", name);
}