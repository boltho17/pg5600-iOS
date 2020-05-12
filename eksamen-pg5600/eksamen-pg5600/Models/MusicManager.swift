//
//  AlbumManager.swift
//  eksamen-pg5600
//
//  Created by Thomas Boldevin Bjerke on 05/12/2019.
//  Copyright © 2019 Thomas Boldevin Bjerke. All rights reserved.
//

import Foundation

protocol MusicManagerDelegate {
    func didUpdateData(albums: [AlbumModel]?, tracks: [TrackModel]?, recommendedArtists: [RecommendedModel]?)
}

struct MusicManager {
    
    let decoder = JSONDecoder()
    var delegate: MusicManagerDelegate?
    
    func fetchTopAlbums() {
        let topAlbumsURL = "https://theaudiodb.com/api/v1/json/1/mostloved.php?format=album"
        performRequest(urlString: topAlbumsURL, format: "album")
    }
    
    func searchAlbums(term: String) {
        let searchURL = "https://theaudiodb.com/api/v1/json/1/searchalbum.php?a=\(term.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil))"
        performRequest(urlString: searchURL, format: "album")
    }
    
    func fetchAlbumTracks(albumId: String) {
        let tracksURL = "https://theaudiodb.com/api/v1/json/1/track.php?m=\(albumId)"
        performRequest(urlString: tracksURL, format: "track")
    }
    
    func fetchRecommended(term: String, type: String, limit: Int) {
        let recommendedURL = "https://tastedive.com/api/similar?type=\(type)&limit=\(limit)&q=\(term.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil))"
        print(recommendedURL)
        performRequest(urlString: recommendedURL, format: "recommended")
    }
    
    func performRequest(urlString: String, format: String) {
        // Tried to fetch and display synchronically with DispatchQueue and semaphore without success. Now the Top 50 listView presentation is depending on it for some reason.
        let semaphore = DispatchSemaphore(value: 0)
        
        // Create URL
        if let url = URL(string: urlString) {
            // Create URLSession
            let session = URLSession(configuration: .default)
            
            // Session task with a trailing closure
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                }
                if let safeData = data {
                    switch format {
                    case "album":
                        if let albums = self.parseAlbumJSON(albumData: safeData) {
                            self.delegate?.didUpdateData(albums: albums, tracks: nil, recommendedArtists: nil)
                        }
                    case "track":
                        if let tracks = self.parseTrackJSON(trackData: safeData) {
                            self.delegate?.didUpdateData(albums: nil, tracks: tracks, recommendedArtists: nil)
                        }
                    case "recommended":
                        if let recommended = self.parseRecommendedJSON(recommendedData: safeData) {
                            self.delegate?.didUpdateData(albums: nil, tracks: nil, recommendedArtists: recommended)
                        }
                    default:
                        print("Error: Wrong format")
                    }
                    semaphore.signal()
                }
            }
            // Start the task
            task.resume()
            _ = semaphore.wait(timeout: .distantFuture)
        }
    }

    func parseAlbumJSON(albumData: Data) -> [AlbumModel]? {
        
        var albums: [Album]?
        var albumsArray: [AlbumModel] = []
        
        do {
            let decodedData = try decoder.decode(AlbumData.self, from: albumData)

            if(decodedData.loved != nil) {
                // top50
                albums = decodedData.loved!
            }
            
            if(decodedData.album != nil) {
                // search
                albums = decodedData.album!
            }
            
            if(albums != nil ) {
                for album in albums! {
                    let id = album.idAlbum
                    let name = album.strAlbum
                    let artist = album.strArtist
                    let year = album.intYearReleased
                    let image: String
                
                    // Setting a placeholder image if the album image URL is an empty string.
                    // Or using the nil coalescing operator to set default values if the album image URL is null:
                    if(album.strAlbumThumb == "") {
                        image = "https://i.pinimg.com/236x/aa/b1/ec/aab1ecb34b618b8e62cabb604822c9a1--cd-cover-design-cd-design.jpg"
                    } else {
                        image = album.strAlbumThumb ?? "https://i.pinimg.com/originals/ac/7d/a4/ac7da4faf6b2c46f6942b1d1bc64e980.jpg"
                    }
                
                    let albumModel = AlbumModel(albumId: id, albumName: name, artistName: artist, yearReleased: year, imageURL: image)
                    albumsArray.append(albumModel)
                }
            }
            return albumsArray
        } catch {
            print(error)
            return nil
        }
    }
    
    func parseTrackJSON(trackData: Data) -> [TrackModel]? {
        var tracks: [Track]?
        var tracksArray: [TrackModel] = []
        
        do {
            let decodedData = try decoder.decode(AlbumData.self, from: trackData)
            
            if(decodedData.track != nil) {
                tracks = decodedData.track!
            }
            
            if(tracks != nil) {
                for track in tracks! {
                    let id = track.idTrack
                    let title = track.strTrack
                    let duration = track.intDuration
                    let trackModel = TrackModel(trackId: id, trackTitle: title, trackDuration: duration)
                    tracksArray.append(trackModel)
                }
            }
            return tracksArray
        } catch {
            print(error)
            return nil
        }
    }
    
    func parseRecommendedJSON(recommendedData: Data) -> [RecommendedModel]? {
        var recArtists: [Recommended]?
        var recArtistsArray: [RecommendedModel] = []
        
        do {
            let decodedData = try decoder.decode(AlbumData.self, from: recommendedData)
            // print(decodedData.Similar?.keys)
            // print(decodedData.Similar?["Info"])
            // print(decodedData.Similar?["Results"])
            
            if(decodedData.Similar != nil) {
                recArtists = decodedData.Similar?["Results"]
            }
            
            if(recArtists != nil) {
                for artist in recArtists! {
                    let artistName = artist.Name
                    let recommendedModel = RecommendedModel(artistName: artistName)
                    recArtistsArray.append(recommendedModel)
                }
            }
            return recArtistsArray
        } catch {
            print(error)
            return nil
        }
    }
}
