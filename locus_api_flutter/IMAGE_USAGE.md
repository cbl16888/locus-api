# 图片路径支持使用说明

## 概述

现在 `displayPoint` 方法支持传入图片路径作为点位的自定义图标。PackPoints 的 bitmap 属性将使用指定路径的图片。

## 使用方法

### 单个点位
```dart
await _locusApiFlutterPlugin.displayPoint(
  point, 
  imagePath: 'your_image_path_here'
);
```

### 多个点位
```dart
await _locusApiFlutterPlugin.displayPoints(
  points, 
  imagePath: 'your_image_path_here'
);
```

### 轨迹更新
```dart
await _locusApiFlutterPlugin.updateTrack(
  track, 
  imagePath: 'your_image_path_here'
);

await _locusApiFlutterPlugin.updateTracks(
  tracks, 
  imagePath: 'your_image_path_here'
);
```

## 支持的图片路径格式

### 1. Flutter Assets 路径
```dart
// 使用 flutter_assets/ 前缀
imagePath: 'flutter_assets/images/custom_marker.png'
```

### 2. 绝对文件路径
```dart
// 直接使用绝对路径
imagePath: '/storage/emulated/0/Download/marker.png'
```

### 3. 相对路径
```dart
// 相对于应用文件目录的路径
imagePath: 'markers/custom_icon.png'
```

### 4. Assets 路径（无前缀）
```dart
// 直接从 assets 加载
imagePath: 'images/marker.png'
```

## 实现原理

### Android 端实现

1. **图片缓存机制**:
   - 使用 `bitmapCache` Map 缓存已加载的图片
   - 避免重复加载相同路径的图片，提高性能
   - 自动管理内存，减少重复的文件I/O操作

2. **图片加载方法** (`loadImageFromPath`):
   - 先检查缓存，如果存在直接返回
   - 支持多种路径格式的图片加载
   - 自动处理 Flutter assets 路径
   - 支持绝对路径和相对路径
   - 成功加载后自动加入缓存
   - 错误处理和容错机制

3. **PackPoints 和 Track 集成**:
   - 将加载的 Bitmap 设置到 PackPoints.bitmap 属性
   - 为轨迹样式设置自定义图标 (`setIconStyle`)
   - 与现有的点位和轨迹显示功能完全兼容

### Flutter 端更新

1. **方法签名更新**:
   - `displayPoint` 方法添加可选的 `imagePath` 参数
   - `displayPoints` 方法添加可选的 `imagePath` 参数
   - `updateTrack` 方法添加可选的 `imagePath` 参数
   - `updateTracks` 方法添加可选的 `imagePath` 参数
   - 保持向后兼容性

2. **平台接口更新**:
   - 所有相关接口文件都已更新
   - 支持图片路径参数传递
   - 统一的参数处理机制

## 使用示例

```dart
// 基本使用
final point = LocusPoint(
  name: 'Custom Point',
  latitude: 24.485408,
  longitude: 118.164626,
  description: 'Point with custom icon',
);

// 使用 assets 中的图片
await _locusApiFlutterPlugin.displayPoint(
  point, 
  imagePath: 'flutter_assets/images/red_marker.png'
);

// 使用文件系统中的图片
await _locusApiFlutterPlugin.displayPoint(
  point, 
  imagePath: '/sdcard/Pictures/blue_marker.png'
);
```

## 注意事项

1. **图片格式**: 支持常见的图片格式（PNG, JPG, JPEG 等）
2. **图片大小**: 建议使用适当大小的图片以获得最佳显示效果
3. **权限**: 访问外部存储的图片可能需要相应的权限
4. **错误处理**: 如果图片加载失败，将使用默认的点位图标
5. **性能优化**: 
   - 内置缓存机制，相同路径的图片只加载一次
   - 大图片可能影响性能，建议使用优化过的小图标
   - 缓存会在应用生命周期内保持，减少重复加载
6. **支持的方法**: 
   - `displayPoint` - 单个点位显示
   - `displayPoints` - 多个点位显示
   - `updateTrack` - 单个轨迹更新
   - `updateTracks` - 多个轨迹更新

## 错误处理

如果图片路径无效或图片加载失败，系统会：
1. 记录错误信息
2. 使用默认的点位图标
3. 正常显示点位（不会因为图片问题导致点位显示失败）