# Buffet
SwiftUI + Combine + Redux 项目实践

### 环境
- Xcode12.1
- Swift5.3

### 包管理 

- Swift Package 

### 代码规范

- 使用了 [SwiftLint](https://github.com/realm/SwiftLint)

### 项目架构

- 采用类似于 Redux 的架构 

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
