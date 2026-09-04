# Buffet
SwiftUI + Combine + Redux 项目实践

### 环境
- Xcode 16 或更新版本（Swift 6 工具链）
- Swift 6 语言模式（应用、单元测试和 UI 测试的 Debug / Release 配置）
- iOS 13.0 或更新版本

Store、Command 和服务层使用 `@MainActor` 隔离；Combine 在更新 Store 前切换到主队列。

### 包管理 

- Swift Package
- 第三方包保留锁定版本，按各自 Package.swift 声明的 Swift 语言模式编译。

### 代码规范

- 使用了 [SwiftLint](https://github.com/realm/SwiftLint)

### 项目架构

- 采用 Clean Architecture，按依赖方向组织为 Domain → Data → Presentation：
  - Domain：`ProductRepository`、`CartRepository` 定义业务边界，`ProductInfoModel` 是纯值对象。
  - Data：`ProductRepositoryImpl` 负责 Moya/Combine 网络适配，`CartRepositoryImpl` 负责 UserDefaults 持久化。
  - Presentation：`Store` 负责状态和用户意图，View 只通过 Action 与 Store 交互。
  - Composition root：`Store` 初始化时注入仓储，生产环境使用默认实现，测试可注入替身。

  迁移采用垂直切片方式，商品列表和购物车已完成，后续设置与充值功能应沿用同样的仓储边界。

[![BAzLG9.png](https://s1.ax1x.com/2020/10/23/BAzLG9.png)](https://imgchr.com/i/BAzLG9)

[![Bn7rX6.png](https://s1.ax1x.com/2020/10/26/Bn7rX6.png)](https://imgchr.com/i/Bn7rX6)

- Store

  Store 就是保存数据的地方，你可以把它看成一个容器。整个应用只能有一个 Store。并提供一些帮助方法来存取，分发以及注册监听状态。

- State

  是 app 一个状态机，状态决定用户界面。

- Action

  View 不能直接操作 State，而只能通过发送 Action 的方式，间接改变存储在 Store 中的 State。

- Reducer

  Reducer 接受原有的 State 和发送过来的 Action，生成新的 State。新的 State 驱动 View 更新。

- Command
  
  来执行所需的副作用,比如网络请求，数据磁盘写入。

### 网络层

- 采用了 Combine + Moya 的方式。

[![nJD1H0.png](https://s2.ax1x.com/2019/09/09/nJD1H0.png)](https://imgchr.com/i/nJD1H0)
代码部分在 NetWork 和 Service 两个文件夹下。
