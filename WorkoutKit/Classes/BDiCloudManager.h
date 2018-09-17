//
//  WorkoutCloudManager.h
//  7MinutesWorkout
//
//  Created by sungeo on 15/8/5.
//  Copyright (c) 2015年 maoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

// 查询对象成功后执行的 block
typedef void (^RecordsReceivedBLock)(NSArray * records);

// 保存对象到 iCloud 成功后执行的 block
typedef void (^RecordSavedBlock)(CKRecord * record);


@protocol BDiCloudManagerDelegate <NSObject>

@required
- (NSString *)recordType;

@end

@interface BDiCloudManager : NSObject

@property (nonatomic, weak) CKContainer * container;
@property (nonatomic, weak) CKDatabase * privateDatabase;

@property (nonatomic, assign) id<BDiCloudManagerDelegate> delegate;

+ (instancetype)sharedInstance;

// 获取设备的 iCloud 可用状态，必须在主线程中调用
- (id)updateICloudToken:(id)newToken;

// 注册 iCloud 状态侦听：sharedInstance 主动调用该接口
- (void)registerIdentityChangeNotification;

// 返回设备的 iCloud 可用状态
- (BOOL)iCloudAvailable;

//- (void)queryRecordsWithType:(NSString *)recordType;
// 用 delete 方式的添加记录
- (void)addRecord:(CKRecord *)record;
// 用 block 方式添加记录
- (void)addRecord:(CKRecord *)record withCompletionBlock:(RecordSavedBlock)block;
// 用 block 方式查询数据
- (void)queryRecordsWithCompletionBlock:(RecordsReceivedBLock)block;

@end
