//
//  ViewController.swift
//  eksamen-pg5600
//
//  Created by Thomas Boldevin Bjerke on 05/12/2019.
//  Copyright © 2019 Thomas Boldevin Bjerke. All rights reserved.
//

import Foundation
import UIKit

class TopAlbumsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var topAlbums: [AlbumModel?] = []
    var selectedIndex: Int = 0
    var selectedAlbumId: String = ""
    var isListView: Bool = false
    var musicManager = MusicManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.dataSource = self
        collectionView?.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        musicManager.delegate = self
        
        // Get Top 50 Albums
        musicManager.fetchTopAlbums()
        
        // Hides tableView on  load
        tableView.isHidden = true
    }
    
    @IBOutlet weak var gridButton: UIBarButtonItem!
    @IBOutlet weak var listButton: UIBarButtonItem!
    
    @IBAction func listTapped(_ sender: UIBarButtonItem) {
        isListView = true
        tableView?.isHidden = false
        gridButton.tintColor = UIColor.systemGray
        sender.tintColor = UIColor.systemIndigo
        self.collectionView?.reloadData()
    }
    
    @IBAction func gridTapped(_ sender: UIBarButtonItem) {
        isListView = false
        //tableView.removeFromSuperview()
        tableView?.isHidden = true
        listButton.tintColor = UIColor.systemGray
        sender.tintColor = UIColor.systemIndigo
        self.collectionView?.reloadData()
    }
    
    
    // Gets called in MusicManager
    func didUpdateData(albums: [AlbumModel]?, tracks: [TrackModel]?, recommendedArtists: [RecommendedModel]?) {
        for album in albums! {
            self.topAlbums.append(album)
        }
        
        // Updates the CollectionView after topAlbums has been populated
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
}

// MARK: - EXTENSIONS
extension TopAlbumsViewController: UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MusicManagerDelegate {
    
    // UITableView:

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCell", for: indexPath) as! ListViewCell
        cell.contentView.layoutMargins.bottom = 20
        cell.albumName.text = self.topAlbums[indexPath.item]?.albumName
        cell.artistName.text = self.topAlbums[indexPath.item]?.artistName
        cell.setImage(from: self.topAlbums[indexPath.item]!.imageURL)
        return cell
    }
    
    // Navigates to detailView when an album is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        selectedAlbumId = topAlbums[indexPath.item]!.albumId
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    // CollectionView:
    
    // Presenting two colums in the CollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(isListView) {
            return CGSize(width: view.frame.width, height: 50)
        }
        else {
            // Code from https://stackoverflow.com/questions/49573790/how-to-show-two-columns-in-a-collectionview-using-swift4-in-all-devices
            let flowlayout = collectionViewLayout as? UICollectionViewFlowLayout
            let space: CGFloat = (flowlayout?.minimumInteritemSpacing ?? 0.0) + (flowlayout?.sectionInset.left ?? 0.0) + (flowlayout?.sectionInset.right ?? 0.0)
            let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
            return CGSize(width: size, height: size)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topAlbums.count
    }
    
    // Populates the collection view cells with the album attributes stored in topAlbums
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        if(topAlbums.count > 0) {
            // Album name
            if let albumName = topAlbums[indexPath.item]?.albumName {
                cell.albumName.text = albumName
            }
            
            // Artist name
            if let artistName = topAlbums[indexPath.item]?.artistName {
                cell.artistName.text = artistName
            }
            
            // Album artwork
            if let albumImage = topAlbums[indexPath.item]?.imageURL {
                cell.setImage(from: albumImage)
            }
        }
        return cell
    }
    
    // Navigates to detailView when an album is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print(indexPath.item)
        selectedIndex = indexPath.item
        selectedAlbumId = topAlbums[indexPath.item]!.albumId
        self.performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.selectedAlbum = topAlbums
            detailVC.selectedIndex = selectedIndex
            detailVC.selectedAlbumId = selectedAlbumId
        }
    }
}


