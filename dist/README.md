# Android 安装包

| 文件 | 用途 |
| --- | --- |
| [SweetDream-arm64.apk](SweetDream-arm64.apk) | ARM64 安卓手机，Android 7.0 / API 24 及以上 |
| [SweetDream-x64.apk](SweetDream-x64.apk) | x86_64 安卓模拟器，已在本机现有模拟器安装启动 |

版本 1.0.0，应用 ID `com.sweetdream.sweet_dream`，target SDK 36。两份都是经过 AOT 编译和压缩的 release 包，以开发密钥签名用于演示。

```powershell
adb -s emulator-5554 install -r dist/SweetDream-x64.apk
```

未附带后台服务、真实支付或完整图书资源。账号和购书是本地演示，内置原创短篇语音和电子书。

重新构建：

```powershell
flutter pub get
flutter build apk --release --split-per-abi --target-platform android-arm64,android-x64
```
