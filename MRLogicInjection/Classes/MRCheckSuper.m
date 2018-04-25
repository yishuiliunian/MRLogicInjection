//
//  MRCheckSuper.m
//  AOPKit
//
//  Created by Dong Zhao on 2017/12/8.
//

#import "MRCheckSuper.h"
#import <objc/runtime.h>
#import "MRExtendClass.h"
#import "NSObject+MRInjectionLogicKey.h"

Class MRGetCurrentClassInvocationSEL(NSString* functionString)
{
    if (functionString.length == 0) {
        return nil;
    }
    NSRange rangeStart = [functionString rangeOfString:@"["];
    NSRange rangeEnd = [functionString rangeOfString:@" "];
    if (rangeStart.location == NSNotFound || rangeEnd.location == NSNotFound) {
        return nil;
    }
    NSInteger start = rangeStart.location + rangeStart.length;
    if (rangeEnd.location - start <= 0) {
        return nil;
    }
    NSRange classRange = NSMakeRange(start, rangeEnd.location - start);
    NSString *classString = [functionString substringWithRange:classRange];
    return NSClassFromString(classString);
}


Class MRGetInjectionSuperClass(Class currentClass, Class logicClass) {
    Class superClass = currentClass;
    Class checkLogicClass = currentClass;
    while (checkLogicClass) {
        checkLogicClass = [(id)superClass mr_injection_logic_class];
        if (checkLogicClass == logicClass) {
            superClass = class_getSuperclass(superClass);
            break;
        }
        superClass = class_getSuperclass(superClass);
    }
    
    return superClass;
}

BOOL MRCheckSuperResponseToSelector(Class currentClass , Class logicClass, SEL selector) {
    Class superClass = MRGetInjectionSuperClass(currentClass, logicClass);
    return class_respondsToSelector(superClass, selector);
}



