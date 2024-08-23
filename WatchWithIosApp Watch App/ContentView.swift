//
//  ContentView.swift
//  WatchWithIosApp Watch App
//
//  Created by USER on 8/6/24.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var uniqueID: String = ""

    @StateObject private var heartRateManager = HeartRateManager()

    var body: some View {
        VStack {
            Text("Unique ID:")
                            .font(.headline)
                        Text(uniqueID)
                            .font(.body)
                            .padding()
                            .lineLimit(nil) // 여러 줄로 표시하기
                            .minimumScaleFactor(0.5) // 텍스트가 너무 클 경우 축소 비율
                        
            
            if let heartRate = heartRateManager.heartRate {
                Text("Heart Rate: \(heartRate) BPM")
                    .font(.body)
            } else {
                Text("Fetching Heart Rate...")
                    .font(.body)
            }
        }
        .onAppear {
            uniqueID = UniqueIDManager.shared.getUniqueID()

            heartRateManager.start()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
