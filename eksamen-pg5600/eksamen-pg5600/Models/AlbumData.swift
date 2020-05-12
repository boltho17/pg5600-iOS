//
//  MusicAlbumData.swift
//  eksamen-pg5600
//
//  Created by Thomas Boldevin Bjerke on 05/12/2019.
//  Copyright © 2019 Thomas Boldevin Bjerke. All rights reserved.
//

import Foundation

struct AlbumData: Decodable{
    let loved: [Album]?
    let album: [Album]?
    let track: [Track]?
    let Similar: [String : [Recommended]]?
}

struct Album: Decodable {
    let idAlbum: String
    let strAlbum: String
    let strArtist: String
    let intYearReleased: String
    let strAlbumThumb: String?
}

struct Track: Decodable {
    let idTrack: String
    let strTrack: String
    let intDuration: String
}

struct Recommended: Decodable {
    let Name: String
}
