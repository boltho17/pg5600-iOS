//
//  FavoritesTableViewCell.swift
//  eksamen-pg5600
//
//  Created by Thomas Boldevin Bjerke on 11/12/2019.
//  Copyright © 2019 Thomas Boldevin Bjerke. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var duration: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
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
