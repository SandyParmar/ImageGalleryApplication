//
//  ReachabilityManager.swift
//  ImageGalleryApplication
//
//  Created by Sandeep Parmar on 18/11/19.
//  Copyright © 2019 Sandeep Parmar. All rights reserved.
//

import UIKit


public enum NetworkType: Int {
    case offline, wifi, cellular
    
}

public protocol ReachabilityManagerDelegate {
    func networkStatusManager(status:NetworkType)
}

public class ReachabilityManager: NSObject {
    
    internal var reachability: Reachability?
    
    
    private override init() {
        super.init()
        self.stopNotifier()
        self.setupReachability("www.google.com", useClosures: true)
        self.startNotifier()
    }
    
    public static var sharedInstance : ReachabilityManager {
        get { return instance }
    }
    
    static let instance : ReachabilityManager = ReachabilityManager()
    
    public var networkDelegate : ReachabilityManagerDelegate? = nil
    
    
    func setupReachability(_ hostName: String, useClosures: Bool) {
        let reachability: Reachability?
        reachability = Reachability(hostname: hostName)
        self.reachability = reachability
        
        if useClosures {
            reachability?.whenReachable = { reachability in
                self.updateLabelColourWhenReachable(reachability)
            }
            reachability?.whenUnreachable = { reachability in
                self.updateLabelColourWhenNotReachable(reachability)
            }
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(reachabilityChanged(_:)),
                name: .reachabilityChanged,
                object: reachability
            )
        }
    }
    
   internal func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
   internal func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }
    
    internal func updateLabelColourWhenReachable(_ reachability: Reachability) {
        if reachability.connection == .wifi {
            self.networkDelegate?.networkStatusManager(status: .wifi)
        } else {
            self.networkDelegate?.networkStatusManager(status: .cellular)
        }
    }
    
    internal func updateLabelColourWhenNotReachable(_ reachability: Reachability) {

        self.networkDelegate?.networkStatusManager(status: .offline)
    }
    
    @objc internal func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.connection != .none {
            updateLabelColourWhenReachable(reachability)
        } else {
            updateLabelColourWhenNotReachable(reachability)
        }
    }
    
    deinit {
        stopNotifier()
    }
    
}
