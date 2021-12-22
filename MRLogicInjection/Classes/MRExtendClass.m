//
//  MRExtendClass.m
//  MagicRemind
//
//  Created by baidu on 15/12/7.
//  Copyright © 2015年 dzpqzb. All rights reserved.
//

#import "MRExtendClass.h"
#import <objc/runtime.h>
#import "NSObject+MRInjectionLogicKey.h"

static void MRExtendBaseClassWithLogicClass(Class baseClass, Class logicClass) {
    unsigned int methodCount = 0;
    Method* logicMethodList= class_copyMethodList(logicClass, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        Method m = logicMethodList[i];
        class_addMethod(baseClass, method_getName(m), method_getImplementation(m), method_copyReturnType(m));
    }
    if (logicMethodList) {
        free(logicMethodList);
    }
}

NSString* const KMRExtendClassKey = @"__MR_EXTEND_";

Class MRExtendLogicCLass(Class baseClass, Class logicClass, NSString* key) {
    
    if (key.length == 0) {
        key = KMRExtendClassKey;
    }
    NSString* name = [key stringByAppendingString:NSStringFromClass(baseClass)];
    Class cla = NSClassFromString(name);
    if (!cla) {
        //alloc class pair
        cla = objc_allocateClassPair(baseClass, name.UTF8String, 0);
        //never try to add ivar to the new class, or you will find place using a wrong map.
        
        //register the class
        //
        objc_registerClassPair(cla);
        [(id)cla setMr_injection_superclass:baseClass];
    }
    [(id)cla setMr_injection_logic_key:key];
    [(id)cla setMr_injection_logic_class:logicClass];
    MRExtendBaseClassWithLogicClass(cla, logicClass);
    return cla;
}

Class MRExtendClass(Class baseClass, NSArray* logicClasses, NSString* key) {
    Class aimCla ;
    for (Class cla  in logicClasses) {
        aimCla = MRExtendLogicCLass(baseClass, cla, key);
        baseClass = aimCla;
    }
    return aimCla;
}

static BOOL IsKVOSubclass(id obj) {
    return [obj class] == class_getSuperclass(object_getClass(obj));
}

static void PatchKVOSubclass(Class class, NSArray* logicClasses, NSString* logicKey) {
    
    for (Class cla in logicClasses) {
        MRExtendBaseClassWithLogicClass(class, cla);
        
        [(id)class setMr_injection_superclass:class_getSuperclass(class)];
        [(id)class setMr_injection_logic_key:logicKey];
        [(id)class setMr_injection_logic_class:cla];
    }
}

id  MRExtendInstanceLogicWithKey(id object, NSString* logicKey,  NSArray* logicClasses) {
    if (!object) {
        return nil;
    }
    if (logicKey.length == 0) {
        return nil;
    }
    Class originClass = object_getClass(object);
    while ([(id)originClass mr_injection_logic_key]) {
        NSString* key = [(id)originClass mr_injection_logic_key];
        if ([key isEqualToString:logicKey]) {
            return object;
        }
        originClass = class_getSuperclass(originClass);
    }
    
    Class cla;
    if (IsKVOSubclass(object)) {
        PatchKVOSubclass(originClass, logicClasses, logicKey);
        cla = originClass;
    }
    else {
        cla = MRExtendClass(object_getClass(object), logicClasses, logicKey);
    }
    
    if (class_getSuperclass(cla) == originClass) {
        object_setClass(object, cla);
    }
    
    return object;
}

id  MRExtendInstanceLogic(id object, NSArray* logicClasses) {
    return MRExtendInstanceLogicWithKey(object, KMRExtendClassKey, logicClasses);
}

//wrong API, the method cached will cause crash, if you want to do this please remove the cached method
id MRRemoveExtendLogic(id object)
{
    if (!object) {
        return object;
    }
    Class cla = [object class];
    while ([(id)cla mr_injection_logic_key]) {
        cla = class_getSuperclass(cla);
    }
    if (cla) {
        Class originClass = cla;
        if (originClass) {
            object_setClass(object, originClass);
        }
    }
    return object;
}
//wrong API, the method cached will cause crash
id MRRemoveExtendSpecialLogic(id object, NSString* logicKey)
{
    if (!object) {
        return object;
    }
    Class startClass = nil;
    Class endClass = nil;
    
    Class claItor = [object class];
    Class claPrevious = nil;
    while ([(id)claItor mr_injection_logic_key]) {
        NSString* key = [(id)claItor mr_injection_logic_key];
        if ([key isEqualToString:logicKey]) {
            if (claPrevious) {
                startClass = claPrevious;
            }
        } else {
            if (startClass) {
                endClass = claItor;
                break;
            }
        }
        claPrevious = claItor;
        claItor = class_getSuperclass(claPrevious);
    }
    if (!endClass) {
        endClass = claItor;
    }
    object_setClass(object, endClass);
    return object;
}
