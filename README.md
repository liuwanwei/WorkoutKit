# 使用说明

CocoaPods library aims to replace BDWorkoutKit library.

## 初始化使用环境

一般放在 App 启动时，didFinishLaunchingWithOptions 中调用：

```
    BDiCloudManager * cloudManager = [BDiCloudManager sharedInstance];

    // 获取并更新 iCloud Token
    [cloudManager updateICloudToken:nil];

    // 监听 iCloud 可用状态变化
    [cloudManager registerIdentityChangeNotification];
```
