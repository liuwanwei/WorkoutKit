//
//  UIColor+TrainingTimer.h
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    TrainingColorSchemaOrange,
    TrainingColorSchemaBlue,
    TrainingColorSchemaRed,
    TrainingColorSchemaGreen,
    TrainingColorSchemaRandom = 100
    
}TrainingColorSchema;

@interface UIColor(Workout)

+ (void)loadSchema;
+ (void)setSchema:(TrainingColorSchema)schema;

+ (NSArray *)fixedColors;               // 内置固定色彩
+ (UIColor *)barBackgroundColor;        // 导航栏背景色

+ (NSArray *)mainColors;
+ (UIColor *)mainColor;                 // 背景色

+ (UIColor *)lineFgColor;
+ (UIColor *)lineBgColor;

+ (void)resetRandColor;

/**
 *  日历中训练日背景色
 *
 *  @return UIColor object
 */
+ (UIColor *)workoutDayBackgroundColor;

/**
 *  圆点被选中时的颜色
 *
 *  @return UIColor object
 */
+ (UIColor *)selectedDotColor;

/**
 *  未完成的训练单元的圆点的颜色
 *
 *  @return UIColor object
 */
+ (UIColor *)unfinishedUnitDotColor;

+ (UIColor *)finishedUnitDotColor;

@end
