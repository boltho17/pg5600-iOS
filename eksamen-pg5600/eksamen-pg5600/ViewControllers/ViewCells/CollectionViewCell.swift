//
//  CollectionViewCell.swift
//  eksamen-pg5600
//
//  Created by Thomas Boldevin Bjerke on 07/12/2019.
//  Copyright © 2019 Thomas Boldevin Bjerke. All rights reserved.
//

import UIKit

// Code from https://stackoverflow.com/questions/38062289/ios-swift-how-to-properly-scale-down-an-image
extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
}

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    // @IBOutlet weak var albumThumbnail: UIImageView!
    
    
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

