//
//  BaseModel.m
//  HLZBaseModel
//
//  Created by chenqg on 2016/2/6.
//  Copyright © 2018年 helanzhu. All rights reserved.
//


#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"value : %@  key : %@",value,key);
}


+ (NSString *)descriptWithProperties:(NSString *)key value:(id)value level:(NSInteger) level{
    NSMutableString *head = [NSMutableString string];
    for(NSInteger i=0; i<level; i++){
        [head appendString:@"\t"];
    }
    NSString *strDescription;
    if([value isKindOfClass:[NSString class]]){
        if(key){
            strDescription = [NSString stringWithFormat:@"%@%@ = \"%@\"", head, key, value];
        }else{
            strDescription = [NSString stringWithFormat:@"%@\"%@\"", head, value];
        }
        return strDescription;
    }
    else if([value isKindOfClass:[NSArray class]]){
        NSMutableString *str = [NSMutableString string];
        if(key){
            [str appendFormat:@"%@%@ = (\n",head, key];
        }else{
            [str appendFormat:@"%@(\n",head];
        }
        for(id obj in ((NSArray *)value)){
            NSString *p = [self descriptWithProperties:nil value:obj level:level+1];
            [str appendFormat:@"%@\n",p];
        }
        [str appendFormat:@"%@)",head];
        strDescription = str;
        return strDescription;
    }
    else if([value isKindOfClass:[NSDictionary class]]){
        NSMutableString *str = [NSMutableString string];
        if(key){
            [str appendFormat:@"%@%@ = {\n",head, key];
        }else{
            [str appendFormat:@"%@{\n",head];
        }
        [value enumerateKeysAndObjectsUsingBlock:^(id subkey, id obj, BOOL *stop) {
            NSString *strProperties = [self descriptWithProperties:subkey value:obj level:level +1];
            [str appendFormat:@"%@\n", strProperties];
        }];
        [str appendFormat:@"%@}",head];
        strDescription = str;
        return strDescription;
    }
    else if([value isKindOfClass:[BaseModel class]]){
        NSDictionary *dic = [BaseModel mapPropertiesToDictionary:value];
        NSMutableString *str = [NSMutableString string];
        if(key){
            [str appendFormat:@"%@%@ = {\n",head, key];
        }else{
            [str appendFormat:@"%@{\n",head];
        }
        [dic enumerateKeysAndObjectsUsingBlock:^(id subkey, id obj, BOOL *stop) {
            NSString *strProperties = [self descriptWithProperties:subkey value:obj level:level+1];
            [str appendFormat:@"%@\n", strProperties];
        }];
        [str appendFormat:@"%@}",head];
        strDescription = str;
        return strDescription;
        
    }
    else if([value isKindOfClass:[NSData class]]){
        NSData *data = value;
        if(data.length > 20){
            NSData * subData = [data subdataWithRange:NSMakeRange(0, 20)];
            NSMutableString *str = [NSMutableString string];
            if(key){
                [str appendFormat:@"%@%@ = %@ ... %ld bytes",head, key, subData, (long)data.length];
            }else{
                [str appendFormat:@"%@%@... %ld bytes",head,subData, (long)data.length];
            }
            strDescription = str;
            return strDescription;
        }
    }
    else if([value isKindOfClass:[NSValue class]]){
        
        const char * objctype = [value objCType];
        if(strcmp(objctype, "{?=dd}") == 0){
            struct {double a;double b;} dd;
            [value getValue:&dd];
            if(key){
                strDescription = [NSString stringWithFormat:@"%@%@ = {%f,%f}", head, key, dd.a, dd.b];
            }
            else{
                strDescription = [NSString stringWithFormat:@"%@{%f,%f}", head, dd.a, dd.b];
            }
            return strDescription;
        }
        if(strcmp(objctype, "{?=ff}") == 0){
            struct {float a;float b;} ff;
            [value getValue:&ff];
            if(key){
                strDescription = [NSString stringWithFormat:@"%@%@ = {%f,%f}", head, key, ff.a, ff.b];
            }
            else{
                strDescription = [NSString stringWithFormat:@"%@{%f,%f}", head, ff.a, ff.b];
            }
            return strDescription;
        }
        
    }
    
    if(key){
        strDescription = [NSString stringWithFormat:@"%@%@ = %@", head, key, value];
    }else{
        strDescription = [NSString stringWithFormat:@"%@%@", head, value];
    }
    return strDescription;
    
}


+ (NSDictionary *)mapPropertiesToDictionary:(id)object {
    // 用以存储属性（key）及其值（value）
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    // 获取当前类对象类型
    Class loopObj = [object class];
    while(loopObj){
        uint ivarsCount = 0;
        Ivar *ivars = class_copyIvarList(loopObj, &ivarsCount);
        // 遍历成员变量列表，其中每个变量为Ivar类型的结构体
        const Ivar *ivarsEnd = ivars + ivarsCount;
        for (const Ivar *ivarsBegin = ivars; ivarsBegin < ivarsEnd; ivarsBegin++) {
            Ivar const ivar = *ivarsBegin;
            //　获取变量名
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            /*
             若此变量声明为属性，则变量名带下划线前缀'_'
             比如 @property (nonatomic, copy) NSString *name;则 key = _name;
             为方便查看属性变量，在此特殊处理掉下划线前缀
             */
            if ([key hasPrefix:@"_"]) key = [key substringFromIndex:1];
            //　获取变量值
            id value = [object valueForKey:key];
            
            // 处理属性未赋值属性，将其转换为null，若为nil，插入将导致程序异常
            [dictionary setObject:value ? value : [NSNull null]
                           forKey:key];
        }
        Class superClass = [loopObj superclass];
        if(loopObj == superClass || superClass == [BaseModel class]){
            break;
        }
        loopObj = superClass;
    }
    return dictionary;
}

- (NSString *)debugDescription {
    NSMutableString *str = [NSMutableString string];
    //NSString *className = NSStringFromClass([self class]);
    NSDictionary *dic = [BaseModel mapPropertiesToDictionary:self];
    [str appendString:@"{\n"];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *strProperties = [BaseModel descriptWithProperties:key value:obj level:1];
        [str appendFormat:@"%@\n", strProperties];
    }];
    [str appendString:@"}"];
    return str;
}
- (NSString *)description {
    return [self debugDescription];
}


#pragma mark -protocol NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder{
    NSDictionary *dic = [BaseModel mapPropertiesToDictionary:self];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if(obj != nil && [obj conformsToProtocol:@protocol(NSCoding)]){
            if([obj isKindOfClass:[NSValue class]]){
                //基本类型，结构
                const char * objctype = [obj objCType];
                if(strcmp(objctype, "{?=dd}") == 0){
                    struct {double a;double b;} dd;
                    [obj getValue:&dd];
                    NSString *strDesc = [NSString stringWithFormat:@"_BaseModelValueDD_{%f,%f}", dd.a, dd.b];
                    [aCoder encodeObject:strDesc forKey:key];
                    return;
                }
                if(strcmp(objctype, "{?=ff}") == 0){
                    struct {float a;float b;} ff;
                    [obj getValue:&ff];
                    NSString *strDesc = [NSString stringWithFormat:@"_BaseModelValueFF_{%f,%f}", ff.a, ff.b];
                    [aCoder encodeObject:strDesc forKey:key];
                    return;
                }
            }
            [aCoder encodeObject:obj  forKey:key];
        }
    }];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        NSDictionary *dic = [BaseModel mapPropertiesToDictionary:self];
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id value = [aDecoder decodeObjectForKey:key];
            if([value isKindOfClass:[NSString class]] && [((NSString *)value) hasPrefix:@"_BaseModelValueDD_"]){
                NSString * strDesc = (NSString *)value;
                struct {double a;double b;} dd;
                struct {float a;float b;} ff;
                sscanf(strDesc.UTF8String, "_BaseModelValueDD_{%f,%f}", &ff.a, &ff.b);
                dd.a = ff.a;
                dd.b = ff.b;
                value = [NSValue value:&dd withObjCType:"{?=dd}"];
            }
            else if([value isKindOfClass:[NSString class]] && [((NSString *)value) hasPrefix:@"_BaseModelValueFF_"]){
                NSString * strDesc = (NSString *)value;
                struct {float a;float b;} ff;
                sscanf(strDesc.UTF8String, "_BaseModelValueFF_{%f,%f}", &ff.a, &ff.b);
                value = [NSValue value:&ff withObjCType:"{?=ff}"];
            }
            if(value && ![value isEqual:[NSNull null]]){
                [self setValue:value forKey:key];
            }
        }];
    }
    return self;
}

#pragma mark -protocol NSCopying

- (id)copyWithZone:(NSZone *)zone{
    BaseModel *ret = [[BaseModel allocWithZone:zone] init];
    NSDictionary *dic = [BaseModel mapPropertiesToDictionary:self];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if(obj != nil && [obj conformsToProtocol:@protocol(NSCopying)]){
            id oneCopy = [obj copy];
            [ret setValue:oneCopy forKey:key];
        }
    }];
    
    return ret;
}


#pragma mark -protocol NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone{
    BaseModel *ret = [[BaseModel allocWithZone:zone] init];
    NSDictionary *dic = [BaseModel mapPropertiesToDictionary:self];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if(obj != nil && [obj conformsToProtocol:@protocol(NSMutableCopying)]){
            id oneCopy = [obj mutableCopy];
            [ret setValue:oneCopy forKey:key];
        }
    }];
    
    return ret;
}

#pragma mark -protocol NSSecureCoding
+ (BOOL)supportsSecureCoding{
    return YES;
}

@end

