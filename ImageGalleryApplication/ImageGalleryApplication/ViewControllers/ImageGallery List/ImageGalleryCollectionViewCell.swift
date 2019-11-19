//
//  ImageGallaryCollectionViewCell.swift
//  ImageGalleryApplication
//
//  Created by Sandeep Parmar on 18/11/19.
//  Copyright © 2019 Sandeep Parmar. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {
    
    var imageViewBGView : UIImageView = {
        
        let view = UIImageView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var titleNameLabel : UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0

        label.textAlignment = .left
        label.text = "Magic Crunch"
        return label
        
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView()  {
        self.contentView.addSubview(self.titleNameLabel)
        self.contentView.addSubview(self.imageViewBGView)
        
       
        self.imageViewBGView.backgroundColor = .clear
      
        self.titleNameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        self.titleNameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        self.titleNameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5).isActive = true
        
        self.imageViewBGView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
        self.imageViewBGView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        self.imageViewBGView.bottomAnchor.constraint(equalTo: self.titleNameLabel.topAnchor, constant: -5).isActive = true
        self.imageViewBGView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        
    }
}
