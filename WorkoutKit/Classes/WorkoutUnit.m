//
//  Workout.m
//  7MinutesWorkout
//
//  Created by maoyu on 15/7/10.
//  Copyright (c) 2015年 maoyu. All rights reserved.
//

#import "WorkoutUnit.h"
#import "WorkoutPlan.h"
#import "WorkoutPlanCache.h"

static NSString * const Title = @"title";
static NSString * const WorkoutTimeLength = @"workoutTimeLength";
static NSString * const RestTimeLength = @"RestTimeLength";
static NSString * const ExerciseNumber = @"ExerciseNumber";
static NSString * const WorkoutPlanId = @"workoutPlanId";
static NSString * const ProfileBundleImage = @"profileBundleImage";


@implementation WorkoutUnit

- (instancetype)initWithICloudRecord:(CKRecord *)record{
    if (self = [super initWithICloudRecord:record])
    {
        _title = [record objectForKey:Title];
        _workoutTimeLength = [record objectForKey:WorkoutTimeLength];
        _restTimeLength = [record objectForKey:RestTimeLength];
        _exerciseNumber = [record objectForKey:ExerciseNumber];
        _workoutPlanId = [record objectForKey:WorkoutPlanId];
        _profileBundleImage = [record objectForKey:ProfileBundleImage];
    }

    return self;
}

- (WorkoutPlan *)workoutPlan{
    if (_workoutPlanId != nil){
        return [[WorkoutPlanCache sharedInstance] workoutPlanWithId:_workoutPlanId];
    }else{
        return nil;
    }
}

- (UIImage *)workoutPreviewImage{
    if (_profileBundleImage.length > 0) {
        UIImage * image = [UIImage imageNamed:_profileBundleImage];
        if (image == nil) {
            NSLog(@"训练单元图片不存在：%@, %@", _title, _profileBundleImage);
        }
        
        return image;
    }else{
        NSLog(@"训练单元图片未设置：%@", _title);
        return nil;
    }
}

- (NSString *)detailsContent{
    if (_detailsBundleFile.length > 0) {
        NSString * details = nil;
        
        NSString * dataFilePath = [[NSBundle mainBundle] pathForResource:_detailsBundleFile ofType:nil];
        if (dataFilePath) {
            details = [NSString stringWithContentsOfFile:dataFilePath encoding:NSUTF8StringEncoding error:NULL];
        }else{
            NSLog(@"训练单元描述文件不存在：%@, %@", _title, _detailsBundleFile);
        }
        
        return details;

    }else{
        NSLog(@"训练单元描述文件未设置：%@", _title);
        return nil;
    }
}

- (BOOL)isEqual:(id)newObject{
    if([_workoutPlanId isEqualToNumber:[newObject workoutPlanId]] && 
        [self.objectId isEqualToNumber:[newObject objectId]]){
        return YES;
    }else{
        return NO;
    }
}

// 将当前实例的属性同步到对应的 CKRecord 实例中
- (void)updateICloudRecord:(CKRecord *)record{
    [record setObject:self.title forKey:Title];
    [record setObject:self.workoutTimeLength forKey:WorkoutTimeLength];
    [record setObject:self.restTimeLength forKey:RestTimeLength];
    [record setObject:self.exerciseNumber forKey:ExerciseNumber];
    [record setObject:self.workoutPlanId forKey:WorkoutPlanId];
    [record setObject:self.profileBundleImage forKey:ProfileBundleImage];
}

@end
