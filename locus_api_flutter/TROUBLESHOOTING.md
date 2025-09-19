# 故障排除指南

本文档包含使用 Locus API Flutter Plugin 时可能遇到的常见问题和解决方案。

## 常见错误

### 1. ScaffoldMessenger 错误

**错误信息**:
```
Typically, the ScaffoldMessenger widget is introduced by the MaterialApp at the top of your application widget tree.
```

**原因**: 在 MaterialApp 完全初始化之前尝试使用 ScaffoldMessenger。

**解决方案**: 确保 Widget 结构正确：
```dart
MaterialApp(
  home: MyHomePage(), // 不要直接在这里使用 Scaffold
)

class MyHomePage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 在这里可以安全使用 ScaffoldMessenger.of(context)
    );
  }
}
```

### 2. Activity Context 错误

**错误信息**:
```
PlatformException(LOCUS_API_ERROR, Calling startActivity() from outside of an Activity context requires the FLAG_ACTIVITY_NEW_TASK flag, null, null)
```

**原因**: 插件尝试从应用上下文启动 Activity，但需要 Activity 上下文。

**解决方案**: 
- 插件已实现 `ActivityAware` 接口来正确获取 Activity 上下文
- 确保在调用需要 Activity 的方法时，应用处于前台状态

### 3. Locus Map 未安装

**错误信息**: 方法调用返回 `false` 或抛出异常

**解决方案**:
1. 确保设备上已安装 Locus Map
2. 使用 `isLocusMapInstalled()` 检查安装状态
3. 引导用户安装 Locus Map

```dart
bool isInstalled = await locusApi.isLocusMapInstalled();
if (!isInstalled) {
  // 显示安装提示
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('需要 Locus Map'),
      content: Text('请先安装 Locus Map 应用'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('确定'),
        ),
      ],
    ),
  );
}
```

### 4. 权限问题

**症状**: 某些功能无法正常工作

**解决方案**: 确保应用具有必要的权限：

在 `android/app/src/main/AndroidManifest.xml` 中添加：
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### 5. Java 版本兼容性

**错误信息**:
```
Dependency requires at least JVM runtime version 11. This build uses a Java 8 JVM.
```

**解决方案**: 项目已配置为支持 Java 8，如果仍有问题：

1. 检查 `android/build.gradle`:
```gradle
compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
}
```

2. 检查 `android/app/build.gradle.kts`:
```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
}
```

## 调试技巧

### 1. 启用详细日志

在 Android 代码中添加日志：
```kotlin
import android.util.Log

// 在方法中添加
Log.d("LocusApiFlutter", "Method called: ${call.method}")
```

### 2. 检查 Locus Map 状态

```dart
Future<void> debugLocusStatus() async {
  try {
    final isInstalled = await locusApi.isLocusMapInstalled();
    print('Locus installed: $isInstalled');
    
    if (isInstalled) {
      final info = await locusApi.getLocusInfo();
      print('Locus info: $info');
    }
  } catch (e) {
    print('Debug error: $e');
  }
}
```

### 3. 测试基本功能

```dart
Future<void> testBasicFunctionality() async {
  try {
    // 1. 检查安装
    final isInstalled = await locusApi.isLocusMapInstalled();
    print('✓ Installation check: $isInstalled');
    
    if (!isInstalled) return;
    
    // 2. 获取信息
    final info = await locusApi.getLocusInfo();
    print('✓ Info retrieval: ${info != null}');
    
    // 3. 测试简单点显示
    final point = LocusPoint(
      name: 'Test',
      latitude: 50.0,
      longitude: 14.0,
    );
    final success = await locusApi.displayPoint(point);
    print('✓ Point display: $success');
    
  } catch (e) {
    print('✗ Test failed: $e');
  }
}
```

## 性能优化

### 1. 避免频繁调用

```dart
// 不好的做法
Timer.periodic(Duration(seconds: 1), (timer) {
  locusApi.isTrackRecording(); // 频繁调用
});

// 好的做法
bool _isRecording = false;
Future<void> updateRecordingStatus() async {
  final isRecording = await locusApi.isTrackRecording();
  if (_isRecording != isRecording) {
    setState(() {
      _isRecording = isRecording;
    });
  }
}
```

### 2. 缓存状态信息

```dart
class LocusStatusManager {
  Map<String, dynamic>? _cachedInfo;
  DateTime? _lastUpdate;
  
  Future<Map<String, dynamic>?> getLocusInfo() async {
    final now = DateTime.now();
    if (_cachedInfo == null || 
        _lastUpdate == null || 
        now.difference(_lastUpdate!).inMinutes > 5) {
      _cachedInfo = await locusApi.getLocusInfo();
      _lastUpdate = now;
    }
    return _cachedInfo;
  }
}
```

## 最佳实践

### 1. 错误处理

```dart
Future<void> safeLocusOperation() async {
  try {
    // 检查前置条件
    if (!await locusApi.isLocusMapInstalled()) {
      throw Exception('Locus Map not installed');
    }
    
    // 执行操作
    final success = await locusApi.displayPoint(point);
    
    if (!success) {
      throw Exception('Operation failed');
    }
    
    // 成功处理
    showSuccessMessage();
    
  } on PlatformException catch (e) {
    // 处理平台异常
    showErrorMessage('Platform error: ${e.message}');
  } catch (e) {
    // 处理其他异常
    showErrorMessage('Error: $e');
  }
}
```

### 2. 用户体验

```dart
Future<void> displayPointWithFeedback(LocusPoint point) async {
  // 显示加载指示器
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: CircularProgressIndicator(),
    ),
  );
  
  try {
    final success = await locusApi.displayPoint(point);
    Navigator.pop(context); // 关闭加载指示器
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Point sent to Locus Map')),
      );
    } else {
      throw Exception('Failed to send point');
    }
  } catch (e) {
    Navigator.pop(context); // 关闭加载指示器
    showErrorDialog(e.toString());
  }
}
```

## 联系支持

如果遇到本文档未涵盖的问题：

1. 检查 [Locus API 官方文档](https://docs.locusmap.eu/)
2. 查看项目的 GitHub Issues
3. 提供详细的错误信息和复现步骤