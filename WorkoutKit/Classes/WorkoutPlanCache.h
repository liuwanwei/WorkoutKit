//
//  WorkoutPlanCache.h
//  HiitWorkout
//
//  Created by sungeo on 16/9/5.
//  Copyright © 2016年 maoyu. All rights reserved.
//

/*
 * 获取内置训练方案（徒手初级、徒手中级，跳绳初级、跳绳中级）：
 *      [[WorkoutPlanCache sharedInstance] builtInWorkoutPlans];
 * 获取自定义训练方案：
 *      [[WorkoutPlanCache sharedInstance] cachedObjects];
 * 添加新的训练方案：
 *      WorkoutPlan * plan = [[WorkoutPlanCache sharedInstance] newWorkoutPlan:PlanTypeHIIT];
 *      ...
 *      [[WorkoutPlanCache sharedInstance] addObject:plan];
 *
 */

#import <Foundation/Foundation.h>
#import "BaseCache.h"
#import "WorkoutPlan.h"

// 当前训练方案改变时，会发送这个通知消息，可以通过 NotificationCenter 接收
#define kUPDATE_WORKOUT_MODE_MESSAGE    @"kUpdateWorkoutModeMessage"

@interface WorkoutPlanCache : BaseCache

// 当前训练方案的训练单元数组(WorkoutUnit)
@property (nonatomic, strong, readonly) NSArray * workoutUnits;
// 当前训练方案对象（WorkoutPlan)
@property (nonatomic, strong, readonly) WorkoutPlan * currentWorkoutPlan;


+ (instancetype)sharedInstance;

// 查询内置的训练方案
+ (NSArray *)builtInWorkoutPlans;

- (void)resetCurrentWorkoutPlan:(NSNumber *)workoutPlanId;

// 查询 objectId 对应的训练方案对象
- (WorkoutPlan *)workoutPlanWithId:(NSNumber *)objectId;

/**
 * 新建训练方案。
 * 注意：新建训练方案必须使用这个接口，接口内部会为训练方案创建唯一 Id；
 * 创建完成后，请调用 addObject 保存新的训练方案。
 */
- (WorkoutPlan *)newWorkoutPlan:(WorkoutPlanType)type;

@end
