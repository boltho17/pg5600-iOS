//
//  TrackModel.swift
//  eksamen-pg5600
//
//  Created by Thomas Boldevin Bjerke on 09/12/2019.
//  Copyright © 2019 Thomas Boldevin Bjerke. All rights reserved.
//

import Foundation

struct TrackModel {
    let trackId: String
    let trackTitle: String
    let trackDuration: String
    var trackDurationFormatted: String {
        mutating get{
            return secondsToMinutesSeconds(seconds: trackDuration)
        }
    }

    mutating func secondsToMinutesSeconds (seconds : String) -> String {
        let secondsInt = Int(seconds)! / 1000
        let minutes = secondsInt / 60
        let second = secondsInt % 60
        return "\(minutes):\(String(format: "%02d", second))"
    }
}
