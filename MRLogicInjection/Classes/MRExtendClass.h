//
//  MRExtendClass.h
//  MagicRemind
//
//  Created by baidu on 15/12/7.
//  Copyright © 2015年 dzpqzb. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 通过对一个类注入另外一簇类的方法来实现该类的扩展。
 该方法将会对动态的生成baseClass的子类，并将logicClasses中所有的实例方法注入到生成的子类当中，来扩展原有类的功能
 
 @param baseClass 容器类，用来承载其他类中逻辑的容器
 @param logicClasses 将用于注入的素材类
 @param key 该次注入相关的逻辑的一个标志
 @return 从baseClass集成并包含了所有logicClasses中实例方法的被改造的类
 */
Class MRExtendClass(Class baseClass, NSArray* logicClasses, NSString* key);

/**
 扩展一个类的能力，通过对其添加logicClasses中的能力。
 
 本方法使用isa-swizzing的方式，先生成object的class的子类，并对齐子类注入logicClasses中的业务逻辑，得到一个新的类。并将object的isa指针，重定向到新生成的类实现。
 
 @param object 将要被扩展的实例
 @param logicClasses 将要被注入的业务逻辑簇
 @return 被isa-swzzing之后的实例
 */
id MRExtendInstanceLogic(id object, NSArray* logicClasses);


/**
 扩展一个类的能力，通过对其添加logicClasses中的能力。
 
 本方法使用isa-swizzing的方式，先生成object的class的子类，并对齐子类注入logicClasses中的业务逻辑，得到一个新的类。并将object的isa指针，重定向到新生成的类实现。
 
 @param object 将要被扩展的实例
 @param logicKey  该次注入的业务逻辑key，可用于防止重复注入，如果两次注入使用了同一个logicKey，则第二次将不会再次注入
 @param logicClasses 将要被注入的业务逻辑簇
 @return 被isa-swzzing之后的实例
 */
id MRExtendInstanceLogicWithKey(id object,NSString* logicKey,  NSArray* logicClasses);
