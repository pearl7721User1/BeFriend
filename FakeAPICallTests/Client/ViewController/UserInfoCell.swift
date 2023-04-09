//
//  UserInfoCell.swift
//  FakeAPICallTests
//
//  Created by Giwon Seo on 2023/03/26.
//

import UIKit

class UserInfoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: GiwonImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func layoutSubviews() {
        imageView.layer.cornerRadius = imageView.bounds.width / 2.0
        imageView.layer.borderColor = UIColor.orange.cgColor
        imageView.layer.borderWidth = imageView.image != nil ? 2.0 : 0.0
    }
    
    func configure(userInfo: User) {
        if let imageUrl = userInfo.imageUrl {
            imageView.urlString = imageUrl
            imageView.load()
        }
        
        nameLabel.text = userInfo.name
    }
    
    override func prepareForReuse() {
        imageView.cancelLoading()
        imageView.image = nil
    }
}
