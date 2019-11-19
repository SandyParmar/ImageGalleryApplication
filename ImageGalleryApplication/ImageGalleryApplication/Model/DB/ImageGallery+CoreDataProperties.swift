//
//  ImageGallery+CoreDataProperties.swift
//  ImageGalleryApplication
//
//  Created by Sandeep Parmar on 18/11/19.
//  Copyright © 2019 Sandeep Parmar. All rights reserved.
//
//

import Foundation
import CoreData


extension ImageGallery {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageGallery> {
        return NSFetchRequest<ImageGallery>(entityName: "ImageGallery")
    }

    @NSManaged public var albumId: Int64
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var thumbnailUrl: String?

}
