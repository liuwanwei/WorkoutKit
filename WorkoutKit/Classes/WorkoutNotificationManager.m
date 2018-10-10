//
//  WorkoutNotificationManager.m
//  7MinutesWorkout
//
//  Created by sungeo on 15/7/10.
//  Copyright (c) 2015年 maoyu. All rights reserved.
//

#import "WorkoutNotificationManager.h"
#import <UIKit/UIKit.h>
#import "Macro.h"
#import "WorkoutAppSetting.h"
#import "NSDate+DateTools.h"


static NSString * const NotificationCategoryIdentifier = @"ACTIONABLE";
static NSString * const NotificationActionIdentifierDoItNow = @"DoItNow";
static NSString * const NotificationActionTitleDoItNow = @"马上开始";
static NSString * const NotificationActionIdentifierDoItLater = @"DoItLater";
static NSString * const NotificationActionTitleDoItLater = @"牛仔很忙";

@implementation WorkoutNotificationManager

+ (instancetype)sharedInstance{
    static WorkoutNotificationManager * sWorkOutNotifcationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sWorkOutNotifcationManager = [[WorkoutNotificationManager alloc] init];
    });
    
    return sWorkOutNotifcationManager;
}

/**
 *  注册 iOS8 特有的本地通知类型——支持在通知中心添加交互按钮
 */
- (void)registerNotification{
    UIMutableUserNotificationAction * actionDoItNow = [[UIMutableUserNotificationAction alloc] init];
    [actionDoItNow setActivationMode:UIUserNotificationActivationModeBackground];
    [actionDoItNow setTitle:NotificationActionTitleDoItNow];
    [actionDoItNow setIdentifier:NotificationActionIdentifierDoItNow];
    [actionDoItNow setDestructive:NO];
    [actionDoItNow setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction * actionDoItLater = [[UIMutableUserNotificationAction alloc] init];
    [actionDoItLater setActivationMode:UIUserNotificationActivationModeBackground];
    [actionDoItLater setTitle:NotificationActionTitleDoItLater];
    [actionDoItLater setIdentifier:NotificationActionIdentifierDoItLater];
    [actionDoItLater setDestructive:NO];
    [actionDoItLater setAuthenticationRequired:NO];
    
    UIMutableUserNotificationCategory * actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:NotificationCategoryIdentifier];
    [actionCategory setActions:@[actionDoItNow, actionDoItLater] forContext:UIUserNotificationActionContextDefault];
    
    UIUserNotificationType type = (UIUserNotificationTypeAlert|
                                   UIUserNotificationTypeBadge|
                                   UIUserNotificationTypeSound);
    
    NSSet * categories = [NSSet setWithObject:actionCategory];
    
    UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:type categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    NSLog(@"Register iOS8 notification center");
}

- (void)deployLocalNotification:(NSDate *)dateTime{
    // 取消所有已创建的通知日程
    [self cancelAllNotifications];
    
    UIApplication * application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [self registerNotification];
        
    }else{
        NSLog(@"系统版本 %@ 低于 8.0，无法添加通知菜单，直接部署本地通知", @(iOS));
        [self scheduleLocalNotification:dateTime];
    }
}

- (void)scheduleLocalNotification:(NSDate *)dateTime{
    if (dateTime == nil) {
        NSLog(@"本地提醒部署失败：提醒锻炼时间未设置");
        return;
    }
    
    // 添加新的通知日程
    NSString * message = [[WorkoutAppSetting sharedInstance] notificationText];
    
    UILocalNotification * localNotification = [[UILocalNotification alloc] init];
    localNotification.repeatInterval = NSCalendarUnitDay;
    localNotification.alertBody = message.length > 0 ? message : @"今天 HIIT 有氧训练了吗？";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.alertAction = NotificationActionTitleDoItNow;
    
    // 设置通知时间
    localNotification.fireDate = [self realFireDateForTime:dateTime];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

/**
 *  计算第一次通知的开始时间
 *  本地通知按天循环，用户需要设置几点几分通知。假如设置的时间在当前时间之前，第一次通知时间就应该在明天，否则在今天通知。
 *
 *  @param fireTime 通知开始时间，只有小时和分钟有效
 *
 *  @return 第一次通知的开始时间，包含年月日时分秒
 */
- (NSDate *)realFireDateForTime:(NSDate *)fireTime{
    // 今天通知时间已过，设置到明天；没过时，设置到今天。
    NSDate * now = [NSDate date];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString * exactString = [NSString stringWithFormat:@"%04zd-%02zd-%02zd %02zd:%02zd:00",
                              now.year, now.month, now.day,
                              fireTime.hour, fireTime.minute];
    NSDate * exactDate = [dateFormatter dateFromString:exactString];
    
    if ((now.hour > fireTime.hour ) ||
        (now.hour == fireTime.hour && now.minute > fireTime.minute)) {
        // 设置时间已过，明天触发
        NSLog(@"首次提醒在明天");
        exactDate = [exactDate dateByAddingDays:1];
    }
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: exactDate];
    NSDate *localeDate = [exactDate  dateByAddingTimeInterval: interval];
    NSLog(@"首次本地提醒时间：%@", localeDate);
    
    return  exactDate;
}

- (void)cancelAllNotifications{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

+ (void)test{
    NSDate * fireDate = [NSDate date];
    fireDate = [fireDate dateByAddingMinutes:1];    // 1 分钟后触发
    
    [[WorkoutNotificationManager sharedInstance] deployLocalNotification:fireDate];
}

@end
