//
//  HiitType.h
//  HiitWorkout
//
//  属性跟 HiitTypes.json 文件中的数组元素相对应
//  Created by maoyu on 15/7/29.
//  Copyright (c) 2015年 maoyu. All rights reserved.
//

#import "BDiCloudModel.h"
#import <CloudKit/CloudKit.h>

typedef enum{
    PlanTypeBuiltIn     = 0,
    PlanTypeHIIT        = 1,
    PlanTypeEquipment   = 2,
    PlanTypeJumpRope    = 3,
}WorkoutPlanType;

@interface WorkoutPlan : BDiCloudModel

/* 自定义方案属性 */

// 训练方案类型：WorkoutPlanType
@property (nonatomic, strong) NSNumber * type;
// 训练方案的名字，如：徒手训练·初级
@property (nonatomic, copy) NSString * title;
// 显示在显示方案列表中的封面图
@property (nonatomic, copy) NSString * cover;
// 训练方案详情页顶部的背景图，如：hiit_intro_bg.jpg
@property (nonatomic, copy) NSString * headerImage;

/* 内置方案属性 */

// 训练方案名字简介，显示在运动主页，如：徒手·初级
@property (nonatomic, copy) NSString * briefDescription;
// 是否需要器材，显示在训练方案列表中，如：无限器材，约7分钟
@property (nonatomic, copy) NSString * equipment;

// 训练单元定义文件名字，如：Workouts-Girl-Primary
@property (nonatomic, copy) NSString * configFile;

// 训练方案的整体描述文件名字，如：desc-hiit-girl-primary.txt
@property (nonatomic, copy) NSString * detailsBundleFile;

/* 动态属性 */
// 锻炼总时长（秒，不包含休息时间，HIIT、跳绳有效）
@property (nonatomic) NSInteger workoutTimeLength;
// 休息总时长（秒）
@property (nonatomic) NSInteger restTimeLength;
// 训练总组数（组，分组训练有效）
@property (nonatomic) NSInteger groupNumber;
// 动作总次数（次，分组训练有效）
@property (nonatomic) NSInteger exerciseNumber;

// 当前训练方案实例是不是系统内置的训练方案
- (BOOL)isBuiltInPlan;

- (void)updateICloudRecord:(CKRecord *)record;

// 重新计算动态属性：workoutTime, resetTime
- (void)updateDynamicProperties;

// 详细的描述信息，用在测试菜单中
- (NSString *)longDescription;

@end
