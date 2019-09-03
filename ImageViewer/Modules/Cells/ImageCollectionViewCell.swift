//
//  ImageCollectionViewCell.swift
//  ImageViewer
//
//  Created by Aman gupta on 03/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var displayImageView: UIImageView!
    
    // MARK: - Properties
    var photo: Photo?
    
    // MARK: - Cell Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(photo: Photo) {
        self.photo = photo
        displayImageView.image = #imageLiteral(resourceName: "placeholder")
        ImageManager.shared.downloadImage(imageURL: photo.thumbImageURL) {[weak self] (imageURL, image) in
            if imageURL == self?.photo?.thumbImageURL, let image = image {
                DispatchQueue.main.async {
                    self?.displayImageView.image = image
                }
            }
        }
    }
    
}
