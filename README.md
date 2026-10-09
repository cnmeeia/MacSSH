# SSHMon · Mac + iPhone 服务器面板（v0.4）

纯 SSH 客户端：连上就能看监控、开终端，服务器上**不用装任何东西**（读取 /proc，支持 Debian / Arch / Ubuntu 等 Linux）。

## 功能
- 服务器列表：密码或 OpenSSH 私钥（ed25519 / RSA）登录，密码与私钥存钥匙串
- 监控面板（每 3 秒刷新）：负载 1/5/15、进程数、CPU 总览与每核、内存 Used/Cache/Free 与 Swap、各磁盘挂载点、RX/TX 实时曲线和峰值、每块网卡速率
- 终端：xterm-256color，窗口大小同步，切到监控再切回来会话不断
- 断线 5 秒自动重连

## v0.4 更新（并发 + Liquid Glass 审查）
- App 和 Core 都切到 Swift 6 语言模式；Core 在 Swift 6.1.2 下零并发警告编译通过，单测通过
- `Monitor` 改为 actor，上一帧采样不再有数据竞争；采样间隔用 `Duration`
- `ShellSession` 去掉跨线程回调，改为有序的 `events: AsyncStream<ShellEvent>`；所有可变状态都在锁内
- `SSHConnection.warmUp()`：预握手时不再把非 Sendable 的 SSHClient 跨隔离域传递；超时改为只读
- Citadel 的 `SSHClient` 尚未标 Sendable，用 `@preconcurrency import` 隔离
- 监控卡片统一放进 `GlassEffectContainer`（iOS/macOS 26），单次渲染；间距设 0，卡片不会融成一团
- 终端「重新连接」按钮在 26 上用 `.glassProminent`
- 如果你的 Xcode 在 Swift 6 模式下报 App 端并发错误，可先把 `project.yml` 里 `SWIFT_VERSION` 改回 `5.0`，把报错发我

## v0.3 更新（按 SwiftUI Pro 规则审查）
- 数据流全面换成 `@Observable` + `@State` / `@Environment`，不再依赖 Combine
- 新增 `ServerSession`：每台服务器一份连接 + 监控数据 + 终端，切走再回来秒开，终端历史保留
- 修掉每次界面刷新都读 Keychain 的问题（只在首次建会话时读）
- 去掉 `AnyView`；`String(format:)` 改为 FormatStyle；`onAppear` 改 `task()`，离开页面自动取消采样
- 终端输出改用有序 AsyncStream 送回主线程，去掉 GCD；`Task.sleep(for:)`
- 无障碍：尊重「减弱动态效果」，大数字跟随动态字体，图标按钮带文字标签，磁盘告警不只靠颜色
- 私钥输入改为多行 TextField（带占位提示）
- 按功能拆分目录：App / Servers / Sessions / Dashboard / Terminal / Shared，一个类型一个文件
- 打开 `SWIFT_STRICT_CONCURRENCY = complete`（Swift 5 模式下只报警告）

## v0.2 更新
- 苹果白浅色主题 + 毛玻璃卡片（用 Xcode 26 编译、跑在 iOS 26 / macOS 26 上自动用 Liquid Glass，旧系统用系统毛玻璃材质）
- 连接提速：监控和终端共用一条 SSH 连接；点选服务器就提前握手；首帧立即显示（不再等 1 秒预采样）；切换服务器保持连接，切回秒开；8 秒连接超时，断线 1/2/4/8 秒退避重连
- 键盘只在终端页弹出，离开终端立刻收起；终端第一次打开时才建会话
- 动画：卡片依次浮现、数字滚动、进度条与曲线平滑过渡、标签页切换缩放淡入、骨架屏加载、状态呼吸灯

## 构建（需要 Mac + Xcode 16，iOS 18 / macOS 15 以上）
```bash
brew install xcodegen
cd App
xcodegen generate
open SSHMon.xcodeproj
```
选 `SSHMon-macOS` 直接运行；选 `SSHMon-iOS` 时在 Signing & Capabilities 里选你的 Apple ID 团队，再装到 iPhone。

## 目录
- `Core/`：Swift Package（SSH 连接、采集脚本、解析、PTY 终端会话），附命令行测试工具
  - `swift run sshmon-cli <host> <port> <user> <密码>` 或把密码换成 `@私钥路径`
- `App/Sources/`：SwiftUI 界面（Mac 与 iPhone 共用）

## 下一步（v0.2 计划）
- 文件管理（SFTP 上传 / 下载）
- 端口转发
- 首次连接记住主机指纹（当前版本接受任意主机密钥，只连自己的服务器）
