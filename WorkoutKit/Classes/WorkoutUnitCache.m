//
//  WorkoutUnitCache.m
//  HiitWorkout
//
//  Created by sungeo on 16/9/5.
//  Copyright © 2016年 maoyu. All rights reserved.
//

#import "WorkoutUnitCache.h"
#import "WorkoutPlanCache.h"
#import "WorkoutUnit.h"
#import "WorkoutAppSetting.h"
#import "BDiCloudManager.h"
#import "WorkoutPlan.h"
#import <CloudKit/CloudKit.h>
#import "TMCache.h"
//#import <EXTScope.h>

// iCloud 中使用的训练单元存储类型
static NSString * const RecordTypeWorkoutUnit = @"WorkoutUnit";

// TMCache 用到的存储所有训练单元的 Key
static NSString * const WorkoutUnitsKey = @"WorkoutUnitsKey";

@implementation WorkoutUnitCache

+ (instancetype)sharedInstance{
    static WorkoutUnitCache * sSharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sSharedInstance == nil) {
            sSharedInstance = [[WorkoutUnitCache alloc] init];
        }
    });
    
    return sSharedInstance;
}

- (WorkoutUnit *)newUnitForPlan:(NSNumber *)workoutPlanId{
    WorkoutUnit * unit = [[WorkoutUnit alloc] init];
    unit.workoutPlanId = workoutPlanId;
    unit.objectId = [self maxObjectIdWithDefaultValue:0];
    
    return unit;
}

- (BOOL)addObject:(BDiCloudModel *)newObject{
    BOOL ret = [super addObject:newObject];
    if (ret){
        WorkoutUnit * unit = (WorkoutUnit *)newObject;
        [self updateWorkoutPlan:[unit workoutPlan]];   
    }

    return ret;
}

- (void)updateWorkoutPlan:(WorkoutPlan *)plan{
    [plan updateDynamicProperties];

    if ([plan isEqual:[[WorkoutPlanCache sharedInstance] currentWorkoutPlan]]){
        [[WorkoutPlanCache sharedInstance] resetCurrentWorkoutPlan:plan.objectId];
    }
}

// 查询训练方案下属的所有训练单元
- (NSArray *)unitsForPlan:(WorkoutPlan *)plan{
    NSArray * allUnits = [self cachedObjects];
    NSMutableArray * units = [[NSMutableArray alloc] init];
    for (WorkoutUnit * unit in allUnits) {
        if ([unit.workoutPlanId isEqualToNumber:plan.objectId]) {
            [units addObject:unit];
        }
    }

    // 按照 Id 从大到小排序
    return [units sortedArrayUsingComparator: ^(id obj1, id obj2){
        NSNumber * id1 = ((BDiCloudModel *)obj1).objectId;
        NSNumber * id2 = ((BDiCloudModel *)obj2).objectId;

        return [id1 compare: id2];
    }];
}

// 需要重载的函数

- (void)objectsDeleted:(NSArray *)objects withError:(NSError *)error{
    if (!error){
        // 找出删除的训练单元对应的训练方案，更新他们的动态数据
        NSMutableArray * affectedPlans = [NSMutableArray arrayWithCapacity:8];
        for (WorkoutUnit * unit in objects){
            WorkoutPlan * plan = [unit workoutPlan];
            if (plan != nil){
                if (![affectedPlans containsObject:plan]){
                    [affectedPlans addObject:plan];
                }
            }            
        }

        for (WorkoutPlan * plan in affectedPlans){
            [self updateWorkoutPlan:plan];
        }

        // 提示删除成功
        NSLog(@"训练单元删除成功：%@ 个", @(objects.count));
    }else{
        // 提示删除失败
        [self showAlertWithMessage:[NSString stringWithFormat:@"删除训练单元失败: %@", error]];
    }
}

- (void)objectUpdated:(BDiCloudModel *)object withError:(NSError *)error{
    if (!error){
        WorkoutUnit * unit = (WorkoutUnit *)object;
        [self updateWorkoutPlan:[unit workoutPlan]];
    }else{
        // TODO: 提示修改失败
    }
}

- (NSString *)cacheKey{
    return WorkoutUnitsKey;
}

- (BDiCloudModel *)newCacheObjectWithICloudRecord:(CKRecord *)record{
    WorkoutUnit * object = [[WorkoutUnit alloc] initWithICloudRecord:record];
    return object;
}

- (NSString *)recordType{
    return RecordTypeWorkoutUnit;
}

@end
