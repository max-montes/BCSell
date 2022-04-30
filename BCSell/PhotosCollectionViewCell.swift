//
//  PhotosTableViewCell.swift
//  BCSell
//
//  Created by Max Montes on 4/27/22.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    
    var image: UIImage! {
        didSet {
            photo.image = image
        }
    }
}
