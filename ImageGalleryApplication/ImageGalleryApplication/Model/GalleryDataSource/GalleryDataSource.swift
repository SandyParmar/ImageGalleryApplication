//
//  GalleryDataSource.swift
//  ImageGalleryApplication
//
//  Created by Sandeep Parmar on 18/11/19.
//  Copyright © 2019 Sandeep Parmar. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class GenericDataSource<T> : NSObject {
    var data: DynamicValue<[T]> = DynamicValue([])
}

class GalleryDataSource : GenericDataSource<ImageGallery>, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageGalleryCollectionViewCell", for: indexPath)as! ImageGalleryCollectionViewCell
        cell.titleNameLabel.text = data.value[indexPath.row].title ?? ""
        
        let url = URL(string: data.value[indexPath.row].thumbnailUrl ?? "")
        cell.imageViewBGView.kf.setImage(with: url)
        cell.imageViewBGView.contentMode = UIImageView.ContentMode.scaleAspectFit
        return cell
    }
    
   
}
