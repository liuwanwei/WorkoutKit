//
//  HistoryCellTableViewCell.m
//  HiitWorkout
//
//  Created by sungeo on 2018/6/14.
//  Copyright © 2018年 maoyu. All rights reserved.
//

#import "HistoryCell.h"
#import "WorkoutResult.h"
#import "BDFoundation.h"

@implementation HistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        NSArray * nibs = [[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:self options:nil];
        self = [nibs objectAtIndex:0];
        
        [self.circular makeCircle];
        [self.bgView makeCornorRadius:5.0f];
    }
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setWorkoutResult:(WorkoutResult *)workoutResult{
    self.planName.text = workoutResult.workoutTitle != nil ? workoutResult.workoutTitle : @"默认训练";
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    formatter.dateFormat = @"yy-MM-dd HH:mm";
    formatter.timeZone = [NSTimeZone systemTimeZone];
    NSString * dateString = [formatter stringFromDate:workoutResult.workoutTime];
    self.workoutDate.text = dateString;
    
    self.workoutDesc.text = [workoutResult simpleDesc];
    
    _workoutResult = workoutResult;
}

@end
