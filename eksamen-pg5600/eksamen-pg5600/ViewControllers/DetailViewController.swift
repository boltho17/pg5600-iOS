//
//  DetailViewController.swift
//  eksamen-pg5600
//
//  Created by Thomas Boldevin Bjerke on 08/12/2019.
//  Copyright © 2019 Thomas Boldevin Bjerke. All rights reserved.
//

import UIKit

protocol DetailViewDelegate {
    func sendFavoritesArray(favorites: [TrackModel?])
}

class DetailViewController: UIViewController {
    
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var albumYear: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var testArray: [String] = []
    
    var tracks: [TrackModel?] = []
    var favoriteTracks: [FavoriteModel] = []
    var selectedAlbum: [AlbumModel?] = []
    var selectedTrack: TrackModel?
    var selectedIndex: Int = 0
    var selectedAlbumId: String = ""
    var musicManager = MusicManager()
    let favoritesVC = FavoritesViewController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImage(from: selectedAlbum[selectedIndex]!.imageURL)
        self.artistName.text = selectedAlbum[selectedIndex]?.artistName
        self.albumName.text = selectedAlbum[selectedIndex]?.albumName
        self.albumYear.text = selectedAlbum[selectedIndex]?.yearReleased
        
        tableView?.dataSource = self
        tableView?.delegate = self
        
        musicManager.delegate = self
        musicManager.fetchAlbumTracks(albumId: selectedAlbumId)
    }
    
    // Sets the album cover
    // Code from https://medium.com/swlh/loading-images-from-url-in-swift-2bf8b9db266
    func setImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }

            // just not to cause a deadlock in UI!
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.artwork.image = image
            }
        }
    }
    
    // Gets called in MusicManager
    func didUpdateData(albums: [AlbumModel]?, tracks: [TrackModel]?, recommendedArtists: [RecommendedModel]?) {
        for track in tracks! {
            self.tracks.append(track)
        }
        
        // Updates the CollectionView after topAlbums has been populated
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource, MusicManagerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        cell.songTitle.text = tracks[indexPath.item]?.trackTitle
        cell.duration.text = tracks[indexPath.item]?.trackDurationFormatted
        return cell
    }
    
    // Adds selected track to Favorites
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedTrack = tracks[indexPath.item]
        let newFavorite = FavoriteModel(trackId: selectedTrack!.trackId, title: selectedTrack!.trackTitle, artist: selectedAlbum[selectedIndex]!.artistName, albumImage: selectedAlbum[selectedIndex]!.imageURL, trackDuration: selectedTrack!.trackDurationFormatted)

        tableView.deselectRow(at: indexPath, animated: true)
        
        // Checks if the selected song is already in Favorites and adds if its not.
        if FavoritesViewController.favoriteTracksArray.contains(where: {$0.trackId == newFavorite.trackId}) {
            showToast(message: "Already added!", font: .systemFont(ofSize: 14))
        } else {
            showToast(message: "Added to Favorites!", font: .systemFont(ofSize: 14))
            FavoritesViewController.favoriteTracksArray.append(newFavorite)
        }
        
        // Updates the Favorites tableView
        // Code from: https://stackoverflow.com/questions/53872958/reload-tableview-from-another-viewcontroller-swift-4-2
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
    }
    
    // Shows a toast message when trying to add a song to Favorites
    // Modified code from: https://stackoverflow.com/questions/31540375/how-to-toast-message-in-swift/51348537
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-140, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.systemIndigo.withAlphaComponent(1.0)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
