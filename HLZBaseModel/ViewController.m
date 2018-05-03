//
//  ViewController.m
//  HLZBaseModel
//
//  Created by chenqg on 2018/5/3.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import "ViewController.h"
#import "PersonModel.h"

@interface ViewController ()

@property (nonatomic, strong) NSDictionary *personDic;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    PersonModel *model = [[PersonModel alloc] init];
    [model setValuesForKeysWithDictionary:self.personDic];
    NSLog(@"model infor ->\n %@",model);
    
    // -------------- 继承自自定义基类BaseModel  打印如下model信息
    //    {
    //        name = "helanzhu"
    //        hobby = (
    //                 "篮球"
    //                 "travel"
    //                 )
    //        age = 28
    //    }
    
    // -------------- 继承自自定义基类NSObject  打印如下model信息
    
    //    <PersonModel: 0x60000002e5e0>


    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSDictionary *)personDic
{
    if (!_personDic) {
        _personDic = @{@"hobby":@[@"篮球",@"travel"],@"name":@"helanzhu",@"age":@28};
    }
    return _personDic;
}

@end
