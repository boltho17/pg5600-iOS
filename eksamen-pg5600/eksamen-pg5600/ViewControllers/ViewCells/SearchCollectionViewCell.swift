//
//  SearchCollectionViewCell.swift
//  eksamen-pg5600
//
//  Created by Thomas Boldevin Bjerke on 08/12/2019.
//  Copyright © 2019 Thomas Boldevin Bjerke. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    // Code from https://medium.com/swlh/loading-images-from-url-in-swift-2bf8b9db266
    func setImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }

            // just not to cause a deadlock in UI!
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.albumImage.image = image
            }
        }
    }
}
