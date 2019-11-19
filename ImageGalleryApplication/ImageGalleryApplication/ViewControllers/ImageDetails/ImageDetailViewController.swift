//
//  ImageDetailViewController.swift
//  ImageGalleryApplication
//
//  Created by Sandeep Parmar on 18/11/19.
//  Copyright © 2019 Sandeep Parmar. All rights reserved.
//

import UIKit
import Kingfisher

class ImageDetailViewController: UIViewController {

    @IBOutlet weak var galleryImageView : UIImageView!
    
    var imageURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: self.imageURL)
        self.galleryImageView.kf.setImage(with: url)
        self.galleryImageView.contentMode = UIImageView.ContentMode.scaleAspectFit
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
