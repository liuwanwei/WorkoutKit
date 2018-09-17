//
//  iCloudModel.m
//  HiitWorkout
//
//  Created by sungeo on 16/9/5.
//  Copyright © 2016年 maoyu. All rights reserved.
//

#import "BDiCloudModel.h"
#import <objc/runtime.h>

// 绑定 self 指针到 CKRecord 对象上用到的键值
const void * AssociatedBDModel = @"AssociatedBDModel";

// iCloud 上数据表字段名字
static NSString * const ObjectId = @"objectId";

@implementation BDiCloudModel

- (CKRecord *)baseICloudRecordWithType:(NSString *)recordType{
    CKRecordZone * zone = [CKRecordZone defaultRecordZone];
    CKRecord * record = [[CKRecord alloc] initWithRecordType:recordType zoneID:zone.zoneID];
    
    if (_objectId != nil) {
        [record setObject:_objectId forKey:ObjectId];
    }
    
    // 将当前对象的指针关联到 CRRecord 对象，用于上传到 iCloud 成功后，更新上传标志
    objc_setAssociatedObject(record, AssociatedBDModel, self, OBJC_ASSOCIATION_ASSIGN);

    return record;
}

// iCloud/CloudKit 的 CKRecord 对象之间互相转换
- (nullable instancetype)initWithICloudRecord:(nonnull CKRecord *)record{
    if (self = [super init]) {
        _cloudRecord = record;
        _objectId = [record objectForKey:ObjectId];
    }
    
    return self;
}

// 将当前对象转换成 CKRecord 对象并返回
- (nullable CKRecord *)newICloudRecord:(NSString *)type{
    CKRecord * record = [self baseICloudRecordWithType:type];
    [self updateICloudRecord:record];
    return record;
}

// 派生类填充需要保存到 iCloud 中的属性
- (void)updateICloudRecord:(CKRecord *)record{
    @throw [NSException exceptionWithName:NSGenericException
        reason:@"派生类必须重载 BDiCloudModel 中声明的 updateICloudRecord 函数" userInfo:nil];
}

@end
