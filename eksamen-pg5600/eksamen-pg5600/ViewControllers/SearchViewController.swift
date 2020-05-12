//
//  SearchViewController.swift
//  eksamen-pg5600
//
//  Created by Thomas Boldevin Bjerke on 08/12/2019.
//  Copyright © 2019 Thomas Boldevin Bjerke. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, MusicManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var noResults: UILabel!
    
    var albumResults: [AlbumModel?] = []
    var selectedIndex: Int = 0
    var selectedAlbumId: String = ""
    var musicManager = MusicManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.delegate = self
        collectionView?.dataSource = self
        searchTextField.delegate = self
        musicManager.delegate = self
    }
    
    
    // Search button with magnifying icon
    @IBAction func searchPressed(_ sender: UIButton) {
        albumResults = []
        musicManager.searchAlbums(term: searchTextField.text!)

        if(albumResults.count == 0) {
            noResults.text = "No results"
        } else { noResults.text = "" }
        searchTextField.endEditing(true)
    }
    
    // Return button of the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        albumResults = []
        musicManager.searchAlbums(term: searchTextField.text!)
        
        if(albumResults.count == 0) {
            noResults.text = "No results"
        } else { noResults.text = "" }
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Please type something"
            return false
        }
    }
    
    
    // Presenting two colums in the CollectionView
    // Code from https://stackoverflow.com/questions/49573790/how-to-show-two-columns-in-a-collectionview-using-swift4-in-all-devices
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCollectionViewCell
        
        //
        if(albumResults.count > 0) {
            // Album name
            if let albumName = albumResults[indexPath.item]?.albumName {
                cell.albumName.text = albumName
            }
                
            // Artist name
            if let artistName = albumResults[indexPath.item]?.artistName {
                cell.artistName.text = artistName
            }
                    
            // Album artwork
            if let albumImage = albumResults[indexPath.item]?.imageURL {
                cell.setImage(from: albumImage)
            }
        }
        return cell
    }
    
    
    // When an album is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        selectedIndex = indexPath.item
        selectedAlbumId = albumResults[indexPath.item]!.albumId
        self.performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.selectedAlbum = albumResults
            destinationVC.selectedIndex = selectedIndex
            destinationVC.selectedAlbumId = selectedAlbumId
        }
    }

    // Gets called in MusicManager
    func didUpdateData(albums: [AlbumModel]?, tracks: [TrackModel]?, recommendedArtists: [RecommendedModel]?) {
        for album in albums! {
            self.albumResults.append(album)
        }
        // Updates the CollectionView after albumResults has been populated
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
}
