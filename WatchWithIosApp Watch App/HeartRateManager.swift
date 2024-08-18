//
//  HeartRateManager.swift
//  WatchWithIosApp Watch App
//
//  Created by USER on 8/6/24.
//

import Foundation
import HealthKit

class HeartRateManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private var query: HKObserverQuery?
    @Published var heartRate: Double?

    init() {
        requestAuthorization()
    }

    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }

        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [heartRateType]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if !success {
                if let error = error {
                    print("Error requesting HealthKit authorization: \(error.localizedDescription)")
                }
            }
        }
    }

    func start() {
        #if targetEnvironment(simulator)
        // 시뮬레이터에서 미리 정의된 데이터를 사용
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.heartRate = 72.0
            self.sendHeartRateToServer(72.0)
        }
        #else
        // 실제 디바이스에서 HealthKit 데이터를 가져옴
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Error starting heart rate query: \(error.localizedDescription)")
                return
            }

            self?.fetchLatestHeartRate()
            completionHandler()
        }

        if let query = query {
            healthStore.execute(query)
        }
        #endif
    }

    private func fetchLatestHeartRate() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] query, results, error in
            if let error = error {
                print("Error fetching heart rate: \(error.localizedDescription)")
                return
            }

            if let results = results, let sample = results.first as? HKQuantitySample {
                let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                DispatchQueue.main.async {
                    self?.heartRate = heartRate
                    self?.sendHeartRateToServer(heartRate)
                }
            }
        }

        healthStore.execute(query)
    }

    private func sendHeartRateToServer(_ heartRate: Double) {
        guard let url = URL(string: "https://yourserver.com/api/heartRate") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["heartRate": heartRate]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending heart rate to server: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Heart rate successfully sent to server")
            } else {
                print("Failed to send heart rate to server")
            }
        }

        task.resume()
    }
}
