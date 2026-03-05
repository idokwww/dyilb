# 设备环境检测工具

基于kfd内核读取的iOS设备环境检测工具，使用Swift 5.0+开发，UI用SwiftUI，可打包为dylib通过TrollStore安装，无需越狱即可运行。

## 功能特性

1. **内核级检测**：集成开源稳定版kfd源码，实现自动系统版本适配、一键获取内核读写权限
2. **越狱检测**：读取内核proc结构体、syscall表、VFS挂载表、沙盒策略，检测越狱进程、内核钩子、系统分区可写状态
3. **巨魔检测**：检测CoreTrust漏洞痕迹、TrollStore安装状态、当前应用的巨魔权限真实性
4. **设备信息读取**：获取真实的机型、iOS版本、内核版本、UDID、序列号、电池健康
5. **报告导出**：一键全量检测、检测结果分色展示、风险评分、TXT报告导出功能
6. **适配性**：适配iOS 14.0-16.6.1，支持深色/浅色模式，界面简洁易用

## 编译步骤

1. **打开项目**：使用Xcode打开 `DeviceChecker.xcodeproj`
2. **配置签名**：在Xcode中配置开发者账号和签名设置
3. **编译项目**：选择 `Product` -> `Build` 编译项目
4. **生成dylib**：
   - 选择 `File` -> `New` -> `Target`
   - 选择 `Framework & Library` -> `Dynamic Library`
   - 命名为 `DeviceCheckerDylib`
   - 将所有核心文件添加到dylib目标
   - 编译生成dylib文件

## TrollStore安装步骤

1. **安装TrollStore**：在目标设备上安装TrollStore
2. **打包为IPA**：
   - 使用Xcode Archive打包应用
   - 导出为Ad Hoc IPA文件
3. **安装到TrollStore**：
   - 通过TrollStore安装IPA文件
   - 或使用TrollStore的"Install IPA"功能
4. **配置权限**：确保应用有正确的Entitlements权限

## 权限配置

项目包含 `DeviceChecker.entitlements` 文件，配置了TrollStore所需的权限：

- `com.apple.private.security.no-container`
- `com.apple.private.security.no-sandbox`
- `com.apple.private.skip-library-validation`
- `com.apple.security.cs.disable-library-validation`
- `com.apple.security.cs.allow-dyld-environment-variables`
- `com.apple.security.cs.allow-jit`
- `com.apple.security.cs.debugger`

## 风险提示

1. **使用风险**：本工具涉及内核级操作，虽然已做异常处理，但仍存在一定风险
2. **兼容性**：仅支持iOS 14.0-16.6.1，其他版本可能无法正常工作
3. **权限要求**：需要TrollStore提供的特殊权限才能正常运行
4. **检测准确性**：内核级检测可能会被高级越狱工具绕过，仅供参考
5. **法律合规**：使用本工具时请遵守当地法律法规，不得用于非法用途

## 项目结构

- `DeviceChecker/` - 主应用目录
  - `AppDelegate.swift` - 应用代理
  - `SceneDelegate.swift` - 场景代理
  - `ContentView.swift` - 主界面
  - `KFDManager.swift` - kfd内核管理
  - `JailbreakDetector.swift` - 越狱检测
  - `TrollDetector.swift` - 巨魔检测
  - `DeviceInfoReader.swift` - 设备信息读取
  - `ReportGenerator.swift` - 报告生成
  - `kfd.c` - kfd核心实现
  - `kfd.h` - kfd头文件
  - `Info.plist` - 应用配置
- `DeviceChecker.entitlements` - 权限配置
- `DeviceChecker.xcodeproj` - Xcode项目文件

## 技术说明

1. **kfd集成**：集成了开源的kfd内核利用工具，实现内核级访问
2. **异常处理**：当kfd无法获取内核权限时，自动降级为用户态检测
3. **检测方法**：
   - 内核级：读取proc结构体、syscall表、VFS挂载表、沙盒策略
   - 用户态：检测文件、路径、环境变量、URL Scheme
4. **报告生成**：使用TXT格式生成详细的检测报告，包含所有检测结果

## 注意事项

1. **首次运行**：首次运行时可能需要较长时间初始化kfd
2. **权限请求**：导出报告时需要文件访问权限
3. **性能影响**：内核级检测可能会短暂影响设备性能
4. **更新维护**：随着iOS版本更新，kfd可能需要相应更新以保持兼容性

## 贡献

欢迎提交Issue和Pull Request，共同改进这个项目。

## 许可证

本项目基于MIT许可证开源。