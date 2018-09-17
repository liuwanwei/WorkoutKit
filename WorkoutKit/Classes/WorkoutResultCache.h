//
//  WorkoutResultCache.h
//  HiitWorkout
//
//  Created by sungeo on 16/9/6.
//  Copyright © 2016年 maoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDiCloudManager.h"
#import "BaseCache.h"

@class WorkoutResult;

@interface WorkoutResultCache : BaseCache

+ (instancetype)sharedInstance;

@end
