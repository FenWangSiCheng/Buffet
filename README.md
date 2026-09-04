# Buffet

使用 SwiftUI 展示商品列表和购物车的 iOS 示例项目，按 Clean Architecture 分层，展示层采用 MVVM。

## 开发环境

- Xcode 16 或更新版本，Swift 6 语言模式。
- 应用及测试 Target 最低支持 iOS 15；保留 `ObservableObject` / Combine 驱动 SwiftUI 更新。
- 通过 Swift Package Manager 管理 Moya、Kingfisher，提交 `Package.resolved` 固定已验证的依赖版本。

打开 `PayPayPay/PayPayPay.xcodeproj`，选择 `dev`、`stg` 或 `pro` scheme。

### dev / stg / pro 环境

参考 SwiftModul 的 Project / Target 分层 xcconfig 配置，共享设置放在 Base 文件，环境差异放在各自文件中。

| Scheme | 用途 | 桌面名称 | Bundle ID |
| --- | --- | --- | --- |
| `dev` | 开发 | 飞狼GO Dev | `cn.com.fenrir-inc.FenrirPay.dev` |
| `stg` | 预发布 | 飞狼GO Stg | `cn.com.fenrir-inc.FenrirPay.stg` |
| `pro` | 生产 | 飞狼GO | `cn.com.fenrir-inc.FenrirPay` |

三个环境可同时安装，默认 UserDefaults 也随 Bundle ID 隔离。生产环境沿用原 Bundle ID。

- 每个 Scheme 的 Run / Test / Analyze 使用 `Debug-环境`，Profile / Archive 使用 `Release-环境`，共六个 Build Configuration；应用、单元测试和 UI 测试 Target 均已同步。
- `PayPayPay/PayPayPay/Resources/Configurations/Project/` 管理 Swift 版本、最低系统版本、`APP_ENVIRONMENT` 及 `DEV` / `STG` / `PRO` 编译条件；Debug 配置额外包含 `DEBUG`。
- `PayPayPay/PayPayPay/Resources/Configurations/Targets/` 管理 Bundle ID、显示名称、版本号和 `API_BASE_URL`。URL 使用 `https:/$()/store/api` 写法，避免 `//` 被 xcconfig 当作注释。
- `Info.plist` 注入构建变量，应用装配通过 `AppEnvironment.apiBaseURL` 读取地址；可通过 `AppEnvironment.current` 获取环境。
- 三个环境暂时都使用原有示例地址 `https://store/api`，仍返回延迟样本数据。接入真实服务时，需要填写各环境真实地址并调整 `AppContainer` 中的 Moya stub 策略。
- 真机运行 dev / stg 时，签名团队需要能为对应的新 Bundle ID 生成描述文件。原有第三方 URL 回调配置沿用，接入真实登录时需按平台登记信息配置。

原来的 `Debug` / `Release` 配置已替换为带环境后缀的配置；命令行或 CI 请显式选择环境 Scheme。例如生产归档：

```sh
xcodebuild archive \
  -project PayPayPay/PayPayPay.xcodeproj \
  -scheme pro \
  -destination 'generic/platform=iOS' \
  -archivePath build/PayPayPay-pro.xcarchive
```

### Swift 6 并发检查（2026-09-04）

- 应用、单元测试、UI 测试 Target 的所有环境 Debug / Release 配置均使用 `SWIFT_VERSION = 6.0`，严格并发检查由 Swift 6 语言模式启用。
- 当前没有启用默认 MainActor 隔离、Approachable Concurrency 或 `NonisolatedNonsendingByDefault`；未标注声明使用默认的 nonisolated 语义。UI 状态和请求生命周期显式由 `@MainActor` 管理，跨回调边界传递 `Sendable` 数据。
- Moya 回调显式使用后台队列完成 JSON 解码，随后回到 MainActor 完成 continuation；回调标注 `@Sendable`，避免继承调用方的 actor 隔离。第三方依赖仍按各自 Package 的语言模式编译，不代表依赖源码也全部迁移到 Swift 6。
- Toast 在实际展示时启动两秒关闭计时，消失时取消旧回调，支持页面出现后才到达的错误提示。沿用现有延迟工具。
- 本次使用 Xcode 26.1 / Swift 6.2.1 验证；未引入仅 Swift 6.2 可用的语法。新增后台解码及延迟出现 Toast 的回归测试。

### 三方依赖更新（2026-09-04）

- Moya：`15.0.0-alpha.1` → `15.0.3`（正式版）。
- Kingfisher：`5.15.0` → `8.12.0`；SwiftUI 图片组件改为使用统一的 `Kingfisher` 产品与模块。最低系统版本统一为 iOS 15，直接使用 `KFImage`。
- Alamofire：`5.2.2` → `5.12.0`；RxSwift：`5.1.1` → `6.10.2`。
- ReactiveSwift：从 Moya fork `6.1.0` 切换到官方上游 `6.7.0`。Moya 15.0.3 的依赖声明限制在 `6.x`，因此采用该范围内最新稳定版，不能直接解析到上游 `7.2.1`。
- 应用仅链接 Moya 和 Kingfisher；RxSwift、ReactiveSwift 属于 Moya 包的可选响应式产品依赖，业务代码未直接使用。

## 目录与职责

物理文件夹与 Xcode 分组保持一致：

```text
PayPayPay/PayPayPay/
├── Application/
│   ├── AppDelegate.swift
│   ├── AppEnvironment.swift
│   ├── SceneDelegate.swift
│   ├── DependencyInjection/AppContainer.swift
│   ├── Previews/CatalogPreviews.swift
│   └── Info.plist
├── Domain/
│   ├── Entities/                 # Product、CartItem
│   ├── Errors/                   # 与框架无关的 RepositoryError
│   ├── Repositories/             # ProductRepository、CartRepository 协议
│   └── UseCases/                 # LoadProductsUseCase、ManageCartUseCase
├── Data/
│   ├── DTOs/                     # API 字段及 ProductDTO → Product 映射
│   ├── Networking/               # Moya 请求、取消和错误转换
│   └── Repositories/             # RemoteProductRepository、UserDefaultsCartRepository
├── Presentation/
│   ├── Products/
│   │   ├── Models/               # CatalogState、CatalogAction、商品显示格式
│   │   ├── ViewModels/            # CatalogViewModel
│   │   └── Views/                # ProductListView、ProductRowView
│   ├── Cart/Views/               # CartView、CartRowView、CartSummaryView
│   ├── Navigation/               # MainTabView
│   └── Shared/                   # Components、Extensions、Utilities
└── Resources/
    ├── Assets.xcassets/
    ├── Configurations/           # Project / Targets 分层环境配置
    ├── Base.lproj/
    ├── Fixtures/Products.json
    └── Preview Content/

PayPayPay/PayPayPayTests/
├── Domain/
├── Data/
├── Presentation/
└── Support/                      # 内存仓储、可控异步仓储
```

依赖方向为 `Presentation → Domain ← Data`，`Application` 负责装配三者。

- **Domain** 只定义商品、购物车、仓储契约和业务规则，不引用 SwiftUI、Moya、UserDefaults 或 DTO。数量下限、选中规则、删除和加载后恢复购物车都由 Use Case 处理。
- **Data** 实现 Domain 的仓储协议。JSON 字段名、图片地址拼接、HTTP 状态码和存储键留在这一层。网络回调桥接到 async/await，每个请求单独管理取消与 continuation。
- **Presentation** 负责页面状态与用户意图。`CatalogViewModel` 通过注入的 Use Case 工作；首页和购物车共享同一实例，避免两套状态不一致。View 不能直接修改 `CatalogState`。
- **Application** 是 composition root。`AppContainer` 创建具体仓储并注入 Use Case、ViewModel；`SceneDelegate` 持有页面生命周期，断开场景时取消加载。Preview 也在这里装配，使用独立的 UserDefaults suite。

目前仍是单一应用 Target，没有额外引入 SPM 业务模块。`Scripts/check_architecture.py` 检查跨层类型引用，并单独用 Swift 6 编译检查 Domain；它是轻量边界检查，不替代独立模块的编译器访问控制。

## 命名规范

- 实体使用业务名：`Product`、`CartItem`，不带通用 `Model` 后缀。
- 业务操作使用 `…UseCase`；仓储协议使用 `…Repository`；具体实现说明技术或来源，例如 `UserDefaultsCartRepository`。
- 网络载荷使用 `…DTO`，页面使用 `…View`，展示逻辑使用 `…ViewModel`。
- 扩展文件使用 `类型+职责.swift`，例如 `CartItem+Presentation.swift`。
- 页面按 Products、Cart 等功能归类，避免再增加含义模糊的 `Service`、`Utils`、`DataFlow` 文件夹。

## 行为与迁移范围

商品展示、搜索、购物车增减、单选／全选、删除和总价计算均沿用原有交互。商品与购物车状态拆分后，持久化仍使用 `cart.count.<id>`、`cart.selected.<id>`，已有购物车可继续恢复。

修正了数量归零／删除后选中状态未清除、空购物车被判定为全选、搜索缺少商品名时强制解包，搜索框点击区域拦截输入焦点，以及底部两个 Tab 的徽标仍按三个 Tab 定位的问题。请求失败保留现有商品；取消不显示错误；已取消请求的结果不会覆盖后续请求。

应用仍通过 Moya 延迟 3 秒返回 `Resources/Fixtures/Products.json`，`https://store/api` 是原项目的示例地址，不代表已经接入可用后端。充值、登录原本没有可用页面和完整请求链，本次保留其 DTO 定义，移除了无调用方的 Action／State 占位分支。扫码、付款也仍是原有占位交互，未增加支付功能。

## 验证

在仓库根目录运行边界检查：

```sh
python3 Scripts/check_architecture.py
```

在 Xcode 中运行 `PayPayPayTests` 与 `CatalogFlowUITests`，或将下面的 `<SIMULATOR_ID>` 替换为本机可用模拟器 ID：

```sh
xcodebuild test \
  -project PayPayPay/PayPayPay.xcodeproj \
  -scheme dev \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_ID>' \
  -only-testing:PayPayPayTests \
  -only-testing:PayPayPayUITests/CatalogFlowUITests \
  -disableAutomaticPackageResolution \
  CODE_SIGNING_ALLOWED=NO
```

单元测试覆盖仓储失败、HTTP／解码错误、请求取消和重复加载、旧结果隔离、加载期间的购物车修改、持久化键兼容性及数量／选中规则。UI 测试验证真实 bundle 中的商品样本加载、搜索和 Tab 导航。
