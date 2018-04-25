//
//  NSObject+MRInjectionLogicKey.m
//  MRLogicInjection
//
//  Created by Dong Zhao on 2018/4/25.
//

#import "NSObject+MRInjectionLogicKey.h"
#import <objc/runtime.h>

@implementation NSObject(MRInjectionLogicKey)

static void * kMRInjectionClassMap = &kMRInjectionClassMap;
static void * kMRInjectionClassMapSuperClass = &kMRInjectionClassMapSuperClass;
static void * kMRInjectionClassMapSourceClass = &kMRInjectionClassMapSourceClass;

- (Class) mr_injection_superclass
{
    return objc_getAssociatedObject(self, kMRInjectionClassMapSuperClass);
}

- (void) setMr_injection_superclass:(Class)mr_injection_superclass
{
    objc_setAssociatedObject(self, kMRInjectionClassMapSuperClass, mr_injection_superclass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Class) mr_injection_logic_class
{
    return objc_getAssociatedObject(self, kMRInjectionClassMapSourceClass);
}

- (void) setMr_injection_logic_class:(Class)mr_injection_logic_class
{
    objc_setAssociatedObject(self, kMRInjectionClassMapSourceClass, mr_injection_logic_class, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*) mr_injection_logic_key
{
    return objc_getAssociatedObject(self, kMRInjectionClassMap);
}

- (void) setMr_injection_logic_key:(NSString *)mr_injection_logic_key
{
    objc_setAssociatedObject(self, kMRInjectionClassMap, mr_injection_logic_key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
