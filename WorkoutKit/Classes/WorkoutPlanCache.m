//
//  WorkoutPlanCache.m
//  HiitWorkout
//
//  Created by sungeo on 16/9/5.
//  Copyright © 2016年 maoyu. All rights reserved.
//

#import "WorkoutPlanCache.h"
#import "WorkoutPlan.h"
#import "WorkoutUnitCache.h"
#import "WorkoutAppSetting.h"
#import "BDiCloudManager.h"
#import "BDFoundation.h"
#import "WorkoutUnit.h"
#import "MJExtension.h"
#import <CloudKit/CloudKit.h>
#import "TMCache.h"
#import "EXTScope.h"

// iCloud 中使用的存储类型
static NSString * const RecordTypeWorkoutPlan = @"WorkoutPlan";
// TMCache 使用的存储键值
static NSString * const WorkoutPlansKey = @"WorkoutPlansKey";

// 内置训练方案 Id 最大值
static NSInteger MAX_BUILTIN_PLAN_ID = 10;

@implementation WorkoutPlanCache

+ (instancetype)sharedInstance{
    static WorkoutPlanCache * sSharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sSharedInstance == nil) {
            sSharedInstance = [[WorkoutPlanCache alloc] init];
        }
    });
    
    return sSharedInstance;
}

// 获取 App 内置的 4 种固定训练方案
+ (NSArray *)builtInWorkoutPlans{
    NSDictionary * rootDict = [BDUtils loadJsonFileFromBundel:@"HiitTypes"];
    if (rootDict) {
        NSArray * dicts = rootDict[@"types"];
        return [WorkoutPlan mj_objectArrayWithKeyValuesArray:dicts];
    }else{
        return nil;
    }
}

// 发送消息，通知界面更新
- (void)postNotification{    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUPDATE_WORKOUT_MODE_MESSAGE object:nil];
}

- (void)resetCurrentWorkoutPlan:(NSNumber *)workoutPlanId {
    if(nil == workoutPlanId){
        workoutPlanId = [[WorkoutAppSetting sharedInstance] workoutPlanId];
    }

    NSInteger integerId = [workoutPlanId integerValue];

    if (integerId <= MAX_BUILTIN_PLAN_ID){
        // 在内置训练方案中查询    
        for (WorkoutPlan * plan in [WorkoutPlanCache builtInWorkoutPlans]) {
            if ([plan.objectId isEqualToNumber: workoutPlanId]) {
                _currentWorkoutPlan = plan;
                NSDictionary * rootDict = [BDUtils loadJsonFileFromBundel:_currentWorkoutPlan.configFile];
                if (rootDict) {
                    NSArray * dicts = rootDict[@"workouts"];
                    _workoutUnits = [WorkoutUnit mj_objectArrayWithKeyValuesArray:dicts];
                }
                [self postNotification];
                return;
            }
        }
    }else{
        // 在自定义训练方案中查询
        for (WorkoutPlan * plan in [self cachedObjects]) {
            if ([plan.objectId isEqualToNumber: workoutPlanId]) {
                _currentWorkoutPlan = plan;
                _workoutUnits = [[WorkoutUnitCache sharedInstance] unitsForPlan:_currentWorkoutPlan];
                [self postNotification];
                return;
            }
        }
    }    

    @throw [NSException exceptionWithName:NSGenericException 
        reason:[NSString stringWithFormat:@"没有找到对应的训练方案：%@", workoutPlanId]
        userInfo:nil];
}

/**
 *
 * 加载训练方案是从磁盘加载的最后一类数据，排在从磁盘加载训练单元后面（必须保证）；
 * 最后加载完成后，要做下面事情：
 * 1.根据训练单元数据，计算每个训练方案的训练时间、休息时间；
 * 2.更新当前训练方案和训练单元；
 *
 */

- (void)loadFromDisk{
    [super loadFromDisk];

    // 计算动态属性：运动总时间、休息总时间、动作次数、动作组数
    NSArray * plans = [self cachedObjects];
    for(WorkoutPlan * plan in plans){
        [plan updateDynamicProperties];
    }

    // 更新当前训练方案到内存中
    [self resetCurrentWorkoutPlan:nil];
}

- (WorkoutPlan *)newWorkoutPlan:(WorkoutPlanType)type{
    // 取现有最大 Id + 1 作为下一个训练方案的 objectId
    WorkoutPlan * plan = [[WorkoutPlan alloc] init];
    plan.objectId = [self maxObjectIdWithDefaultValue:MAX_BUILTIN_PLAN_ID];
    plan.type = @(type);
    
    return plan;
}

- (void)objectsDeleted:(NSArray *)objects withError:(NSError *)operationError{
    if (!operationError){

        NSNumber * currentPlanId = [[WorkoutAppSetting sharedInstance] workoutPlanId];
        for(BDiCloudModel * object in objects){
            WorkoutPlan * plan = (WorkoutPlan *)object;
            // 删除训练方案下属训练单元
            [self deleteUnitsForPlan:plan];

            if ([plan.objectId isEqualToNumber:currentPlanId]){
                // 删除的是当前训练方案时，修改当前训练方案为第一个内置方案
                NSArray * builtInPlans = [WorkoutPlanCache builtInWorkoutPlans];
                WorkoutPlan * first = builtInPlans[0];
                [WorkoutAppSetting sharedInstance].workoutPlanId = first.objectId;
            }
        }
        
        NSLog(@"删除 iCloud 记录成功");        
    }else{
        NSLog(@"删除 iCloud 记录失败");
    }   
}

- (void)objectUpdated:(BDiCloudModel *)object withError:(NSError *)error{
    if (! error) {
        NSLog(@"修改 iCloud 记录成功");
    }else{
        NSLog(@"修改 iCloud 记录失败");
    }
}

// 删除训练方案的所有训练单元，用于删除训练方案时
- (void)deleteUnitsForPlan:(WorkoutPlan *)plan{
    WorkoutUnitCache * unitCache = [WorkoutUnitCache sharedInstance];
    NSArray * units = [unitCache unitsForPlan:plan];
    [unitCache deleteObjects:units];
}

// 查询 Id 对应的训练方案对象
- (WorkoutPlan *)workoutPlanWithId:(NSNumber *)objectId{
    NSArray * plans = [self cachedObjects];
    for (WorkoutPlan * plan in plans){
        if ([plan.objectId isEqualToNumber:objectId]){
            return plan;
        }
    }

    return nil;
}

// 重载关键函数

- (NSString *)cacheKey{
    return WorkoutPlansKey;
}

- (BDiCloudModel *)newCacheObjectWithICloudRecord:(CKRecord *)record{
    WorkoutPlan * plan = [[WorkoutPlan alloc] initWithICloudRecord:record];
    return plan;
}

- (NSString *)recordType{
    return RecordTypeWorkoutPlan;
}

@end
