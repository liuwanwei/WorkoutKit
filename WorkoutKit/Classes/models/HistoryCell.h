//
//  HistoryCellTableViewCell.h
//  HiitWorkout
//
//  Created by sungeo on 2018/6/14.
//  Copyright © 2018年 maoyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WorkoutResult;

@interface HistoryCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView * bgView;
@property (nonatomic, weak) IBOutlet UIView * circular;
@property (nonatomic, weak) IBOutlet UILabel * planName;
@property (nonatomic, weak) IBOutlet UILabel * workoutDate;
@property (nonatomic, weak) IBOutlet UILabel * workoutDesc;

@property (nonatomic, strong) WorkoutResult * workoutResult;


@end

NS_ASSUME_NONNULL_END
