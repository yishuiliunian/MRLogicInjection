#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MRCheckSuper.h"
#import "MRExtendClass.h"
#import "MRLogicInjection.h"
#import "NSObject+MRInjectionLogicKey.h"

FOUNDATION_EXPORT double MRLogicInjectionVersionNumber;
FOUNDATION_EXPORT const unsigned char MRLogicInjectionVersionString[];

