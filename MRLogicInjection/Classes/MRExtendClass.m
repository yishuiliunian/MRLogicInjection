//
//  MRExtendClass.m
//  MagicRemind
//
//  Created by baidu on 15/12/7.
//  Copyright © 2015年 dzpqzb. All rights reserved.
//

#import "MRExtendClass.h"
#import <objc/runtime.h>
#import <pthread.h>
#import "NSObject+MRInjectionLogicKey.h"

@interface NSObject (MRInjectionSwizzled)
- (void)MRInjection_KVO_original_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
- (void)MRInjection_KVO_original_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
@end

static pthread_mutex_t gMutex;

#if USE_BLOCKS_BASED_LOCKING
#define BLOCK_QUALIFIER __block
static void WhileLocked(void (^block)(void))
{
    pthread_mutex_lock(&gMutex);
    block();
    pthread_mutex_unlock(&gMutex);
}
#define WhileLocked(block) WhileLocked(^block)
#else
#define BLOCK_QUALIFIER
#define WhileLocked(block) do { \
        pthread_mutex_lock(&gMutex); \
        block \
        pthread_mutex_unlock(&gMutex); \
    } while(0)
#endif

static void KVOSubclassRemoveObserverForKeyPath(id self, SEL _cmd, id observer, NSString *keyPath)
{
    WhileLocked({
        IMP originalIMP = class_getMethodImplementation(object_getClass(self), @selector(MRInjection_KVO_original_removeObserver:forKeyPath:));
        ((void (*)(id, SEL, id, NSString *))originalIMP)(self, _cmd, observer, keyPath);
    });
}

static void KVOSubclassRemoveObserverForKeyPathContext(id self, SEL _cmd, id observer, NSString *keyPath, void *context)
{
    WhileLocked({
        IMP originalIMP = class_getMethodImplementation(object_getClass(self), @selector(MRInjection_KVO_original_removeObserver:forKeyPath:context:));
        ((void (*)(id, SEL, id, NSString *, void *))originalIMP)(self, _cmd, observer, keyPath, context);
    });
}

static void MRExtendBaseClassWithLogicClass(Class baseClass, Class logicClass) {
    unsigned int methodCount = 0;
    Method* logicMethodList= class_copyMethodList(logicClass, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        Method m = logicMethodList[i];
        class_addMethod(baseClass, method_getName(m), method_getImplementation(m), method_copyReturnType(m));
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

static void PatchKVOSubclass(Class class, NSArray* logicClasses) {
    Method removeObserverForKeyPath = class_getInstanceMethod(class, @selector(removeObserver:forKeyPath:));
    
    for (Class cla in logicClasses) {
        MRExtendBaseClassWithLogicClass(class, cla);
    }
    
    class_addMethod(class,
                    @selector(MRInjection_KVO_original_removeObserver:forKeyPath:),
                    method_getImplementation(removeObserverForKeyPath),
                    method_getTypeEncoding(removeObserverForKeyPath));
    
    class_replaceMethod(class,
                        @selector(removeObserver:forKeyPath:),
                        (IMP)KVOSubclassRemoveObserverForKeyPath,
                        method_getTypeEncoding(removeObserverForKeyPath));
    
    
    
    // The context variant is only available on 10.7/iOS5+, so only perform that override if the method actually exists.
    Method removeObserverForKeyPathContext = class_getInstanceMethod(class, @selector(removeObserver:forKeyPath:context:));
    if(removeObserverForKeyPathContext)
    {
        class_addMethod(class,
                        @selector(MRInjection_KVO_original_removeObserver:forKeyPath:context:),
                        method_getImplementation(removeObserverForKeyPathContext),
                        method_getTypeEncoding(removeObserverForKeyPathContext));
        class_replaceMethod(class,
                            @selector(removeObserver:forKeyPath:context:),
                            (IMP)KVOSubclassRemoveObserverForKeyPathContext,
                            method_getTypeEncoding(removeObserverForKeyPathContext));
        
    }
}

id  MRExtendInstanceLogicWithKey(id object,NSString* logicKey,  NSArray* logicClasses) {
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
        PatchKVOSubclass(originClass, logicClasses);
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
