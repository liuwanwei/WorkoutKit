//
//  HistoryModel.m
//  HiitWorkout
//
//  Created by sungeo on 2018/6/15.
//  Copyright © 2018年 maoyu. All rights reserved.
//

#import "HistoryModel.h"
#import "../WorkoutResult.h"
#import "WorkoutResultCache.h"
#import "NSDate+DateTools.h"

@implementation HistoryModel{
}

- (instancetype)init{
    if (self = [super init]) {
        _results = [self makeSortedResults];
    }
    
    return self;
}

- (NSArray *)makeSortedResults{
    // 得到倒序的训练记录
    NSArray * originalResults = [[WorkoutResultCache sharedInstance] cachedObjects];
    return [originalResults sortedArrayUsingComparator:^NSComparisonResult(id object1, id object2){
        WorkoutResult * result1 = (WorkoutResult *)object1;
        WorkoutResult * result2 = (WorkoutResult *)object2;
        NSComparisonResult ret = [result1.workoutTime compare:result2.workoutTime];
        if (ret == NSOrderedAscending) {
            return NSOrderedDescending;
        }else if (ret == NSOrderedDescending){
            return NSOrderedAscending;
        }else{
            return ret;
        }
    }];
}

- (NSUInteger)totalResultCount{
    return [_results count];
}

- (NSUInteger)resultCountForThisWeek{
    NSInteger count = 0;
    NSDate * today = [[NSDate alloc] init];
    NSInteger weekOfYear = [today weekOfYear];
    NSInteger year = [today year];
    for (WorkoutResult * result in _results) {
        if ([result.workoutTime weekOfYear] == weekOfYear &&
            [result.workoutTime year] == year) {
            count ++;
        }
    }
    
    return count;
}

@end
