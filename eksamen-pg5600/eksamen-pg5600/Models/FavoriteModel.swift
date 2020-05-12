//
//  File.swift
//  eksamen-pg5600
//
//  Created by Thomas Boldevin Bjerke on 12/12/2019.
//  Copyright © 2019 Thomas Boldevin Bjerke. All rights reserved.
//

import Foundation

struct FavoriteModel: Codable {
    let trackId: String
    let title: String
    let artist: String
    let albumImage: String
    let trackDuration: String
    var trackDurationFormatted: String {
        mutating get{
            return secondsToMinutesSeconds(seconds: trackDuration)
        }
    }
    // Turns an amount of seconds to minutes and seconds
    mutating func secondsToMinutesSeconds (seconds : String) -> String {
        let secondsInt = Int(seconds)! / 1000
        let minutes = secondsInt / 60
        let second = secondsInt % 60
        return "\(minutes):\(String(format: "%02d", second))"
    }
}
