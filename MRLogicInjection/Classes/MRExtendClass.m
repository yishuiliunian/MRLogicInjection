//
//  MRExtendClass.m
//  MagicRemind
//
//  Created by baidu on 15/12/7.
//  Copyright © 2015年 dzpqzb. All rights reserved.
//

#import "MRExtendClass.h"
#import <objc/runtime.h>
NSString* const KMRExtendClassKey = @"__MR_EXTEND_";

Class MRExtendLogicCLass(Class baseClass, Class logicClass, NSString* key) {
    
    NSString* name = [KMRExtendClassKey stringByAppendingString:NSStringFromClass(baseClass)];
    Class cla = NSClassFromString(name);
    if (!cla) {
        cla = objc_allocateClassPair(baseClass, name.UTF8String, 0);
        objc_registerClassPair(cla);
    }
    unsigned int methodCount = 0;
    Method* logicMethodList= class_copyMethodList(logicClass, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        Method m = logicMethodList[i];
        class_addMethod(cla, method_getName(m), method_getImplementation(m), method_copyReturnType(m));
    }
    return cla;
}

Class MRExtendClass(Class baseClass, NSArray* logicClasses, NSString* key) {
    Class aimCla ;
    for (Class cla  in logicClasses) {
        aimCla = MRExtendLogicCLass(baseClass, cla, key);
    }
    return aimCla;
}

id  MRExtendInstanceLogicWithKey(id object,NSString* logicKey,  NSArray* logicClasses) {
    if (!object) {
        return nil;
    }
    if (logicKey.length == 0) {
        return nil;
    }
    if ([NSStringFromClass([object class]) hasPrefix:logicKey] ) {
        return object;
    }
    Class cla = MRExtendClass([object class], logicClasses, logicKey);
    object_setClass(object, cla);
    return object;
}

id  MRExtendInstanceLogic(id object, NSArray* logicClasses) {
    return MRExtendInstanceLogicWithKey(object, KMRExtendClassKey, logicClasses);
}


id MRRemoveExtendLogic(id object)
{
    NSString* className = NSStringFromClass([object class]);
    if ([className hasPrefix:KMRExtendClassKey]) {
        NSString* originClassName = [className substringFromIndex:KMRExtendClassKey.length];
        Class originClass = NSClassFromString(originClassName);
        if (originClass) {
            object_setClass(object, originClass);
        }
    }
    return object;
}