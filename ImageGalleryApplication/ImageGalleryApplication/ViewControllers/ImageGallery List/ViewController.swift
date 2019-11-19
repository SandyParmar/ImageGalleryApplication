//
//  ViewController.swift
//  ImageGalleryApplication
//
//  Created by Sandeep Parmar on 18/11/19.
//  Copyright © 2019 Sandeep Parmar. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,ReachabilityManagerDelegate {
    
    @IBOutlet weak var segmentController : UISegmentedControl!
    @IBOutlet weak var collectionView : UICollectionView!
    
    lazy var collectionViewFlowLayout : CustomCollectionViewFlowLayout = {
        let layout = CustomCollectionViewFlowLayout(display: .list)
        return layout
    }()
    
    let dataSource = GalleryDataSource()
    
      let alert = UIAlertController(title: "IGA", message: "", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ReachabilityManager.sharedInstance.networkDelegate = self
        
        self.collectionView.register(ImageGalleryCollectionViewCell.self, forCellWithReuseIdentifier: "ImageGalleryCollectionViewCell")
        
        self.collectionView.collectionViewLayout = self.collectionViewFlowLayout
        self.collectionView.dataSource = self.dataSource
        self.collectionView.delegate = self
        self.fetchDataFromDB()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let obj = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "ImageDetailViewController")as! ImageDetailViewController
        obj.imageURL = self.dataSource.data.value[indexPath.row].thumbnailUrl ?? ""
        
        self.navigationController?.pushViewController(obj, animated: true)
    }
    func fetchDataFromDB() {
        let request: NSFetchRequest<ImageGallery> = ImageGallery.fetchRequest()
        
        
        do {
            self.dataSource.data.value = try CoreDataManager.sharedInstance.persistentContainer.viewContext.fetch(request)
            if self.dataSource.data.value.count == 0 {
                SPIndicatorView.sharedInstance.showActivityIndicator(uiView: self.view)
                self.getAllImageGallary()
            }
            else{
                
                DispatchQueue.main.async {
                    self.dataSource.data.addAndNotify(observer: self) { [weak self] in
                        self?.collectionView.reloadData()
                    }
                }
                
            }
        } catch {
            print("Fetch failed")
            self.showAlertMessage(message: "Fetch failed")
        }
    }
    func getAllImageGallary() {
        
        guard let url = URL(string: "\(APIConstants.baseAPI)") else { return }
        
        APIManager.sharedInstance.apiRequest(toURL: url, withHttpMethod: .GET) { (results) in
            
            guard let response = results.response else { return }
            if response.httpStatusCode == 200 {
                guard let data = results.data else { return }
                
                do {
                    let imageGallary =  try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSArray
                    
                    self.save(gallaryImages: imageGallary)
                } catch {
                    DispatchQueue.main.async {
                        SPIndicatorView.sharedInstance.hideActivityIndicator(uiView: self.view)
                        self.showAlertMessage(message: "Something went wrong with plugin api")
                    }
                }
            }
            else  if response.httpStatusCode == 0 {
                DispatchQueue.main.async {
                    SPIndicatorView.sharedInstance.hideActivityIndicator(uiView: self.view)
                    self.showAlertMessage(message: "The Internet connection appears to be offline.")
                }
            }
            else{
                DispatchQueue.main.async {
                    SPIndicatorView.sharedInstance.hideActivityIndicator(uiView: self.view)
                    self.showAlertMessage(message: "Something went wrong with plugin api")
                }
            }
        }
    }
    
    func save(gallaryImages:NSArray)
    {
        let managedContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
        //Data is in this case the name of the entity
        
        for itemDict in gallaryImages {
            
            let dict = itemDict as! NSDictionary
            
            let imageGalleryObj = NSEntityDescription.insertNewObject(forEntityName: "ImageGallery", into: managedContext) as! ImageGallery
            
            imageGalleryObj.albumId = dict.object(forKey: "albumId") as! Int64
            imageGalleryObj.id = dict.object(forKey: "id") as! Int64
            imageGalleryObj.title = (dict.object(forKey: "title") as! String)
            imageGalleryObj.url = (dict.object(forKey: "url") as! String)
            imageGalleryObj.thumbnailUrl = (dict.object(forKey: "thumbnailUrl") as! String)
        }
        
        do {
            try managedContext.save()
            self.fetchDataFromDB()
        } catch {
            print("Failed saving")
            self.showAlertMessage(message: "Failed saving")
        }
        
        DispatchQueue.main.async {
            SPIndicatorView.sharedInstance.hideActivityIndicator(uiView: self.view)
        }
    }
    
    
    @IBAction func layoutValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.collectionViewFlowLayout.display = .list
        case 1:
            self.collectionViewFlowLayout.display = .grid
        default:
            break
        }
    }
    func networkStatusManager(status: NetworkType) {
        
        switch status {
            
        case .offline:
            print("offline")
        case .wifi:
            print("wifi")
            self.hideAlertMessage()
            self.fetchDataFromDB()
        case .cellular:
            self.fetchDataFromDB()
            self.hideAlertMessage()
            print("cellular")
        }
    }
    
    func showAlertMessage(message:String)  {
       
       if let currentAlert = self.presentedViewController as? UIAlertController {
        currentAlert.message = message
           return
       }

            alert.message = message
                   let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                   
                   alert.addAction(okAction)
                   
                   present(alert, animated: true, completion: nil)
        
        
//       if ([self.navigationController.visibleViewController isKindOfClass:[UIAlertController class]]) {
//
//              // UIAlertController is presenting.Here
//
//        }
       
    }
    
    func hideAlertMessage()  {
        
        self.alert.dismiss(animated: true, completion: nil)
    }
}
