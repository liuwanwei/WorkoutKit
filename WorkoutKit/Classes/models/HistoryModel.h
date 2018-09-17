//
//  HistoryModel.h
//  HiitWorkout
//
//  Created by sungeo on 2018/6/15.
//  Copyright © 2018年 maoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HistoryModel : NSObject

@property (nonatomic, strong) NSArray * results;

- (NSUInteger)totalResultCount;
- (NSUInteger)resultCountForThisWeek;

@end

NS_ASSUME_NONNULL_END
