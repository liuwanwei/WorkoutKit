//
//  CacheManager.m
//  HiitWorkout
//
//  Created by sungeo on 16/9/22.
//  Copyright © 2016年 maoyu. All rights reserved.
//

#import "CacheManager.h"
#import "WorkoutAppSetting.h"
#import "WorkoutPlanCache.h"
#import "WorkoutUnitCache.h"
#import "WorkoutResultCache.h"
#import "UIAlertController+Window.h"
#import "EXTScope.h"

@implementation CacheManager

+ (instancetype)sharedInstance{
    static CacheManager * sSharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sSharedInstance == nil) {
            sSharedInstance = [[CacheManager alloc] init];
        }
    });
    
    return sSharedInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        _planCacheEnabled = @(YES);
        _unitCacheEnabled = @(YES);
        _resultCacheEnabled = @(YES);
    }
    
    return self;
}


- (void)loadAll{
    if ([_resultCacheEnabled boolValue]) {
        [[WorkoutResultCache sharedInstance] load];
    }
    
    if ([_unitCacheEnabled boolValue]) {
        [[WorkoutUnitCache sharedInstance] load];
    }
    
    if ([_planCacheEnabled boolValue]) {
        [[WorkoutPlanCache sharedInstance] load];
    }
}

- (void)cleanAll{
    if ([_resultCacheEnabled boolValue]) {
        [[WorkoutResultCache sharedInstance] clean];
    }

    if ([_unitCacheEnabled boolValue]) {
        [[WorkoutUnitCache sharedInstance] clean];
    }

    if ([_planCacheEnabled boolValue]) {
        [[WorkoutPlanCache sharedInstance] clean];
    }
}



/**
 加载数据，只是对 loadAll 的调用进行了一层封装，调用前判断 iCloud 是否可用，
 避免并发调用三种 CacheManager.load 时，造成 accountStatusWithCompletionHandler 失败的问题。
 */
//- (void)loadData{
//    if ([[WorkoutAppSetting sharedInstance] useICloudSchema]){
//        CKContainer * container = [[BDiCloudManager sharedInstance] container];
//        [container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * error){
//            if (accountStatus == CKAccountStatusAvailable) {
//                [self loadAll];
//            }else{
//                // TODO: 记录下面描述的情况
//                // 并行查询时（plan，unit，result），很大几率会有 1-2 次失败在 accountStatusWithCompletionHandler 里
//                // accountStatus 会等于 CKAccountStatusNoAccount
//                NSLog(@"查询数据出现 iCloud 账户不可用: %@", @(accountStatus));
//            }
//        }];
//    }else{
//        [self loadAll];
//    }
//}

// 判断 App 是否安装后首次运行
- (BOOL)firstLaunchFlag{
	static NSString * LaunchKey = @"firstLaunch";
	BOOL firstLaunch = NO;
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:LaunchKey];
    if (! value) {
        firstLaunch = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:LaunchKey];
    }	

    return firstLaunch;
}

// App 首次运行时，提示用户选择数据存储方案
- (void)chooseStorageScheme{
	
	BOOL firstLaunch = [self firstLaunchFlag];
    
    // 首次打开 App，并且 iCloud 可用时，提示用户是否使用 iCloud 存储数据
    if (firstLaunch && [[BDiCloudManager sharedInstance] iCloudAvailable]) {
        [self showChooseStorageSchemeView];
    }else{
        [self loadAll];
    }
}

// 显示对话框，让用户选择数据存储方案
- (void)showChooseStorageSchemeView{
    @weakify(self);
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"选择数据存储方案"
                                                                    message:@"建议您将数据保存在 iCloud 中，这样可以在每一台设备上访问到您的数据。"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * confirmAction = [UIAlertAction actionWithTitle:@"保存在 iCloud 上"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action){
                                                               @strongify(self);
                                                               [WorkoutAppSetting sharedInstance].useICloud = @(YES);
                                                               [self loadAll];
                                                           }];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"只保存在本机"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action){
                                                              @strongify(self);
                                                              [WorkoutAppSetting sharedInstance].useICloud = @(NO);
                                                              [self loadAll];
                                                          }];
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    
    [alert show];
}

@end
