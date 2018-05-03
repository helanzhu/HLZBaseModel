//
//  BaseModel.h
//  HLZBaseModel
//
//  Created by chenqg on 2016/2/6.
//  Copyright © 2018年 helanzhu. All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 *  数据模型基础类
 *  可以在调试时格式化输出成员变量 例如：NSLog(@"%@", (BaseModel*)someModel)
 *  如果该对象存放在数组或者字典中，可以使用 debugDescription 方式 ，例如：NSLog(@"%@", (NSArray *)[aryOfBaseModel debugDescription])
 */

@interface BaseModel : NSObject<NSSecureCoding, NSCopying, NSMutableCopying>

@end
