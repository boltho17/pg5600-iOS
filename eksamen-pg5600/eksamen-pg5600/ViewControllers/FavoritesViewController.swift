//
//  FavoritesViewController.swift
//  eksamen-pg5600
//
//  Created by Thomas Boldevin Bjerke on 11/12/2019.
//  Copyright © 2019 Thomas Boldevin Bjerke. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var editMode: Bool = false
    
    static var favoriteTracksArray = Array<FavoriteModel>()
    var recommendedArtists: [RecommendedModel?] = []
    var selectedTrack: TrackModel?
    var musicManager = MusicManager()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var recommendedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        musicManager.delegate = self
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        // Updates the tableView when initiated from the DetailVC
        // Code from: https://stackoverflow.com/questions/53872958/reload-tableview-from-another-viewcontroller-swift-4-2
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
        
        // Fetches the stored data from UserDefaults
        // Code from https://stackoverflow.com/questions/44876420/save-struct-to-userdefaults
        if let storedTracks = UserDefaults.standard.value(forKey: "favoriteTracks") as? Data {
            FavoritesViewController.favoriteTracksArray = try! PropertyListDecoder().decode(Array<FavoriteModel>.self, from: storedTracks)
        }
        
        setupRecommendedView()
        musicManager.fetchRecommended(term: parseFavoriteArtistsToString(), type: "music", limit: 20)
        
        // Single row collectionView with horizontal scroll
        // Code from: https://stackoverflow.com/questions/15166755/how-to-make-a-single-row-collection-view-that-scrolls-horizontally-but-is-fixed/39219198
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/2-10, height: 190)
        flowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        collectionView.collectionViewLayout = flowLayout
        
    }
    
    func setupRecommendedView() {
        if FavoritesViewController.favoriteTracksArray.count < 1 {
            collectionView.isHidden = true
            recommendedLabel.text = "Add favorites from albums"
        } else {
            collectionView.isHidden = false
            recommendedLabel.text = "Recommended Artists"
        }
    }
    
    // Parses each unique artist from Favorites to a string. Gets invoked in the fetchRecommended method.
    func parseFavoriteArtistsToString() -> String {
        var query = ""
        var uniqueArtistsArray: [FavoriteModel] = []
        for artist in FavoritesViewController.favoriteTracksArray {
            if(!uniqueArtistsArray.contains(where: { $0.artist == artist.artist })) {
                uniqueArtistsArray.append(artist)
            }
        }
        for artist in uniqueArtistsArray.reversed() {
            query = query + artist.artist + "%2C"
        }
        return String(query.dropLast(3))
    }
    
    @objc func refresh() {
        setupRecommendedView()
        self.tableView.reloadData()
        //parseFavoriteArtistsToString()
        // Saves the selected track to UserDefaults at the same time as user adds the track to Favorites in the DetailVC
        // Code from https://stackoverflow.com/questions/44876420/save-struct-to-userdefaults
        UserDefaults.standard.set(try? PropertyListEncoder().encode(FavoritesViewController.favoriteTracksArray), forKey: "favoriteTracks")
        recommendedArtists.removeAll()
        musicManager.fetchRecommended(term: parseFavoriteArtistsToString(), type: "music", limit: 20)
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing == false {
            tableView.isEditing = true
            editButton.title = "Done"
            cancelButton.title = "Cancel"
            cancelButton.isEnabled = true
            let parsed = parseFavoriteArtistsToString()
            print(parsed)
            collectionView.reloadData()
        } else {
            recommendedArtists.removeAll()
            musicManager.fetchRecommended(term: parseFavoriteArtistsToString(), type: "music", limit: 20)
            tableView.isEditing = false
            editButton.title = "Edit"
            cancelButton.title = ""
            cancelButton.isEnabled = false
            // Saves the changes (deletes and reordering) to UserDefaults:
            refresh()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        tableView.isEditing = false
        cancelButton.title = ""
        cancelButton.isEnabled = false
        if let storedTracks = UserDefaults.standard.value(forKey: "favoriteTracks") as? Data {
            FavoritesViewController.favoriteTracksArray = try! PropertyListDecoder().decode(Array<FavoriteModel>.self, from: storedTracks)
        }
        tableView.reloadData()
    }
}

// MARK: - EXTENSIONS
extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, MusicManagerDelegate {
    
    // Gets called in MusicManager
    func didUpdateData(albums: [AlbumModel]?, tracks: [TrackModel]?, recommendedArtists: [RecommendedModel]?) {
        for artist in recommendedArtists! {
            self.recommendedArtists.append(artist)
        }
    
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(recommendedArtists.count)
        if(recommendedArtists.count > 0) {
            return recommendedArtists.count
        }
        else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! RecommendedCollectionViewCell
        
        if(recommendedArtists.count > 0) {
        
            if let artistName = recommendedArtists[indexPath.item]?.artistName {
                cell.label.text = artistName
            }
        }
        else {
            cell.label.text = "Push to reload"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        recommendedArtists.removeAll()
        musicManager.fetchRecommended(term: parseFavoriteArtistsToString(), type: "music", limit: 20)
        DispatchQueue.main.async {
            collectionView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesViewController.favoriteTracksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath) as! FavoritesTableViewCell
        cell.setImage(from: FavoritesViewController.favoriteTracksArray[indexPath.item].albumImage)
        cell.trackTitle.text = FavoritesViewController.favoriteTracksArray[indexPath.item].title
        cell.artistName.text = FavoritesViewController.favoriteTracksArray[indexPath.item].artist
        cell.duration.text = FavoritesViewController.favoriteTracksArray[indexPath.item].trackDuration
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Enables reordering of the Rows in tableView
    // Code from: https://www.ioscreator.com/tutorials/reorder-rows-table-view-ios-tutorial-ios12
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = FavoritesViewController.favoriteTracksArray[sourceIndexPath.row]
        FavoritesViewController.favoriteTracksArray.remove(at: sourceIndexPath.row)
        FavoritesViewController.favoriteTracksArray.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    // Deletes the selected row from the TableView if confirmed by pressing delete
    // Code from: https://www.ioscreator.com/tutorials/delete-rows-table-view-ios-tutorial-ios12
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            // Shows an alerts message asking for confirmation on delete (Only implemented because the exam explicitly asked for it. Not nessecary when user can cancel the edit mode.)
            // Modified code from: https://stackoverflow.com/questions/29633938/swift-displaying-alerts-best-practices
            presentAlertWithTitle(title: "Delete Favorite", message: "Are you sure you want to remove the song \(FavoritesViewController.favoriteTracksArray[indexPath.row].title) by \(FavoritesViewController.favoriteTracksArray[indexPath.row].artist)?", options: "Cancel", "Delete") { (option) in
                switch(option) {
                    case 0:
                        break
                    case 1:
                        FavoritesViewController.favoriteTracksArray.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                        break
                    default:
                        break
                }
            }
        }
    }
    
    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                completion(index)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

/* Clears all data in UserDefaults:
let domain = Bundle.main.bundleIdentifier!
UserDefaults.standard.removePersistentDomain(forName: domain)
UserDefaults.standard.synchronize()
print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
*/

