package com.example.flokk_src

import io.flutter.embedding.android.FlutterActivity

import io.flutter.plugin.common.MethodChannel
import com.microsoft.device.display.DisplayMask
import android.hardware.Sensor
import android.hardware.SensorManager
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "duosdk.microsoft.dev"

    private val HINGE_ANGLE_SENSOR_NAME = "Hinge Angle"
    private var mSensorsSetup : Boolean = false
    private var mSensorManager: SensorManager? = null
    private var mHingeAngleSensor: Sensor? = null
    private var mSensorListener: SensorEventListener? = null
    private var mCurrentHingeAngle: Float = 0.0f

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        //super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine);


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,  CHANNEL).setMethodCallHandler { call, result ->
            if (!isDualScreenDevice()) {
                result.success(false)
            } else {
                try {
                    when (call.method) {
                        "isDualScreenDevice" -> {
                            if (isDualScreenDevice()) {
                                result.success(true)
                            } else {
                                result.success(false)
                            }
                        }
                        "isAppSpanned" -> {
                            if (isAppSpanned()) {
                                result.success(true)
                            } else {
                                result.success(false)
                            }
                        }
                        "getHingeAngle" -> {
                            if (!mSensorsSetup) {
                                setupSensors()
                            }
                            result.success(mCurrentHingeAngle)
                        }
                        "getHingeSize" -> {
                            result.success(getHingeSize())
                        }
                        else -> {
                            result.notImplemented()
                        }
                    }
                } catch(e: Exception) {
                    result.success(false)
                }
            }
        }
    }

    fun isDualScreenDevice(): Boolean {
        val feature = "com.microsoft.device.display.displaymask"
        val pm = this.packageManager
        return (pm.hasSystemFeature(feature))
    }

    fun isAppSpanned(): Boolean {
        var displayMask = DisplayMask.fromResourcesRectApproximation(this)
        var boundings = displayMask.getBoundingRects()
        var first = boundings.get(0)
        var rootView = this.getWindow().getDecorView().getRootView()
        var drawingRect = android.graphics.Rect()
        rootView.getDrawingRect(drawingRect)
        return  (first.intersect(drawingRect))
    }

    private fun setupSensors() {
        mSensorManager = getSystemService(SENSOR_SERVICE) as SensorManager?
        val sensorList: List<Sensor> = mSensorManager!!.getSensorList(Sensor.TYPE_ALL)

        for (sensor in sensorList) {
            if (sensor.getName().contains(HINGE_ANGLE_SENSOR_NAME)) {
                mHingeAngleSensor = sensor
                break
            }
        }

        mSensorListener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                if (event.sensor === mHingeAngleSensor) {
                    mCurrentHingeAngle = event.values.get(0) as Float
                }
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
                //TODO – Add support later
            }
        }
        mSensorManager?.registerListener(mSensorListener, mHingeAngleSensor, SensorManager.SENSOR_DELAY_NORMAL)
        mSensorsSetup = true
    }


    fun getHingeSize(): Int {
        // The size will always be the same,
        // it will either be the height (Double Landscape)
        // or the width (Double portrait)
        val displayMask = DisplayMask.fromResourcesRectApproximation(activity)
        val boundings = displayMask.boundingRects

        if (boundings.isEmpty()) return 0

        val first = boundings[0]
        val density: Float = activity!!.resources.displayMetrics.density
        val height = ((first.right / density) - (first.left / density)).toInt()
        val width = ((first.bottom / density) - (first.top / density)).toInt()

        if (width < height)
        {
            return width
        }else {
            return height
        }
    }
}
