//
//  NSObject+MRInjectionLogicKey.h
//  MRLogicInjection
//
//  Created by Dong Zhao on 2018/4/25.
//

#import <Foundation/Foundation.h>

@interface NSObject (MRInjectionLogicKey)

/**
 注入逻辑的关键字
 */
@property (nonatomic, strong) NSString* mr_injection_logic_key;

/**
 当前类在注入的时候的基类
 */
@property (nonatomic, strong) Class mr_injection_superclass;

/**
 当前类注入的逻辑的来源类
 */
@property (nonatomic, strong) Class mr_injection_logic_class;
@end
