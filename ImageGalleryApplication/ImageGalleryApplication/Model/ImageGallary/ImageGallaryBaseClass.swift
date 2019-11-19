//
//	ImageGallaryBaseClass.swift
//  ImageGalleryApplication
//
//  Created by Sandeep Parmar on 18/11/19.
//  Copyright © 2019 Sandeep Parmar. All rights reserved.
//
import Foundation


class ImageGallaryBaseClass : NSObject, NSCoding{

	var albumId : Int!
	var id : Int!
	var thumbnailUrl : String!
	var title : String!
	var url : String!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		albumId = dictionary["albumId"] as? Int
		id = dictionary["id"] as? Int
		thumbnailUrl = dictionary["thumbnailUrl"] as? String
		title = dictionary["title"] as? String
		url = dictionary["url"] as? String
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if albumId != nil{
			dictionary["albumId"] = albumId
		}
		if id != nil{
			dictionary["id"] = id
		}
		if thumbnailUrl != nil{
			dictionary["thumbnailUrl"] = thumbnailUrl
		}
		if title != nil{
			dictionary["title"] = title
		}
		if url != nil{
			dictionary["url"] = url
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         albumId = aDecoder.decodeObject(forKey: "albumId") as? Int
         id = aDecoder.decodeObject(forKey: "id") as? Int
         thumbnailUrl = aDecoder.decodeObject(forKey: "thumbnailUrl") as? String
         title = aDecoder.decodeObject(forKey: "title") as? String
         url = aDecoder.decodeObject(forKey: "url") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if albumId != nil{
			aCoder.encode(albumId, forKey: "albumId")
		}
		if id != nil{
			aCoder.encode(id, forKey: "id")
		}
		if thumbnailUrl != nil{
			aCoder.encode(thumbnailUrl, forKey: "thumbnailUrl")
		}
		if title != nil{
			aCoder.encode(title, forKey: "title")
		}
		if url != nil{
			aCoder.encode(url, forKey: "url")
		}

	}

}
