# Buffet

[![iOS dev Build](https://github.com/FenWangSiCheng/Buffet/actions/workflows/ios.yml/badge.svg?branch=main&event=push)](https://github.com/FenWangSiCheng/Buffet/actions/workflows/ios.yml)

一个使用 SwiftUI 构建的 iOS 商品列表与购物车示例。项目按 Clean Architecture 分层，展示层采用 MVVM + Observation（`@Observable`），通过 Swift 6.2、async/await 和显式 MainActor 隔离管理界面状态与异步请求，并基于 iOS 18 的 SwiftUI API 实现。

仓库名称为 **Buffet**，Xcode 工程及应用 Target 名称为 **PayPayPay**。

## 功能与范围

- 商品列表展示、按名称搜索、商品图片加载。
- 购物车数量增减、单选与全选、删除选中商品、选中金额计算。
- 首页与购物车共享状态，Tab 徽章显示购物车中的商品种类数。
- 购物车以单个快照持久化到 UserDefaults（数量 + 选中状态），重新启动后恢复，并兼容早期按商品 ID 存储的旧 key。
- 加载指示、错误 Toast、请求取消与重复加载控制。

当前商品数据来自 `PayPayPay/Resources/Fixtures/Products.json`，由 Moya 延迟 3 秒返回。三个环境都使用示例地址 `https://store/api`，尚未接入真实后端。扫码按钮是界面占位，付款按钮只会提示功能尚未上线。

## 快速开始

本地已使用 **Xcode 26.1** 验证 `dev` 的 Release 编译。工程使用 **Swift 6 语言模式**（工具链 Swift 6.2），最低部署版本为 **iOS 18**，支持 iPhone 和 iPad。

1. 克隆仓库并打开工程：

   ```sh
   git clone https://github.com/FenWangSiCheng/Buffet.git
   cd Buffet
   open PayPayPay.xcodeproj
   ```

2. 等待 Xcode 通过 Swift Package Manager 解析依赖。
3. 选择 `dev` Scheme 和一个 iOS 模拟器，按 `⌘R` 运行。

模拟器运行不需要配置 Apple 签名证书。真机运行需在 Xcode 中设置可用的签名团队和描述文件。Ruby、Fastlane 和 SwiftLint 用于下文的检查与打包流程，直接在 Xcode 中运行无需先安装这些工具。

### 命令行编译

在仓库根目录执行，与 CI 使用相同的构建参数：

```sh
xcodebuild build \
  -project PayPayPay.xcodeproj \
  -scheme dev \
  -configuration Release-dev \
  -destination 'generic/platform=iOS' \
  -onlyUsePackageVersionsFromResolvedFile \
  CODE_SIGNING_ALLOWED=NO
```

该命令验证面向 iOS 真机的未签名编译，不生成可安装的 IPA。

## 持续集成

[GitHub Actions](https://github.com/FenWangSiCheng/Buffet/actions/workflows/ios.yml) 在每次 push 后运行，也支持手动触发。配置位于 [`.github/workflows/ios.yml`](.github/workflows/ios.yml)。

| 项目 | 当前配置 |
| --- | --- |
| 构建环境 | `macos-26` runner 提供的默认 Xcode，版本输出到日志 |
| 编译目标 | `dev` Scheme / `Release-dev` |
| 依赖 | 使用已提交的 `Package.resolved` 中的版本 |
| 签名 | 关闭，无需 Apple 证书 |
| 检查范围 | 仅编译；不运行测试、SwiftLint 或 IPA 导出 |

README 顶部徽章显示 **main 分支最近一次 push** 的构建结果：成功为 `passing`，失败为 `failing`。其他分支也会触发编译，但不会改变此徽章对应的分支。点击徽章可查看日志；工作流推送并首次运行后才会有结果。

## 代码结构

```text
PayPayPay/
├── Application/           # SwiftUI 入口、环境读取、AppContainer 装配、Preview
├── Domain/
│   ├── Entities/          # Product、Money、Cart、CartItem
│   ├── Errors/            # RepositoryError
│   ├── Repositories/      # 仓储协议
│   └── UseCases/          # LoadProductsUseCase、ManageCartUseCase
├── Data/
│   ├── DTOs/              # ProductDTO：字段映射与取值校验
│   ├── Networking/        # Moya 请求、async/await 桥接、错误转换
│   └── Repositories/      # RemoteProductRepository、UserDefaultsCartRepository
├── Presentation/
│   ├── Products/          # CatalogState、CatalogViewModel、商品列表视图
│   ├── Cart/              # 购物车列表与汇总栏
│   ├── Navigation/        # AppTab、MainTabView
│   └── Shared/            # 主题常量、通用组件、展示扩展
└── Resources/             # 图片、配置、启动页与样本数据
PayPayPayTests/            # Domain、Data、Presentation 单元测试
fastlane/                  # lint 与三环境打包入口
```

依赖方向为 `Presentation → Domain ← Data`，具体实现只在 `Application/AppContainer` 中装配。各层职责：

- **Application**：`PayPayPayApp` 使用 SwiftUI App 生命周期（没有 AppDelegate / SceneDelegate），用 `@State` 持有 `CatalogViewModel` 并通过 `.environment` 注入；`AppEnvironment` 从 Info.plist 读取环境标识与 API 地址。
- **Domain**：不依赖任何 UI 或网络框架，只包含实体、仓储协议和 Use Case。`LoadProductsUseCase` 拉取商品后再读取购物车，`ManageCartUseCase` 是 actor，串行处理数量增减、选中与删除。
- **Data**：`ProductAPIClient`（`@MainActor`）把 Moya 回调桥接为 async/await，`ProductRequest` 保证 continuation 只 resume 一次、取消时立即结束，解码转移到后台队列；`UserDefaultsCartRepository` 以单个快照读写购物车，并兼容早期按商品 ID 存储的旧 key。
- **Presentation**：`CatalogViewModel` 是 `@MainActor` + `@Observable` 的唯一共享状态源，首页与购物车 Tab 共用；`CatalogState` 在数据或搜索词变化时一次性重算可见商品、购物车项、徽章数量、全选状态与合计金额，视图只读取结果。叶子视图只接收展示值与事件闭包。

分层方向由 `.swiftlint.yml` 的自定义规则强制：Domain 不得 import SwiftUI / UIKit / Moya / Kingfisher，Data 不得 import SwiftUI / UIKit。金额在 Domain 中用 `Money` / `Decimal` 表达，取值校验集中在 DTO 边界；网络失败统一映射为 `RepositoryError`，展示文案集中在 `Presentation/Shared/Extensions`。目前业务代码位于单个应用 Target，尚未拆分为独立 Package。

## 环境配置

| Scheme | 用途 | 应用显示名称 | Bundle ID |
| --- | --- | --- | --- |
| `dev` | 开发 | 飞狼GO Dev | `cn.com.fenrir-inc.FenrirPay.dev` |
| `stg` | 预发布 | 飞狼GO Stg | `cn.com.fenrir-inc.FenrirPay.stg` |
| `pro` | 生产 | 飞狼GO | `cn.com.fenrir-inc.FenrirPay` |

三个环境可同时安装，UserDefaults 随各自 Bundle ID 隔离。每个 Scheme 的 Run / Test / Analyze 使用 `Debug-环境`，Profile / Archive 使用 `Release-环境`。

- `Resources/Configurations/Project/`：Swift 版本、最低系统版本、环境标识与编译条件。
- `Resources/Configurations/Targets/`：Bundle ID、显示名称、API 地址；`BaseTarget.xcconfig` 统一管理版本号与构建号。
- `Application/AppEnvironment.swift`：读取 Info.plist 注入的环境和 API 地址，启动时校验环境标识与 URL 的 scheme / host，配置缺失或非法会直接 `preconditionFailure`。

接入真实服务时，修改各环境的 `API_BASE_URL`，并调整 `AppContainer` 中的 `MoyaProvider.delayedStub(3)`。xcconfig 中的 URL 写作 `https:/$()/store/api`，用于避免 `//` 被解析为注释。

## 依赖

iOS 依赖由 Swift Package Manager 管理，锁文件位于 `PayPayPay.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`。

| 依赖 | 锁定版本 | 用途 |
| --- | --- | --- |
| Moya | 15.0.3 | 请求封装与样本响应 |
| Kingfisher | 8.12.0 | SwiftUI 图片加载 |
| Alamofire | 5.12.0 | Moya 底层网络依赖 |
| RxSwift | 6.10.2 | Moya 可选响应式产品依赖 |
| ReactiveSwift | 6.7.0 | Moya 可选响应式产品依赖 |

应用直接链接 Moya 和 Kingfisher，业务代码未直接使用 RxSwift 或 ReactiveSwift。更新依赖时同步提交 `Package.resolved`。

## 测试

在 Xcode 中选择 `dev`，按 `⌘U` 运行 Scheme 中的测试。也可先用 `xcrun simctl list devices available` 查询模拟器 ID，再执行：

```sh
xcodebuild test \
  -project PayPayPay.xcodeproj \
  -scheme dev \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_ID>' \
  -only-testing:PayPayPayTests \
  -onlyUsePackageVersionsFromResolvedFile \
  CODE_SIGNING_ALLOWED=NO
```

将 `<SIMULATOR_ID>` 替换为本机可用设备 ID。上面的命令运行项目的全部单元测试。

单元测试按 `Domain` / `Data` / `Presentation` 分组，覆盖：

- 购物车规则与持久化：数量不会为负、清零后自动取消选中、全选只作用于购物车内的商品、删除选中项后写入原子快照、旧 key 迁移、`Decimal` 计费。
- 加载与网络：页码透传、请求返回后恢复最新购物车、HTTP 状态码与 URLError 映射、非法载荷与空 ID 校验、后台队列解码、在途请求取消。
- 展示层：重复加载去重、取消语义、旧请求结果不能覆盖新结果、购物车派生值（徽章 / 合计 / 全选）、Toast 自动关闭。

CI 当前不会运行测试，编译徽章不代表测试结果。

## 代码检查与打包

### 工具准备

仓库通过 `.ruby-version` 固定 Ruby **4.0.6**，通过 `Gemfile` / `Gemfile.lock` 管理 Bundler **4.0.20** 和 Fastlane **2.238.0**。已安装并初始化 rbenv 后，在根目录执行：

```sh
rbenv install -s
gem install bundler -v 4.0.20 --no-document
bundle config set --local path vendor/bundle
bundle install
brew install swiftlint
```

### SwiftLint

```sh
bundle exec fastlane ios lint
```

`.swiftlint.yml` 使用默认规则，检查范围限定为 `PayPayPay/`（应用）与 `PayPayPayTests/`（单元测试），并额外用自定义规则校验分层依赖（见「代码结构」）。三个 Fastlane 打包入口都会先执行 lint；error 阻止打包，warning 保留为提示。

### 归档与导出

```sh
# 开发环境：默认导出开发包
bundle exec fastlane ios build_ios_develop

# 预发布环境：默认导出开发包
bundle exec fastlane ios build_ios_staging

# 生产环境：默认导出 App Store Connect 分发包
bundle exec fastlane ios build_ios_production
```

三个入口使用各自的 `Release-环境` 配置，仅在本地归档和导出，不自动上传。签名沿用工程中的团队，支持通过 `FASTLANE_TEAM_ID` 覆盖；本机需具备相应证书和描述文件。

可用 `export_method` 指定 `debugging`、`release-testing`、`app-store-connect` 或 `enterprise`，例如：

```sh
FASTLANE_TEAM_ID=YOUR_TEAM_ID bundle exec fastlane ios build_ios_staging export_method:release-testing
```

没有签名环境时，可生成未签名归档，不导出 IPA：

```sh
bundle exec fastlane ios build_ios_develop unsigned:true
```

产物位于 `output/<scheme>/`，文件名包含环境、版本号、构建号、时间和 Git 提交号；日志位于其 `logs/` 子目录。构建过程保留配置中的版本号与构建号。`output/`、`build/`、`.bundle/` 和 `vendor/bundle/` 已加入 Git 忽略规则。

## 许可证

本项目使用 [Apache License 2.0](LICENSE)。
