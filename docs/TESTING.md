# 验证记录

日期：2026-11-13，Asia/Tokyo。

## 结果

| 检查 | 结果 |
| --- | --- |
| `flutter analyze` | 通过，0 issues |
| `flutter test` | 通过，2 个组合筛选行为测试 |
| Android 集成测试 | 通过，真实插件与用户操作流程 |
| 页面状态截图 | 通过，浅色 21 + 深色 21 |
| 补充截图 | 阅读器、搜索无结果、账号表单校验，共 3 张 |
| Pixso 映射与 Markdown 链接 | 42 个节点的设计图、应用截图及文档图片均存在 |
| Android release 构建 | ARM64 与 x86_64 均成功；API 24+，target SDK 36 |
| release 安装启动 | x64 包在现有模拟器安装成功，冷启动返回 Status: ok |
| 构建文件清理 | Flutter clean 与 Gradle clean 均完成，释放约 1968.5 MiB；项目剩余约 77.6 MiB，包含两份安装包与全部截图 |

## 实际验证路径

1. 底部导航进入搜索，输入不存在的标题，断言无结果，再搜索 Kubo。
2. 进入结账，切换保存卡片开关，确认演示购买，断言书籍入架。
3. 将书架写入本地存储，建立新状态实例读取，断言已购买书籍仍存在。
4. 通过实际 Android 音频插件播放本地 MP3，断言播放中、有真实时长、有非零进度。
5. 跳到第 10 秒，断言进度更新；暂停，再进入电子书，断言原创正文可见。
6. 重置筛选并选择免费，断言 Coco 出现、付费的 Kubo 不出现。
7. 注册表单缺少密码时显示错误；填写有效密码后完成本地演示注册。
8. 对浅色、深色各 21 个状态截图；截图前检查无布局或框架异常。
9. 操作深色开关，建立新实例读取，断言主题已持久化；结束时清除测试数据。

每张设备截图为 1080×2400 PNG。截图时复用原有 `emulator-5554`，Android 11 / API 30 / x86_64；测试完成后已恢复该设备原来的 1080×1920、240 dpi。未安装新模拟器或系统镜像。

## 截图查看

- [浅色界面总览](overview-light.jpg)
- [深色界面总览](overview-dark.jpg)
- [逐画板设计与实现映射](UI-MAPPING.md)
- [45 张原始应用截图](screenshots/)
- [发布版启动截图](release-smoke.png)

总览图只是方便检查的缩略图拼版，单页 PNG 保留原始设备输出。

## 范围

未进行 iOS / Xcode 构建、真实支付、真实鉴权、邮件或推送测试。安装包仅用于本地演示；生产服务和完整授权内容没有配置。运行时播放的是原创短篇示例语音。

可复现命令：

```powershell
flutter analyze
flutter test
powershell -ExecutionPolicy Bypass -File scripts/verify-android.ps1
python scripts/screenshot-overview.py
```

最后一条仅生成可选总览，需要 Pillow；应用运行本身不需要 Python。

清理后 `build`、`build_temp` 和 `.dart_tool` 均已移除，安装包保留在 `dist`。下次运行先执行 `flutter pub get`。未删除全局 SDK、依赖缓存或已有模拟器。
