//
//  PhotosTableViewCell.swift
//  BCSell
//
//  Created by Max Montes on 4/27/22.
//

import UIKit
import SDWebImage

class PhotosCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    var listing: Listing!
    var photo: Photo!
    
    var image: UIImage! {
        didSet {
            if let url = URL(string: self.photo.photoURL) {
                self.photoImageView.sd_imageTransition = .fade
                self.photoImageView.sd_imageTransition?.duration = 0.2
                self.photoImageView.sd_setImage(with: url)
            } else {
                print("URL Didn't work \(self.photo.photoURL)")
                self.photo.loadImage(listing: self.listing) { (success) in
                    self.photo.saveData(listing: self.listing) { (success) in
                        print("image updated with URL \(self.photo.photoURL)")
                    }
                }
            }
        }
    }
}
