//
//  MRExtendClass.h
//  MagicRemind
//
//  Created by baidu on 15/12/7.
//  Copyright © 2015年 dzpqzb. All rights reserved.
//

#import <Foundation/Foundation.h>

Class MRExtendClass(Class baseClass, NSArray* logicClasses, NSString* key);
id MRExtendInstanceLogic(id object, NSArray* logicClasses);
id  MRExtendInstanceLogicWithKey(id object,NSString* logicKey,  NSArray* logicClasses);
id MRRemoveExtendLogic(id object);
