//
//  AppSetting.m
//  7分钟和 HIIT 用到的配置信息
//
//  自 “HIIT有氧训练” 1.3 版起，用户的配置信息不再保存到 iCloud，为的是降低软件复杂度
//  iCloud 只保存最重要的数据
//
//  Created by sungeo on 15/7/11.
//  Copyright (c) 2015年 maoyu. All rights reserved.
//

#import "WorkoutAppSetting.h"
#import "WorkoutNotificationManager.h"
#import "WorkoutPlanCache.h"
#import "TMCache.h"
#import "AutoCoding.h"

static NSString * const AppSettingKey = @"AppSettingKey";

@implementation WorkoutAppSetting

+ (instancetype)sharedInstance{
    static WorkoutAppSetting * sSharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sSharedInstance == nil) {
            TMDiskCache * cache = [TMDiskCache sharedCache];
            WorkoutAppSetting * object = (WorkoutAppSetting *)[cache objectForKey:AppSettingKey];
            if (object) {
                sSharedInstance = object;
                if (sSharedInstance.workoutPlanId == nil) {
                    // 1.3 将 hiitType 改为 workoutPlanId，缓存中如果存的是旧属性名字，赋值给新的
                    sSharedInstance.workoutPlanId = sSharedInstance.hiitType;
                }
                
                if (sSharedInstance.useICloud == nil) {
                    // 1.3 新增数据是否保存到 iCloud 标志（通过界面让用户选择的结果）
                    sSharedInstance.useICloud = @(NO);
                }
                
            }else{
                sSharedInstance = [[WorkoutAppSetting alloc] init];
            }

            [sSharedInstance addValueChangeObserver];
        }
    });
    
    return sSharedInstance;
}

- (instancetype)init{
    if (self = [super init]){
        _notificationOn = @(NO);
        _notificationTime = [NSDate date];
        _muteSwitchOn = @(NO);
        _voiceType = @(PromptVoiceTypeGirl);
        _musicName = @"轻快.mp3";
        _workoutPlanId = @(0);// 默认选中第一个内置训练方案
        _mainColorType = @(MainColorTypeOrange);
        _useICloud = @(NO);
    }
    
    return self;
}

// 监视所有属性的修改行为
- (void)addValueChangeObserver{
    NSDictionary * properties = [self codableProperties];
    for(NSString * key in properties){
        [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
}

// 一有数据被修改，就保存到磁盘
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self syncToDisk];

    // 修改当前训练方案时，自动更新动态数据
    if ([keyPath isEqualToString:@"workoutPlanId"]){
        [[WorkoutPlanCache sharedInstance] resetCurrentWorkoutPlan: _workoutPlanId];
    }
}

- (void)syncToDisk{
    [[TMDiskCache sharedCache] setObject:self forKey:AppSettingKey];
}

- (void)startNotification{
    [[WorkoutNotificationManager sharedInstance] deployLocalNotification:_notificationTime];
}

- (void)stopNotification{
    [[WorkoutNotificationManager sharedInstance] cancelAllNotifications];
}

// 对 useICloud 属性添加一层易于访问的封装
- (BOOL)useICloudSchema{
    return [self.useICloud boolValue];
}

@end
