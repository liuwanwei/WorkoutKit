//
//  HiitType.m
//  HiitWorkout
//
//  Created by maoyu on 15/7/29.
//  Copyright (c) 2015年 maoyu. All rights reserved.
//

#import "WorkoutPlan.h"
#import "WorkoutUnit.h"
#import "WorkoutUnitCache.h"

// iCloud 上数据表名字
static NSString * const RecordTypeWorkoutPlan = @"WorkoutPlan";

// iCloud 上数据表字段名字
//static NSString * const ObjectId = @"objectId";
static NSString * const Title = @"title";
static NSString * const Type = @"type";
static NSString * const Cover = @"cover";
static NSString * const HeaderImage = @"headerImage";

@implementation WorkoutPlan

- (instancetype)initWithICloudRecord:(CKRecord *)record{
    if (self = [super initWithICloudRecord:record]) {
        // 从 CKRecord 生成数据
        _title = [record objectForKey:Title];
        _type = [record objectForKey:Type];
        _cover = [record objectForKey:Cover];
        _headerImage = [record objectForKey:HeaderImage];
    }
    
    return self;
}

- (BOOL)isEqual:(id)newObject{
    return [self.objectId isEqualToNumber:[newObject objectId]];
}

// 训练方案是不是内置的 4 种方案
- (BOOL)isBuiltInPlan{
    NSInteger type = [self.type integerValue];
    if (type == PlanTypeBuiltIn) {
        return YES;
    }
    
    return NO;
}

// 将当前实例的属性同步到对应的 CKRecord 实例中
- (void)updateICloudRecord:(CKRecord *)record{
    [record setObject:self.type forKey:Type];
    [record setObject:self.title forKey:Title];
    [record setObject:self.cover forKey:Cover];
    [record setObject:self.headerImage forKey:HeaderImage];
}

// 更新训练方案中的训练时长、休息时长等动态信息
- (void)updateDynamicProperties{
    _workoutTimeLength = 0;
    _restTimeLength = 0;
    _groupNumber = 0;
    _exerciseNumber = 0;

    NSInteger planType = [_type integerValue];    
    NSArray * units = [[WorkoutUnitCache sharedInstance] unitsForPlan:self];
    _groupNumber = units.count;
    for (WorkoutUnit * unit in units) {
        switch(planType){
            case PlanTypeHIIT:
            case PlanTypeJumpRope:
                _workoutTimeLength += [unit.workoutTimeLength integerValue];
                _restTimeLength += [unit.restTimeLength integerValue];
                break;
            case PlanTypeEquipment:
                _exerciseNumber += [unit.exerciseNumber integerValue];
                _restTimeLength += [unit.restTimeLength integerValue];
                break;
            default:
                break;
        }        
    }
}

- (NSString *)typeDescription{
    WorkoutPlanType type = (WorkoutPlanType)[_type integerValue];
    switch(type){
        case PlanTypeHIIT:
            return @"HIIT";
        case PlanTypeEquipment:
            return @"分组训练";
        case PlanTypeJumpRope:
            return @"跳绳训练";
        case PlanTypeBuiltIn:
            return @"内置训练";
    }
}

- (NSString *)longDescription{
    NSString * desc = [NSString stringWithFormat:@"训练类型: %@", [self typeDescription]];
    desc = [desc stringByAppendingFormat:@"\n训练时间: %ld 秒", (long)_workoutTimeLength];
    desc = [desc stringByAppendingFormat:@"\n休息时间: %ld 秒", _restTimeLength];
    desc = [desc stringByAppendingFormat:@"\n训练组数: %ld 组", _groupNumber];
    desc = [desc stringByAppendingFormat:@"\n训练次数: %ld 次", _exerciseNumber];
    return desc;
}

@end
