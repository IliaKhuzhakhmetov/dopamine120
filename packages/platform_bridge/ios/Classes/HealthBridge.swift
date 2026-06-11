import Foundation
import HealthKit

/// HealthKit reads for the bridge's metrics. Requires
/// NSHealthShareUsageDescription in the host app's Info.plist.
final class HealthBridge {
    private let store = HKHealthStore()

    private static func quantityType(for metric: String) -> HKQuantityType? {
        switch metric {
        case "restingHeartRate":
            return HKObjectType.quantityType(forIdentifier: .restingHeartRate)
        case "hrv":
            return HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        case "steps":
            return HKObjectType.quantityType(forIdentifier: .stepCount)
        case "daylightMinutes":
            if #available(iOS 17.0, *) {
                return HKObjectType.quantityType(forIdentifier: .timeInDaylight)
            }
            return nil
        default:
            return nil
        }
    }

    private static func categoryType(for metric: String) -> HKCategoryType? {
        switch metric {
        case "sleep":
            return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        case "mindfulMinutes":
            return HKObjectType.categoryType(forIdentifier: .mindfulSession)
        default:
            return nil
        }
    }

    private static func sampleType(for metric: String) -> HKSampleType? {
        quantityType(for: metric) ?? categoryType(for: metric)
    }

    func requestAccess(metrics: [String], completion: @escaping (String) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion("unsupported")
            return
        }
        let types = Set(metrics.compactMap { Self.sampleType(for: $0) })
        guard !types.isEmpty else {
            completion("unsupported")
            return
        }
        store.requestAuthorization(toShare: nil, read: types) { ok, _ in
            // HealthKit hides per-type read grants from apps; success only
            // means the prompt flow completed. Unreadable types just come
            // back as null values.
            DispatchQueue.main.async { completion(ok ? "granted" : "denied") }
        }
    }

    /// Reads each metric over [start, end); metrics that are unavailable,
    /// unauthorized or empty resolve to NSNull.
    func read(
        metrics: [String],
        start: Date,
        end: Date,
        completion: @escaping ([String: Any]) -> Void
    ) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(Dictionary(uniqueKeysWithValues: metrics.map { ($0, NSNull()) }))
            return
        }
        var values = [String: Any]()
        let lock = NSLock()
        let group = DispatchGroup()

        func record(_ metric: String, _ value: Double?) {
            lock.lock()
            values[metric] = value.map { $0 as Any } ?? NSNull()
            lock.unlock()
            group.leave()
        }

        for metric in metrics {
            group.enter()
            switch metric {
            case "steps", "daylightMinutes":
                readQuantitySum(metric, start: start, end: end) { record(metric, $0) }
            case "restingHeartRate", "hrv":
                readQuantityAverage(metric, start: start, end: end) { record(metric, $0) }
            case "sleep":
                readSleepMinutes(start: start, end: end) { record(metric, $0) }
            case "mindfulMinutes":
                readMindfulMinutes(start: start, end: end) { record(metric, $0) }
            default:
                record(metric, nil)
            }
        }

        group.notify(queue: .main) { completion(values) }
    }

    private func unit(for metric: String) -> HKUnit {
        switch metric {
        case "restingHeartRate":
            return HKUnit.count().unitDivided(by: .minute())
        case "hrv":
            return HKUnit.secondUnit(with: .milli)
        case "daylightMinutes":
            return .minute()
        default:
            return .count()
        }
    }

    private func readQuantitySum(
        _ metric: String,
        start: Date,
        end: Date,
        completion: @escaping (Double?) -> Void
    ) {
        guard let type = Self.quantityType(for: metric) else {
            completion(nil)
            return
        }
        statistics(type: type, options: .cumulativeSum, start: start, end: end) { stats in
            completion(stats?.sumQuantity()?.doubleValue(for: self.unit(for: metric)))
        }
    }

    private func readQuantityAverage(
        _ metric: String,
        start: Date,
        end: Date,
        completion: @escaping (Double?) -> Void
    ) {
        guard let type = Self.quantityType(for: metric) else {
            completion(nil)
            return
        }
        statistics(type: type, options: .discreteAverage, start: start, end: end) { stats in
            completion(stats?.averageQuantity()?.doubleValue(for: self.unit(for: metric)))
        }
    }

    private func statistics(
        type: HKQuantityType,
        options: HKStatisticsOptions,
        start: Date,
        end: Date,
        completion: @escaping (HKStatistics?) -> Void
    ) {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let query = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: options
        ) { _, stats, _ in
            completion(stats)
        }
        store.execute(query)
    }

    private func readSleepMinutes(
        start: Date,
        end: Date,
        completion: @escaping (Double?) -> Void
    ) {
        categorySamples(metric: "sleep", start: start, end: end) { samples in
            guard let samples else {
                completion(nil)
                return
            }
            let asleep = samples.filter { sample in
                guard let value = HKCategoryValueSleepAnalysis(rawValue: sample.value)
                else { return false }
                if #available(iOS 16.0, *) {
                    return HKCategoryValueSleepAnalysis.allAsleepValues.contains(value)
                }
                return value == .asleep
            }
            let minutes = asleep
                .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) / 60 }
            completion(minutes > 0 ? minutes : nil)
        }
    }

    private func readMindfulMinutes(
        start: Date,
        end: Date,
        completion: @escaping (Double?) -> Void
    ) {
        categorySamples(metric: "mindfulMinutes", start: start, end: end) { samples in
            guard let samples else {
                completion(nil)
                return
            }
            let minutes = samples
                .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) / 60 }
            completion(minutes > 0 ? minutes : nil)
        }
    }

    private func categorySamples(
        metric: String,
        start: Date,
        end: Date,
        completion: @escaping ([HKCategorySample]?) -> Void
    ) {
        guard let type = Self.categoryType(for: metric) else {
            completion(nil)
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, _ in
            completion(samples as? [HKCategorySample])
        }
        store.execute(query)
    }
}
