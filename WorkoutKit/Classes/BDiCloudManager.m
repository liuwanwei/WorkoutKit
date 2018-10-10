//
//  WorkoutCloudManager.m
//  7MinutesWorkout
//
//  Created by sungeo on 15/8/5.
//  Copyright (c) 2015年 maoyu. All rights reserved.
//

#import "BDiCloudManager.h"
#import "WorkoutResult.h"
#import "WorkoutAppSetting.h"
#import "CacheManager.h"
#import "EXTScope.h"
#import "UIAlertController+Window.h"

static NSString * const AllRecords = @"TRUEPREDICATE";

// 存储在本地用户信息中用到的 key
static NSString * iCloudTokenKey = @"cn.buddysoft.hiitrope.UbiquityIdentityToken";

@implementation BDiCloudManager{
    id _iCloudToken;
    
    RecordsReceivedBLock _recordsReceivedBlock;
    RecordSavedBlock _recordSavedBlock;
}

+ (instancetype)sharedInstance{
    static BDiCloudManager * sInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sInstance == nil) {
            sInstance = [[BDiCloudManager alloc] init];
        }
    });
    
    return sInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        _container = [CKContainer defaultContainer];
        _privateDatabase = [_container privateCloudDatabase];
        // [self registerIdentityChangeCustomNotification];
    }
    
    return self;
}

// 注册系统级的 iCloud 可用状态改变事件处理
// TODO: 可以隐藏到黑盒子中，在模块初始化时自动完成，不必由模块使用者调用
- (void)registerIdentityChangeNotification{
    // 只让 sharedInstance 实例侦听这个消息
    if (self != [BDiCloudManager sharedInstance]){
        @throw [NSException exceptionWithName:NSGenericException reason:@"只能有一个实例侦听这个消息" userInfo:nil];
    }

    [[NSNotificationCenter defaultCenter]
        addObserver: self
        selector: @selector(iCloudAccountAvailablityChanged:)
        name: NSUbiquityIdentityDidChangeNotification
        object: nil
    ];
}

// iCloud 身份信息改变消息处理
- (void)iCloudAccountAvailablityChanged:(NSNotification *)notification{
    WorkoutAppSetting * setting = [WorkoutAppSetting sharedInstance];
    if (! [setting useICloudSchema]){
        // 如果用户没有选择使用 iCloud，就不做处理
        return;
    }

    id currentToken = [self getSystemICloudToken];        
    if (currentToken) {
        /**
         *
         * 检测到 iCloud 服务被打开
         * 可以推测此前 iCloud 服务是关闭状态，用户 iCloud 开关肯定也是关闭状态，所以不需要做处理
         */
    }else{

        /**
         * 检测到 iCloud 服务被关闭
         */
        
        // 弹出 iCloud 服务关闭提示
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"iCloud 服务被关闭" 
            message:@"生成的训练数据将会被保存到本地，不会上传到云端。"
            preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" 
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action){                
            }];
        [alert addAction: action];
        [alert show];

        // 修改 App 内的 iCloud 可用标志
        setting.useICloud = @(NO);
    }
    
    [self updateICloudToken:currentToken];
}

// 取出缓存在本地的 iCloud token
// 由于不再支持对比 iCloud Token 是否变化，所以该接口不再用到
- (id)loadICloudToken{
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:iCloudTokenKey];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }else{
        return nil;
    }
}

// 将 iCloud token 缓存在本地
- (void)syncICloudTokenToDisk:(id)token{
    if (token) {
        NSData * tokenData = [NSKeyedArchiver archivedDataWithRootObject: token];
        [[NSUserDefaults standardUserDefaults] setObject: tokenData forKey: iCloudTokenKey];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:iCloudTokenKey];
    }
}

// 取出当前 iCloud Token
- (id)getSystemICloudToken{
    return [[NSFileManager defaultManager] ubiquityIdentityToken];
}

// 从系统获取当前 iCloud Token，更新到内存和本地文件存储中
// TODO: 也应隐藏起来，不比让调用者显式调用
- (id)updateICloudToken:(id)newToken{
    id currentToken = newToken;
    if (currentToken == nil) {
        // 取出当前 iCloud Token
        currentToken = [self getSystemICloudToken];
    }
    
    _iCloudToken = currentToken;    
    [self syncICloudTokenToDisk:currentToken];
    
    return currentToken;
}

// 判断用户是否登录了 iCloud
// 并不意味用户已授权给我们使用 iCloud，也不意味我们必须用 iCloud 存储数据
- (BOOL)iCloudAvailable{
    return _iCloudToken == nil ? NO : YES;
}

// 当前账户的 iCloud 不可用
- (void)iCloudNotEnabledHandler{
    NSLog(@"调用 accountStatusWithCompletionHandler 失败");
}

// 查询数据最终实现代码
- (void)finalQueryRecord{
    // 获取要查询的记录类型
    NSString * type = (NSString *)[self.delegate performSelector:@selector(recordType)];
    // 设备账号的 iCloud 服务可用，查询所有数据
    NSPredicate * predict = [NSPredicate predicateWithValue:YES];
    CKQuery * query = [[CKQuery alloc] initWithRecordType:type predicate:predict];
    
    [_privateDatabase performQuery:query  inZoneWithID:nil completionHandler:^(NSArray * results, NSError * error){        
        if (error) {
            NSLog(@"查询 %@ 出现问题: %@", type, error);
        }else{
            NSLog(@"查询 %@ 数据成功", type);
            if (self->_recordsReceivedBlock) {
                self->_recordsReceivedBlock(results);
            }
        }
    }];
}

- (void)queryRecordsWithCompletionBlock:(RecordsReceivedBLock)block{
    self->_recordsReceivedBlock = block;
    [self finalQueryRecord];
}

- (void)finalAddRecord:(CKRecord *)record{
    @weakify(self);
    
    // 先查用户是否有权限，再做后续动作
    [_container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * error){
        @strongify(self);
        
        if (accountStatus == CKAccountStatusAvailable) {
            [self->_privateDatabase saveRecord:record completionHandler:^(CKRecord * record, NSError * error){
                if (error) {
                    NSLog(@"iCloud/CKRecord 添加失败：An error occured in %@: %@", NSStringFromSelector(_cmd), error);
                }else{
                    NSLog(@"添加数据（iCloud/CKRecord）数据成功");                    
                    if (self->_recordSavedBlock) {
                        self->_recordSavedBlock(record);
                    }
                }
            }];
        }else{
            [self iCloudNotEnabledHandler];
        }
    }];
}

/**
 *  将新的训练结果保存到 iCloud 中去
 *
 *  @param record WorkoutResult object
 */
- (void)addRecord:(CKRecord *)record{
    [self finalAddRecord:record];
}

- (void)addRecord:(CKRecord *)record withCompletionBlock:(RecordSavedBlock)block{
    _recordSavedBlock = block;
    [self finalAddRecord:record];
}


@end
