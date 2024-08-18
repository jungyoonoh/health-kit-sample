//
//  ContentView.swift
//  WatchWithIosApp Watch App
//
//  Created by USER on 8/6/24.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var heartRateManager = HeartRateManager()

    var body: some View {
        VStack {
            if let heartRate = heartRateManager.heartRate {
                Text("Heart Rate: \(heartRate) BPM")
                    .font(.largeTitle)
            } else {
                Text("Fetching Heart Rate...")
                    .font(.largeTitle)
            }
        }
        .onAppear {
            heartRateManager.start()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
