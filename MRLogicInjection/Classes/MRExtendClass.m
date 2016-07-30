//
//  MRExtendClass.m
//  MagicRemind
//
//  Created by baidu on 15/12/7.
//  Copyright © 2015年 dzpqzb. All rights reserved.
//

#import "MRExtendClass.h"
#import <objc/runtime.h>
NSString* KMRExtendClassKey = @"MR_EXTEND_";

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


void MRExtendInstanceLogic(id object, NSArray* logicClasses) {
    if (!object) {
        return;
    }
    Class cla = MRExtendClass([object class], logicClasses, KMRExtendClassKey);
    object_setClass(object, cla);
}