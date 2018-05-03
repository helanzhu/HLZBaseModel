//
//  PersonModel.h
//  HLZBaseModel
//
//  Created by chenqg on 2018/5/3.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import "BaseModel.h"

@interface PersonModel : BaseModel

//姓名
@property (copy, nonatomic) NSString *name;
//兴趣
@property (copy, nonatomic) NSArray *hobby;
//年龄
@property (assign, nonatomic) NSUInteger age;


@end
