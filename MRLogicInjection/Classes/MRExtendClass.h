//
//  MRExtendClass.h
//  MagicRemind
//
//  Created by baidu on 15/12/7.
//  Copyright © 2015年 dzpqzb. All rights reserved.
//

#import <Foundation/Foundation.h>

Class MRExtendClass(Class baseClass, NSArray* logicClasses, NSString* key);
void MRExtendInstanceLogic(id object, NSArray* logicClasses);