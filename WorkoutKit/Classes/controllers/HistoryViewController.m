//
//  HistoryViewController.m
//  HiitWorkout
//
//  Created by sungeo on 2018/6/13.
//  Copyright © 2018年 maoyu. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCell.h"
#import "../WorkoutResult.h"
#import "UIColor+Workout.h"
#import "HistoryModel.h"

@interface HistoryViewController (){
    HistoryModel * _model;
    NSArray * _results;
}

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"所有运动";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 108.0f;
    
    _model = [[HistoryModel alloc] init];
    _results = _model.results;
    
    self.topView.backgroundColor = [UIColor mainColor];
    self.totalLabel.text = [NSString stringWithFormat:@"%ld", (long)[_model totalResultCount]];
    self.weekTotalLabel.text = [NSString stringWithFormat:@"%ld", (long)[_model resultCountForThisWeek]];
    
    [self.tableView registerClass:[HistoryCell class] forCellReuseIdentifier:@"HistoryCell"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HistoryCell * cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    cell.workoutResult = [_results objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    HistoryCell * historyCell = (HistoryCell *)cell;
    NSArray * colors = [UIColor fixedColors];
    UIColor * color = [colors objectAtIndex:indexPath.row % colors.count];
    historyCell.circular.backgroundColor = color;
    
}

#pragma mark - UITableViewDelegate


@end
