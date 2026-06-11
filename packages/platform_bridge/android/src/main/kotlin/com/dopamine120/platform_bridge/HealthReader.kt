package com.dopamine120.platform_bridge

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.HeartRateVariabilityRmssdRecord
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.RestingHeartRateRecord
import androidx.health.connect.client.records.SleepSessionRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import java.time.Instant
import kotlin.reflect.KClass

/** Reads the bridge's health metrics from Health Connect. */
class HealthReader(private val context: Context) {

    companion object {
        /** Metric name -> record type; metrics absent here are unsupported
         *  on Android (daylightMinutes, mindfulMinutes) and read as null. */
        val recordTypes: Map<String, KClass<out Record>> = mapOf(
            "sleep" to SleepSessionRecord::class,
            "restingHeartRate" to RestingHeartRateRecord::class,
            "hrv" to HeartRateVariabilityRmssdRecord::class,
            "steps" to StepsRecord::class,
        )

        fun permissionsFor(metrics: List<String>): Set<String> =
            metrics.mapNotNull { recordTypes[it] }
                .map { HealthPermission.getReadPermission(it) }
                .toSet()

        fun isAvailable(context: Context): Boolean =
            HealthConnectClient.getSdkStatus(context) ==
                HealthConnectClient.SDK_AVAILABLE
    }

    suspend fun read(
        metrics: List<String>,
        start: Instant,
        end: Instant,
    ): Map<String, Double?> {
        val client = HealthConnectClient.getOrCreate(context)
        val granted = client.permissionController.getGrantedPermissions()
        val filter = TimeRangeFilter.between(start, end)

        suspend fun <T : Record> records(type: KClass<T>): List<T>? {
            if (HealthPermission.getReadPermission(type) !in granted) return null
            return client.readRecords(ReadRecordsRequest(type, filter)).records
        }

        return metrics.associateWith { metric ->
            when (metric) {
                "sleep" -> records(SleepSessionRecord::class)
                    ?.sumOf { (it.endTime.epochSecond - it.startTime.epochSecond) / 60.0 }
                    ?.takeIf { it > 0 }
                "restingHeartRate" -> records(RestingHeartRateRecord::class)
                    ?.map { it.beatsPerMinute.toDouble() }
                    ?.takeIf { it.isNotEmpty() }?.average()
                // Health Connect exposes RMSSD, not SDNN; close enough for
                // a single "hrv (ms)" metric.
                "hrv" -> records(HeartRateVariabilityRmssdRecord::class)
                    ?.map { it.heartRateVariabilityMillis }
                    ?.takeIf { it.isNotEmpty() }?.average()
                "steps" -> records(StepsRecord::class)
                    ?.sumOf { it.count.toDouble() }
                    ?.takeIf { it > 0 }
                else -> null // unsupported on Android
            }
        }
    }
}
