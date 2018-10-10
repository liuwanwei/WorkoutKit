//
//  WorkoutNotificationManager.h
//  7MinutesWorkout
//
//  Created by sungeo on 15/7/10.
//  Copyright (c) 2015年 maoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkoutNotificationManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  部署本地提醒入口
 *
 *  @param dateTime 每天通知时间，只有“时”和“分”有效。
 */
- (void)deployLocalNotification:(NSDate *)dateTime;


/**
 *  iOS8 下，在 AppDelegate 的回调中添加本地通知
 *
 *  @param dateTime 通知时间
 */
- (void)scheduleLocalNotification:(NSDate *)dateTime;

/**
 *  取消所有通知
 */
- (void)cancelAllNotifications;


+ (void)test;

@end
