//
//  UIColor+TrainingTimer.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "UIColor+Workout.h"
#import "TMCache.h"
#import <BDBaseKit/Macro.h>

#define RGB(r, g, b)             [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

static NSString * const kSchemaKey = @"schemaKey";

static TrainingColorSchema sSchema = TrainingColorSchemaOrange;
static dispatch_once_t sOnceToken = 0;

@implementation UIColor(Workout)

+ (void)loadSchema{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        NSNumber * object = (NSNumber *)[[TMDiskCache sharedCache] objectForKey:kSchemaKey];
        if (object) {
            sSchema = (TrainingColorSchema)[object integerValue];
        }else {
            sSchema = TrainingColorSchemaOrange;
        }
//    });
}

+ (void)setSchema:(TrainingColorSchema)schema{
    sSchema = schema;
    [[TMDiskCache sharedCache] setObject:@(schema) forKey:kSchemaKey];
}

+ (UIColor *)barBackgroundColor{
    return [[self class] mainColor];
}

+ (UIColor *)mainColor{
    switch (sSchema) {
        case TrainingColorSchemaOrange:
            return [[self class] mainColors][0];
        case TrainingColorSchemaBlue:
            return [[self class] mainColors][1];
        case TrainingColorSchemaRed:
            return [[self class] mainColors][2];
        case TrainingColorSchemaGreen:
            return [[self class] mainColors][3];
        case TrainingColorSchemaRandom:
            return [[self class] mainColors][4];

    }
}

+ (NSArray *)fixedColors {
    return @[RGB(241,90,36),RGB(49, 177, 246),RGB(239, 81, 81),RGB(80, 191, 148)];
}

+ (NSArray *)mainColors {
    NSMutableArray * colors=[NSMutableArray arrayWithArray:[[self class] fixedColors]];
    [colors addObject:[[self class] randColor]];
    
    return colors;
    
}

+ (void)resetRandColor {
    sOnceToken = 0;
}

+ (UIColor *)randColor {
   
    static UIColor * color = nil;
    dispatch_once(&sOnceToken, ^{
//        if (nil == color) {
            int index = arc4random()%4;
            color = [[self class] fixedColors][index];
//        }        
    });
    
    return color;
}

+ (UIColor *)lineFgColor{
    return RGB(0xD4, 0xD5, 0xD5);
//    return RGB(246, 246, 246);
}

+ (UIColor *)lineBgColor{
    return RGB(0xAF, 0xAD, 0xAA);
}

+ (UIColor *)workoutDayBackgroundColor{
    return RGB(219,219,234);
}

+ (UIColor *)selectedDotColor{
    return [[self class] mainColor];
//    return RGB(159, 232, 83);
}

+ (UIColor *)unfinishedUnitDotColor{
    return RGB(170, 170, 170);
}

+ (UIColor *)finishedUnitDotColor{
    return RGB(159,232,83);
}

@end
