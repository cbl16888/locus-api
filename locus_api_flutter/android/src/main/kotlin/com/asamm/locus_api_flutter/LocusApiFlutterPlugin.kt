package com.asamm.locus_api_flutter

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import locus.api.android.ActionBasics
import locus.api.android.ActionDisplayPoints
import locus.api.android.ActionDisplayTracks
import locus.api.android.ActionDisplayVarious
import locus.api.android.objects.LocusVersion
import locus.api.android.objects.PackPoints
import locus.api.android.utils.LocusConst
import locus.api.android.utils.LocusUtils
import locus.api.objects.extra.Location
import locus.api.objects.geoData.Point
import locus.api.objects.geoData.Track
import locus.api.objects.geoData.Circle
import locus.api.objects.styles.GeoDataStyle
import locus.api.objects.Storable
import android.graphics.Color
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import java.io.File
import java.io.FileInputStream
import java.io.InputStream


/** LocusApiFlutterPlugin */
class LocusApiFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private var activity: Activity? = null
  
  // Bitmap缓存，避免重复加载相同路径的图片
  private val bitmapCache = mutableMapOf<String, Bitmap>()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "locus_api_flutter")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    try {
      when (call.method) {
        "isLocusMapInstalled" -> {
          val isInstalled = LocusUtils.isLocusAvailable(context)
          result.success(isInstalled)
        }
        
        "getLocusInfo" -> {
          val locusVersion = LocusUtils.getActiveVersion(context)
          if (locusVersion != null) {
            val locusInfo = ActionBasics.getLocusInfo(context, locusVersion)
            if (locusInfo != null) {
              val infoMap = mapOf(
                "isInstalled" to true,
                "isRunning" to locusInfo.isRunning,
                "packageName" to locusInfo.packageName
              )
              result.success(infoMap)
            } else {
              result.success(mapOf("isInstalled" to false))
            }
          } else {
            result.success(mapOf("isInstalled" to false))
          }
        }
        
        "displayPoint" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val name = call.argument<String>("name") ?: ""
          val latitude = call.argument<Double>("latitude") ?: 0.0
          val longitude = call.argument<Double>("longitude") ?: 0.0
          val imagePath = call.argument<String>("imagePath")
          
          val point = Point(name, Location(latitude, longitude))
          val packPoints = PackPoints(name)
          
          // 如果提供了图片路径，加载图片并设置为bitmap
          if (imagePath != null && imagePath.isNotEmpty()) {
            val bitmap = loadImageFromPath(imagePath)
            if (bitmap != null) {
              packPoints.bitmap = bitmap
            }
          }
          
          packPoints.addPoint(point)
          
          val success = ActionDisplayPoints.sendPack(currentActivity, packPoints, ActionDisplayVarious.ExtraAction.NONE)
          result.success(success)
        }
        
        "displayPoints" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val pointsList = call.argument<List<Map<String, Any>>>("points") ?: emptyList()
          if (pointsList.isEmpty()) {
            result.success(true)
            return
          }
          
          val imagePath = call.argument<String>("imagePath")
          val packPoints = PackPoints("Multiple Points")
          
          // 如果提供了图片路径，加载图片并设置为bitmap
          if (imagePath != null && imagePath.isNotEmpty()) {
            val bitmap = loadImageFromPath(imagePath)
            if (bitmap != null) {
              packPoints.bitmap = bitmap
            }
          }
          
          for (pointMap in pointsList) {
            val name = pointMap["name"] as? String ?: ""
            val latitude = pointMap["latitude"] as? Double ?: 0.0
            val longitude = pointMap["longitude"] as? Double ?: 0.0
            
            val point = Point(name, Location(latitude, longitude))
            packPoints.addPoint(point)
          }
          
          val success = ActionDisplayPoints.sendPack(currentActivity, packPoints, ActionDisplayVarious.ExtraAction.NONE)
          result.success(success)
        }
        
        "startNavigation" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val name = call.argument<String>("name") ?: ""
          val latitude = call.argument<Double>("latitude") ?: 0.0
          val longitude = call.argument<Double>("longitude") ?: 0.0
          
          val point = Point(name, Location(latitude, longitude))
          val packPoints = PackPoints("Navigation")
          packPoints.addPoint(point)
          
          // 使用显示点的方式来实现导航功能
          val success = ActionDisplayPoints.sendPack(currentActivity, packPoints, ActionDisplayVarious.ExtraAction.CENTER)
          result.success(success)
        }
        
        "updatePoint" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val name = call.argument<String>("name") ?: ""
          val latitude = call.argument<Double>("latitude") ?: 0.0
          val longitude = call.argument<Double>("longitude") ?: 0.0
          val imagePath = call.argument<String>("icon")

          val point = Point(name, Location(latitude, longitude))
          val packPoints = PackPoints("RealTime_$name")
          // 如果提供了图片路径，加载图片并设置为bitmap
          if (imagePath != null && imagePath.isNotEmpty()) {
            val bitmap = loadImageFromPath(imagePath)
            if (bitmap != null) {
              packPoints.bitmap = bitmap
            }
          }
          packPoints.addPoint(point)
          
          // 实时更新点位，不居中显示
          val success = ActionDisplayPoints.sendPack(currentActivity, packPoints, ActionDisplayVarious.ExtraAction.NONE)
          result.success(success)
        }
        
        "updatePoints" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val pointsList = call.argument<List<Map<String, Any>>>("points") ?: emptyList()
          if (pointsList.isEmpty()) {
            result.success(true)
            return
          }

          try {
            val locusVersion = LocusUtils.getActiveVersion(context)
            if (locusVersion != null) {
              // 按图标路径分组点位，相同图标的点位放在同一个PackPoints中
              val pointsByIcon = mutableMapOf<String?, MutableList<Map<String, Any>>>()
              
              for (pointMap in pointsList) {
                val iconPath = pointMap["icon"] as? String
                val key = iconPath ?: "default" // 没有图标的点位使用"default"键
                pointsByIcon.getOrPut(key) { mutableListOf() }.add(pointMap)
              }
              
              var allSuccess = true
              
              // 为每组相同图标的点位创建单独的PackPoints
              pointsByIcon.forEach { (iconPath, points) ->
                val packName = if (iconPath == "default") "RealTime_Updates_Default" else "RealTime_Updates_${iconPath.hashCode()}"
                val packPoints = PackPoints(packName)
                
                // 如果有图标路径，为这个包设置图标
                if (iconPath != null && iconPath != "default" && iconPath.isNotEmpty()) {
                  val bitmap = loadImageFromPath(iconPath)
                  if (bitmap != null) {
                    packPoints.bitmap = bitmap
                  }
                }
                
                // 添加所有使用相同图标的点位
                for (pointMap in points) {
                  val name = pointMap["name"] as? String ?: ""
                  val latitude = pointMap["latitude"] as? Double ?: 0.0
                  val longitude = pointMap["longitude"] as? Double ?: 0.0
                  
                  val point = Point(name, Location(latitude, longitude))
                  packPoints.addPoint(point)
                }
                
                // 发送这个包
                val success = ActionDisplayPoints.sendPackSilent(currentActivity, packPoints, false)
                if (!success) {
                  allSuccess = false
                }
              }
              
              result.success(allSuccess)
            } else {
              result.success(false)
            }
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }
        
        "clearPoints" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          try {
            // 清除所有相关的点位包
            ActionDisplayPoints.removePackFromLocus(currentActivity, "Multiple Points")
            ActionDisplayPoints.removePackFromLocus(currentActivity, "RealTime_Batch")
            ActionDisplayPoints.removePackFromLocus(currentActivity, "RealTime_Updates")
            
            // 清除每个车辆的单独点位包
            val vehicleNames = listOf("车辆1", "车辆2", "车辆3")
            for (vehicleName in vehicleNames) {
              ActionDisplayPoints.removePackFromLocus(currentActivity, "RealTime_$vehicleName")
            }
            
            result.success(true)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }
        
        "clearPointsWithName" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val packName = call.argument<String>("packName") ?: ""
          if (packName.isEmpty()) {
            result.error("INVALID_ARGUMENTS", "Pack name is required", null)
            return
          }
          
          try {
            ActionDisplayPoints.removePackFromLocus(currentActivity, packName)
            result.success(true)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }
        
        "startTrackRecording" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val locusVersion = LocusUtils.getActiveVersion(context)
          if (locusVersion != null) {
            val success = ActionBasics.actionTrackRecordStart(currentActivity, locusVersion)
            result.success(success)
          } else {
            result.success(false)
          }
        }
        
        "stopTrackRecording" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val locusVersion = LocusUtils.getActiveVersion(context)
          if (locusVersion != null) {
            val success = ActionBasics.actionTrackRecordStop(currentActivity, locusVersion, true)
            result.success(success)
          } else {
            result.success(false)
          }
        }
        
        "pauseTrackRecording" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val locusVersion = LocusUtils.getActiveVersion(context)
          if (locusVersion != null) {
            val success = ActionBasics.actionTrackRecordPause(currentActivity, locusVersion)
            result.success(success)
          } else {
            result.success(false)
          }
        }
        
        "resumeTrackRecording" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val locusVersion = LocusUtils.getActiveVersion(context)
          if (locusVersion != null) {
            val success = ActionBasics.actionTrackRecordStart(currentActivity, locusVersion)
            result.success(success)
          } else {
            result.success(false)
          }
        }
        
        "isTrackRecording" -> {
          // 简化实现，返回 false
          result.success(false)
        }
        
        "displayTrack" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val trackMap = call.argument<Map<String, Any>>("track")
          if (trackMap == null) {
            result.error("INVALID_ARGUMENTS", "Track data is required", null)
            return
          }
          
          try {
            val track = createTrackFromMap(trackMap)
            val success = ActionDisplayTracks.sendTrack(currentActivity, track, ActionDisplayVarious.ExtraAction.NONE)
            result.success(success)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }
        
        "displayTracks" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val tracksList = call.argument<List<Map<String, Any>>>("tracks") ?: emptyList()
          if (tracksList.isEmpty()) {
            result.success(true)
            return
          }
          
          try {
            val tracks = tracksList.map { createTrackFromMap(it) }
            val success = ActionDisplayTracks.sendTracks(currentActivity, tracks, ActionDisplayVarious.ExtraAction.NONE)
            result.success(success)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }
        
        "updateTrack" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val trackMap = call.argument<Map<String, Any>>("track")
          if (trackMap == null) {
            result.error("INVALID_ARGUMENTS", "Track data is required", null)
            return
          }

          try {
            val track = createTrackFromMap(trackMap)
            val success = ActionDisplayTracks.sendTrackSilent(currentActivity, track, false)
            result.success(success)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }
        
        "updateTracks" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val tracksList = call.argument<List<Map<String, Any>>>("tracks") ?: emptyList()
          if (tracksList.isEmpty()) {
            result.success(true)
            return
          }

          try {
            val tracks = tracksList.map { trackMap -> 
              createTrackFromMap(trackMap)
            }
            val success = ActionDisplayTracks.sendTracksSilent(currentActivity, tracks, false)
            result.success(success)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }
        
        "clearTracks" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          try {
            // Locus API轨迹清除的正确方法：发送空的轨迹数据
            // 由于API验证会拒绝空轨迹，我们直接使用Intent机制
            val locusVersion = LocusUtils.getActiveVersion(context)
            if (locusVersion != null) {
              val intent = Intent(LocusConst.ACTION_DISPLAY_DATA_SILENTLY)
              intent.setPackage(locusVersion.packageName)
              
              // 发送空的轨迹数据来清除所有轨迹
              val emptyTracks = emptyList<Track>()
              intent.putExtra(LocusConst.INTENT_EXTRA_TRACKS_MULTI, bytesForTracks(emptyTracks))
              intent.putExtra(LocusConst.INTENT_EXTRA_CENTER_ON_DATA, false)
              
              // 发送广播来清除轨迹
              LocusUtils.sendBroadcast(currentActivity, intent, locusVersion)
              result.success(true)
            } else {
              result.success(false)
            }
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }
        
        "clearTrackByName" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          
          val trackName = call.argument<String>("trackName") ?: ""
          if (trackName.isEmpty()) {
            result.error("INVALID_ARGUMENTS", "Track name is required", null)
            return
          }
          
          try {
            // 对于单个轨迹清除，我们使用清除所有轨迹的方法
            // 因为Locus API没有提供清除单个轨迹的可靠方法
            val locusVersion = LocusUtils.getActiveVersion(context)
            if (locusVersion != null) {
              val intent = Intent(LocusConst.ACTION_DISPLAY_DATA_SILENTLY)
              intent.setPackage(locusVersion.packageName)
              
              // 发送空的轨迹数据来清除所有轨迹
              val emptyTracks = emptyList<Track>()
              intent.putExtra(LocusConst.INTENT_EXTRA_TRACKS_MULTI, bytesForTracks(emptyTracks))
              intent.putExtra(LocusConst.INTENT_EXTRA_CENTER_ON_DATA, false)
              
              // 发送广播来清除轨迹
              LocusUtils.sendBroadcast(currentActivity, intent, locusVersion)
              result.success(true)
            } else {
              result.success(false)
            }
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }
        
        "openLocusMap" -> {
          val success = LocusUtils.callStartLocusMap(context)
          result.success(success)
        }
        
        "getActiveVersionInfo" -> {
          val lv = LocusUtils.getActiveVersion(context)
          if (lv != null) {
            val info = mapOf(
              "packageName" to lv.packageName,
              "versionName" to lv.versionName,
              "versionCode" to lv.versionCode
            )
            result.success(info)
          } else {
            result.success(null)
          }
        }

        "openPointDetailById" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          val itemId = (call.argument<Number>("itemId") ?: -1L).toLong()
          if (itemId <= 0) {
            result.error("INVALID_ARGUMENTS", "itemId is required > 0", null)
            return
          }
          try {
            val intent = Intent(LocusConst.ACTION_DISPLAY_POINT_SCREEN)
            intent.putExtra(LocusConst.INTENT_EXTRA_ITEM_ID, itemId)
            currentActivity.startActivity(intent)
            result.success(true)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        "startNavigationById" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          val itemId = (call.argument<Number>("itemId") ?: -1L).toLong()
          if (itemId <= 0) {
            result.error("INVALID_ARGUMENTS", "itemId is required > 0", null)
            return
          }
          try {
            val intent = Intent(LocusConst.ACTION_NAVIGATION_START)
            intent.putExtra(LocusConst.INTENT_EXTRA_ITEM_ID, itemId)
            currentActivity.startActivity(intent)
            result.success(true)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        "startGuidingById" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          val itemId = (call.argument<Number>("itemId") ?: -1L).toLong()
          if (itemId <= 0) {
            result.error("INVALID_ARGUMENTS", "itemId is required > 0", null)
            return
          }
          try {
            val intent = Intent(LocusConst.ACTION_GUIDING_START)
            intent.putExtra(LocusConst.INTENT_EXTRA_ITEM_ID, itemId)
            currentActivity.startActivity(intent)
            result.success(true)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        "openAddress" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          val address = call.argument<String>("address") ?: ""
          if (address.isBlank()) {
            result.error("INVALID_ARGUMENTS", "address is required", null)
            return
          }
          try {
            val intent = Intent(LocusConst.ACTION_NAVIGATION_START)
            intent.putExtra(LocusConst.INTENT_EXTRA_ADDRESS_TEXT, address)
            currentActivity.startActivity(intent)
            result.success(true)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        "navigateTo" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          val name = call.argument<String>("name")
          val latitude = call.argument<Double>("latitude") ?: 0.0
          val longitude = call.argument<Double>("longitude") ?: 0.0
          try {
            val intent = Intent(LocusConst.ACTION_NAVIGATION_START)
            name?.takeIf { it.isNotBlank() }?.let {
              intent.putExtra(LocusConst.INTENT_EXTRA_NAME, it)
            }
            intent.putExtra(LocusConst.INTENT_EXTRA_LATITUDE, latitude)
            intent.putExtra(LocusConst.INTENT_EXTRA_LONGITUDE, longitude)
            currentActivity.startActivity(intent)
            result.success(true)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        "addNewWmsMap" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          val url = call.argument<String>("url") ?: ""
          if (url.isBlank()) {
            result.error("INVALID_ARGUMENTS", "url is required", null)
            return
          }
          try {
            val intent = Intent(LocusConst.ACTION_ADD_NEW_WMS_MAP)
            intent.putExtra(LocusConst.INTENT_EXTRA_ADD_NEW_WMS_MAP_URL, url)
            currentActivity.startActivity(intent)
            result.success(true)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        // Import points from file URI
        "importPointsFromFile" -> {
          val fileUriStr = call.argument<String>("fileUri") ?: ""
          val centerOnData = call.argument<Boolean>("centerOnData") ?: true
          if (fileUriStr.isBlank()) {
            result.error("INVALID_ARGUMENTS", "fileUri is required", null)
            return
          }
          try {
            val lv = LocusUtils.getActiveVersion(context)
            if (lv == null) { result.success(false); return }
            val uri = Uri.parse(fileUriStr)
            val intent = Intent(LocusConst.ACTION_DISPLAY_DATA).apply {
              setPackage(lv.packageName)
              addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
              putExtra(LocusConst.INTENT_EXTRA_POINTS_FILE_URI, uri)
              putExtra(LocusConst.INTENT_EXTRA_CALL_IMPORT, true)
              putExtra(LocusConst.INTENT_EXTRA_CENTER_ON_DATA, centerOnData)
            }
            LocusUtils.sendBroadcast(context, intent, lv)
            result.success(true)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        // Import tracks from file URI
        "importTracksFromFile" -> {
          val currentActivity = activity ?: run {
            result.error("NO_ACTIVITY", "No activity available", null); return
          }
          val fileUriStr = call.argument<String>("fileUri") ?: ""
          val centerOnData = call.argument<Boolean>("centerOnData") ?: true
          if (fileUriStr.isBlank()) {
            result.error("INVALID_ARGUMENTS", "fileUri is required", null)
            return
          }
          try {
            val lv = LocusUtils.getActiveVersion(context)
            if (lv == null) { result.success(false); return }
            val uri = Uri.parse(fileUriStr)
            val intent = Intent(LocusConst.ACTION_DISPLAY_DATA).apply {
              setPackage(lv.packageName)
              addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
              putExtra(LocusConst.INTENT_EXTRA_TRACKS_FILE_URI, uri)
              putExtra(LocusConst.INTENT_EXTRA_CALL_IMPORT, true)
              putExtra(LocusConst.INTENT_EXTRA_CENTER_ON_DATA, centerOnData)
            }
            LocusUtils.sendBroadcast(currentActivity, intent, lv)
            result.success(true)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        // View file in Locus (no import), relies on mimeType if provided
        "viewFileInLocus" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          val fileUriStr = call.argument<String>("fileUri") ?: ""
          val mimeType = call.argument<String>("mimeType")
          if (fileUriStr.isBlank()) {
            result.error("INVALID_ARGUMENTS", "fileUri is required", null)
            return
          }
          try {
            val lv = LocusUtils.getActiveVersion(context)
            if (lv == null) { result.success(false); return }
            val uri = Uri.parse(fileUriStr)
            val intent = Intent(Intent.ACTION_VIEW).apply {
              setPackage(lv.packageName)
              addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
              if (mimeType.isNullOrBlank()) setData(uri) else setDataAndType(uri, mimeType)
            }
            currentActivity.startActivity(intent)
            result.success(true)
          } catch (e: Exception) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

                // Display circles on map
        "displayCircles" -> {
          val circlesArg = call.argument<List<Map<String, Any>>>("circles") ?: emptyList()
          val centerOnData = call.argument<Boolean>("centerOnData") ?: false
          try {
            val lv = LocusUtils.getActiveVersion(context)
            if (lv == null) { result.success(false); return }
            val circlesPacked = circlesArg.map { map ->
              val name = map["name"] as? String ?: ""
              val latitude = (map["latitude"] as? Number)?.toDouble() ?: 0.0
              val longitude = (map["longitude"] as? Number)?.toDouble() ?: 0.0
              val radius = (map["radius"] as? Number)?.toDouble() ?: 0.0
              Circle(Location(latitude, longitude), radius.toFloat(), false).apply {
                this.name = name
              }
            }

            val intent = Intent(LocusConst.ACTION_DISPLAY_DATA_SILENTLY).apply {
              setPackage(lv.packageName)
              putExtra(LocusConst.INTENT_EXTRA_CIRCLES_MULTI, serializeStorable(circlesPacked))
              putExtra(LocusConst.INTENT_EXTRA_CENTER_ON_DATA, centerOnData)
            }
            LocusUtils.sendBroadcast(context, intent, lv)
            result.success(true)
          } catch (e: Throwable) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        // Remove circles by ids, or clear all if ids empty (best-effort)
        "removeCirclesByIds" -> {
          try {
            val lv = LocusUtils.getActiveVersion(context)
            if (lv == null) { result.success(false); return }
            // 当前未提供基于 ID 的删除 Extra，这里采用清空策略（与 clearTracks 一致）
            val intent = Intent(LocusConst.ACTION_DISPLAY_DATA_SILENTLY).apply {
              setPackage(lv.packageName)
              putExtra(LocusConst.INTENT_EXTRA_CIRCLES_MULTI, serializeStorable(emptyList()))
              putExtra(LocusConst.INTENT_EXTRA_CENTER_ON_DATA, false)
            }
            LocusUtils.sendBroadcast(context, intent, lv)
            result.success(true)
          } catch (e: Throwable) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        // Open Field Notes list, optionally start create log
        "openFieldNotes" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          val createLog = call.argument<Boolean>("createLog") ?: false
          try {
            val intent = Intent(LocusConst.ACTION_LOG_FIELD_NOTES).apply {
              putExtra(LocusConst.INTENT_EXTRA_FIELD_NOTES_CREATE_LOG, createLog)
            }
            currentActivity.startActivity(intent)
            result.success(true)
          } catch (e: Throwable) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        // Log Field Notes by ids
        "logFieldNotes" -> {
          val currentActivity = activity
          if (currentActivity == null) {
            result.error("NO_ACTIVITY", "No activity available", null)
            return
          }
          val ids = call.argument<List<Long>>("ids") ?: emptyList()
          val createLog = call.argument<Boolean>("createLog") ?: true
          if (ids.isEmpty()) {
            result.error("INVALID_ARGUMENTS", "ids is required", null)
            return
          }
          try {
            val intent = Intent(LocusConst.ACTION_LOG_FIELD_NOTES).apply {
              putExtra(LocusConst.INTENT_EXTRA_FIELD_NOTES_IDS, ids.toLongArray())
              putExtra(LocusConst.INTENT_EXTRA_FIELD_NOTES_CREATE_LOG, createLog)
            }
            currentActivity.startActivity(intent)
            result.success(true)
          } catch (e: Throwable) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        // Clear all circles explicitly
        "clearCircles" -> {
          try {
            val lv = LocusUtils.getActiveVersion(context)
            if (lv == null) { result.success(false); return }
            val intent = Intent(LocusConst.ACTION_DISPLAY_DATA_SILENTLY).apply {
              setPackage(lv.packageName)
              putExtra(LocusConst.INTENT_EXTRA_CIRCLES_MULTI, serializeStorable(emptyList()))
              putExtra(LocusConst.INTENT_EXTRA_CENTER_ON_DATA, false)
            }
            LocusUtils.sendBroadcast(context, intent, lv)
            result.success(true)
          } catch (e: Throwable) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        // Display polylines (basic via Track)
        "displayPolylines" -> {
          val linesArg = call.argument<List<Map<String, Any>>>("polylines") ?: emptyList()
          val centerOnData = call.argument<Boolean>("centerOnData") ?: false
          try {
            val tracks = linesArg.map { line ->
              val name = line["name"] as? String ?: ""
              val colorHex = line["color"] as? String
              val width = (line["width"] as? Number)?.toFloat()
              val pts = (line["points"] as? List<Map<String, Any>>)?.map { p ->
                val la = (p["latitude"] as? Number)?.toDouble() ?: 0.0
                val lo = (p["longitude"] as? Number)?.toDouble() ?: 0.0
                Location(la, lo)
              } ?: emptyList()
              Track().apply {
                this.name = name
                if (colorHex != null || width != null) {
                  val style = GeoDataStyle()
                  val color = try { if (colorHex != null) Color.parseColor(colorHex) else Color.RED } catch (_: Throwable) { Color.RED }
                  val w = width ?: 5f
                  style.setLineStyle(color, w)
                  this.styleNormal = style
                }
                this.points.addAll(pts)
              }
            }
            val act = activity ?: (context as? Activity)
            if (act == null) {
              result.success(false)
              return
            }
            val ok = ActionDisplayTracks.sendTracks(
              act,
              tracks,
              if (centerOnData) ActionDisplayVarious.ExtraAction.CENTER else ActionDisplayVarious.ExtraAction.NONE
            )
            result.success(ok)
          } catch (e: Throwable) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        // Display polygons (best-effort via closed Track)
        "displayPolygons" -> {
          val polysArg = call.argument<List<Map<String, Any>>>("polygons") ?: emptyList()
          val centerOnData = call.argument<Boolean>("centerOnData") ?: false
          try {
            val tracks = polysArg.map { poly ->
              val name = poly["name"] as? String ?: ""
              val colorHex = poly["strokeColor"] as? String
              val width = (poly["strokeWidth"] as? Number)?.toFloat()
              val pts = (poly["points"] as? List<Map<String, Any>>)?.map { p ->
                val la = (p["latitude"] as? Number)?.toDouble() ?: 0.0
                val lo = (p["longitude"] as? Number)?.toDouble() ?: 0.0
                Location(la, lo)
              } ?: emptyList()
              val closed = if (pts.size >= 2) {
                val first = pts.first()
                val last = pts.last()
                if (first.latitude != last.latitude || first.longitude != last.longitude) pts + first else pts
              } else pts
              Track().apply {
                this.name = name
                if (colorHex != null || width != null) {
                  val style = GeoDataStyle()
                  val color = try { if (colorHex != null) Color.parseColor(colorHex) else Color.RED } catch (_: Throwable) { Color.RED }
                  val w = width ?: 5f
                  style.setLineStyle(color, w)
                  this.styleNormal = style
                }
                this.points.addAll(closed)
              }
            }
            val act = activity ?: (context as? Activity)
            if (act == null) {
              result.success(false)
              return
            }
            val ok = ActionDisplayTracks.sendTracks(
              act,
              tracks,
              if (centerOnData) ActionDisplayVarious.ExtraAction.CENTER else ActionDisplayVarious.ExtraAction.NONE
            )
            result.success(ok)
          } catch (e: Throwable) {
            result.error("LOCUS_API_ERROR", e.message, null)
          }
        }

        else -> {
          result.notImplemented()
        }
      }
    } catch (e: Exception) {
      result.error("LOCUS_API_ERROR", e.message, null)
    }
  }

  private fun loadImageFromPath(imagePath: String): Bitmap? {
    // 先检查缓存
    bitmapCache[imagePath]?.let { return it }
    
    return try {
      val bitmap = when {
        // 处理assets路径 (flutter_assets/...)
        imagePath.startsWith("assets/") -> {
          val assetPath = "flutter_assets/$imagePath"
          val inputStream = context.assets.open(assetPath)
          BitmapFactory.decodeStream(inputStream)
        }
        // 处理绝对路径
        imagePath.startsWith("/") -> {
          val file = File(imagePath)
          if (file.exists()) {
            BitmapFactory.decodeFile(imagePath)
          } else {
            null
          }
        }
        // 处理相对路径，假设在应用的文件目录中
        else -> {
          val file = File(context.filesDir, imagePath)
          if (file.exists()) {
            BitmapFactory.decodeFile(file.absolutePath)
          } else {
            // 尝试从assets加载
            try {
              val inputStream = context.assets.open(imagePath)
              BitmapFactory.decodeStream(inputStream)
            } catch (e: Exception) {
              null
            }
          }
        }
      }
      
      // 将成功加载的bitmap加入缓存
      bitmap?.let { bitmapCache[imagePath] = it }
      bitmap
    } catch (e: Exception) {
      null
    }
  }

  private fun createTrackFromMap(trackMap: Map<String, Any>): Track {
    val name = trackMap["name"] as? String ?: ""
    val pointsList = trackMap["points"] as? List<Map<String, Any>> ?: emptyList()
    val colorHex = trackMap["color"] as? String
    val width = trackMap["width"] as? Double
    
    val track = Track()
    track.name = name
    
    // 设置轨迹样式
    if (colorHex != null || width != null) {
      val style = GeoDataStyle()
      
      // 解析颜色和宽度
      var color = Color.RED // 默认红色
      var lineWidth = 5.0f // 默认线宽
      
      if (colorHex != null && colorHex.isNotEmpty()) {
        try {
          color = Color.parseColor(colorHex)
        } catch (e: Exception) {
          // 如果颜色解析失败，使用默认红色
          color = Color.RED
        }
      }
      
      if (width != null && width > 0) {
        lineWidth = width.toFloat()
      }
      
      // 使用正确的 Locus API 方法设置线条样式
      style.setLineStyle(color, lineWidth)
      track.styleNormal = style
    }
    
    // 添加轨迹点到Track的points列表
    for (pointMap in pointsList) {
      val latitude = pointMap["latitude"] as? Double ?: 0.0
      val longitude = pointMap["longitude"] as? Double ?: 0.0
      val altitude = pointMap["altitude"] as? Double
      val timestamp = pointMap["timestamp"] as? Long
      val speed = pointMap["speed"] as? Double
      
      val location = Location(latitude, longitude)
      if (altitude != null) {
        location.altitude = altitude
      }
      if (timestamp != null) {
        location.time = timestamp
      }
      if (speed != null) {
        location.speed = speed.toFloat()
      }
      
      track.points.add(location)
    }
    
    return track
  }

  private fun bytesForCircles(data: List<Map<String, Any>>): ByteArray? {
    val circles: List<Circle> = data.map { richMap ->
      val name = richMap["name"] as? String ?: ""
      val latitude = (richMap["latitude"] as? Number)?.toDouble() ?: 0.0
      val longitude = (richMap["longitude"] as? Number)?.toDouble() ?: 0.0
      val radius = (richMap["radius"] as? Number)?.toDouble() ?: 0.0
      Circle(Location(latitude, longitude), radius.toFloat(), false).apply {
        this.name = name
      }
    }
    return serializeStorable(circles)
  }

  private fun bytesForTracks(tracks: List<Track>): ByteArray? {
    return serializeStorable(tracks)
  }

  private fun serializeStorable(items: List<out Storable>): ByteArray? {
    return try {
      @Suppress("UNCHECKED_CAST")
      Storable.getAsBytes(items as List<Storable>)
    } catch (_: Throwable) {
      null
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}