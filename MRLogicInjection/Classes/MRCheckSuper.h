//
//  MRCheckSuper.h
//  AOPKit
//
//  Created by Dong Zhao on 2017/12/8.
//

#import <Foundation/Foundation.h>



/**
 准备在注入类的链条中在父类中调用当前方法
 
 Example:
 @code
 - (void) sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
 {
 if (__MRSuperImplatationCurrentCMD__) {
 MRPrepareSendSuper(void, id, id, id);
 MRSendSuper(action , target, event)
 }
 .....
 }
 @endcode
 
 @param returnType 当前方法的返回类型
 @param ... 当前方法的入参类型列表，请按照顺序传入
 */

#define MRPrepareSendSuper(returnType, ...) \
struct objc_super superInfo = { \
self, \
MRGetInjectionSuperClass([self class],__IMP_CLASS__) \
}; \
returnType (*method)(struct objc_super*, SEL, ##__VA_ARGS__ ) = (void*)&objc_msgSendSuper


/**
 在注入类的链条中在父类中调用当前方法
 
 Example:
 @code
 - (void) sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
 {
 if (__MRSuperImplatationCurrentCMD__) {
 MRPrepareSendSuper(void, id, id, id);
 MRSendSuperSelector(selector, action , target, event)
 }
 .....
 }
 
 @warning 请不要使用_cmd宏定义，因为该参数在编译器确定，如果运行时别人Hook了函数，则会导致该变量产生问题
 
 @param selector 需要执行的方法
 @param ... 当前方法的入参列表，请按照顺序传入
 @return 函数的返回值
 */
#define MRSendSuperSelector(selector, ...) method(&superInfo,selector,##__VA_ARGS__)

/**
 获取在编码的时候实现该方法的原始的类的信息，就是用来用来实现注入逻辑的类
 */
#define __IMP_CLASS__  MRGetCurrentClassInvocationSEL([NSString stringWithFormat:@"%s",__FUNCTION__])


/**
 获取在编码的时候实现该方法的原始的类的信息，就是用来用来实现注入逻辑的类
 
 @param functionString 当前方法的函数描述新信息
 @return 获取在编码的时候实现该方法的原始的类的信息，就是用来用来实现注入逻辑的类
 */
FOUNDATION_EXTERN Class MRGetCurrentClassInvocationSEL(NSString*  functionString);

/**
 检查一个类的父类是否现实了指定的方法
 
 @param currentClass 被检查的类
 @param logicClass 注入的逻辑类
 @param selector 被检查的方法
 @return 如果实现了返回YES，没有实现则返回NO
 */
FOUNDATION_EXTERN BOOL MRCheckSuperResponseToSelector(Class currentClass , Class logicClass, SEL selector);



/**
 获取当前注入了当前逻辑类的父类
 
 @param currentClass 当前类
 @param logicClass 被注入的逻辑类
 @return 注入了当前逻辑类的父类
 */
Class MRGetInjectionSuperClass(Class currentClass, Class logicClass);

/**
 检测当前函数的父类是否实现了当前的函数，如果实现了则返回YES，如果没有实现则返回NO
 */
#define __MRSuperImplatationCurrentCMD__(selector) MRCheckSuperResponseToSelector([self class], __IMP_CLASS__, selector)
