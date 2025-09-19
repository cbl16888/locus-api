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
import locus.api.android.ActionDisplayVarious
import locus.api.android.objects.LocusVersion
import locus.api.android.objects.PackPoints
import locus.api.android.utils.LocusUtils
import locus.api.objects.extra.Location
import locus.api.objects.geoData.Point

/** LocusApiFlutterPlugin */
class LocusApiFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private var activity: Activity? = null

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
          
          val point = Point(name, Location(latitude, longitude))
          val packPoints = PackPoints(name)
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
          
          val packPoints = PackPoints("Multiple Points")
          
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
          
          val point = Point(name, Location(latitude, longitude))
          val packPoints = PackPoints("RealTime_$name")
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
          
          val packPoints = PackPoints("RealTime_Batch")
          
          for (pointMap in pointsList) {
            val name = pointMap["name"] as? String ?: ""
            val latitude = pointMap["latitude"] as? Double ?: 0.0
            val longitude = pointMap["longitude"] as? Double ?: 0.0
            
            val point = Point(name, Location(latitude, longitude))
            packPoints.addPoint(point)
          }
          
          // 批量实时更新点位，不居中显示
          val success = ActionDisplayPoints.sendPack(currentActivity, packPoints, ActionDisplayVarious.ExtraAction.NONE)
          result.success(success)
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
        
        "openLocusMap" -> {
          val success = LocusUtils.callStartLocusMap(context)
          result.success(success)
        }
        
        else -> {
          result.notImplemented()
        }
      }
    } catch (e: Exception) {
      result.error("LOCUS_API_ERROR", e.message, null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}