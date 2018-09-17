//
//  HistoryViewController.h
//  HiitWorkout
//
//  Created by sungeo on 2018/6/13.
//  Copyright © 2018年 maoyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UIView * topView;
@property (nonatomic, weak) IBOutlet UILabel * totalLabel;
@property (nonatomic, weak) IBOutlet UILabel * weekTotalLabel;

@end

NS_ASSUME_NONNULL_END
