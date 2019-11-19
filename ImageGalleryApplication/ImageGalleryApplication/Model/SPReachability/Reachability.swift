//
//  Reachability.swift
//  ImageGalleryApplication
//
//  Created by Sandeep Parmar on 18/11/19.
//  Copyright © 2019 Sandeep Parmar. All rights reserved.
//

import SystemConfiguration
import Foundation

public enum ReachabilityError: Error {
    case FailedToCreateWithAddress(sockaddr_in)
    case FailedToCreateWithHostname(String)
    case UnableToSetCallback
    case UnableToSetDispatchQueue
    case UnableToGetInitialFlags
}

@available(*, unavailable, renamed: "Notification.Name.reachabilityChanged")
public let ReachabilityChangedNotification = NSNotification.Name("ReachabilityChangedNotification")

public extension Notification.Name {
    static let reachabilityChanged = Notification.Name("reachabilityChanged")
}

public class Reachability {
    
    internal typealias NetworkReachable = (Reachability) -> ()
    internal typealias NetworkUnreachable = (Reachability) -> ()
    
  
    internal enum NetworkStatus: CustomStringConvertible {
        case notReachable, reachableViaWiFi, reachableViaWWAN
        public var description: String {
            switch self {
            case .reachableViaWWAN: return "Cellular"
            case .reachableViaWiFi: return "WiFi"
            case .notReachable: return "No Connection"
            }
        }
    }
    
    internal enum Connection: CustomStringConvertible {
        case none, wifi, cellular
        public var description: String {
            switch self {
            case .cellular: return "Cellular"
            case .wifi: return "WiFi"
            case .none: return "No Connection"
            }
        }
    }
    
    internal var whenReachable: NetworkReachable?
    internal var whenUnreachable: NetworkUnreachable?

    internal let reachableOnWWAN: Bool = true
    
    /// Set to `false` to force Reachability.connection to .none when on cellular connection (default value `true`)
    internal var allowsCellularConnection: Bool
    
    // The notification center on which "reachability changed" events are being posted
    internal var notificationCenter: NotificationCenter = NotificationCenter.default
    
  
    internal var currentReachabilityString: String {
        return "\(connection)"
    }
    
   
    internal var currentReachabilityStatus: Connection {
        return connection
    }
    
    internal var connection: Connection {
        if flags == nil {
            try? setReachabilityFlags()
        }
        
        switch flags?.connection {
        case .none?, nil: return .none
        case .cellular?: return allowsCellularConnection ? .cellular : .none
        case .wifi?: return .wifi
        }
    }
    
    fileprivate var isRunningOnDevice: Bool = {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }()
    
    fileprivate var notifierRunning = false
    fileprivate let reachabilityRef: SCNetworkReachability
    fileprivate let reachabilitySerialQueue: DispatchQueue
    fileprivate(set) var flags: SCNetworkReachabilityFlags? {
        didSet {
            guard flags != oldValue else { return }
            reachabilityChanged()
        }
    }
    
    required internal init(reachabilityRef: SCNetworkReachability, queueQoS: DispatchQoS = .default, targetQueue: DispatchQueue? = nil) {
        self.allowsCellularConnection = true
        self.reachabilityRef = reachabilityRef
        self.reachabilitySerialQueue = DispatchQueue(label: "com.sp.reachability", qos: queueQoS, target: targetQueue)
    }
    
    internal convenience init?(hostname: String, queueQoS: DispatchQoS = .default, targetQueue: DispatchQueue? = nil) {
        guard let ref = SCNetworkReachabilityCreateWithName(nil, hostname) else { return nil }
        self.init(reachabilityRef: ref, queueQoS: queueQoS, targetQueue: targetQueue)
    }
    
    internal convenience init?(queueQoS: DispatchQoS = .default, targetQueue: DispatchQueue? = nil) {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let ref = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else { return nil }
        
        self.init(reachabilityRef: ref, queueQoS: queueQoS, targetQueue: targetQueue)
    }
    
    deinit {
        stopNotifier()
    }
}

extension Reachability {
    
    // MARK: - *** Notifier methods ***
   internal func startNotifier() throws {
        guard !notifierRunning else { return }
        
        let callback: SCNetworkReachabilityCallBack = { (reachability, flags, info) in
            guard let info = info else { return }
            
            let reachability = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
            reachability.flags = flags
        }
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutableRawPointer(Unmanaged<Reachability>.passUnretained(self).toOpaque())
        if !SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
            stopNotifier()
            throw ReachabilityError.UnableToSetCallback
        }
        
        if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef, reachabilitySerialQueue) {
            stopNotifier()
            throw ReachabilityError.UnableToSetDispatchQueue
        }
        
        // Perform an initial check
        try setReachabilityFlags()
        
        notifierRunning = true
    }
    
    internal func stopNotifier() {
        defer { notifierRunning = false }
        
        SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
    }
    
    // MARK: - *** Connection test methods ***
   internal var isReachable: Bool {
        return connection != .none
    }

    internal var isReachableViaWWAN: Bool {
        // Check we're not on the simulator, we're REACHABLE and check we're on WWAN
        return connection == .cellular
    }
    
   internal var isReachableViaWiFi: Bool {
        return connection == .wifi
    }

}

fileprivate extension Reachability {
    
    func setReachabilityFlags() throws {
        try reachabilitySerialQueue.sync { [unowned self] in
            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) {
                self.stopNotifier()
                throw ReachabilityError.UnableToGetInitialFlags
            }
            
            self.flags = flags
        }
    }
    
    func reachabilityChanged() {
        let block = connection != .none ? whenReachable : whenUnreachable
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            block?(self)
            self.notificationCenter.post(name: .reachabilityChanged, object: self)
        }
    }
}

extension SCNetworkReachabilityFlags {
    
    typealias Connection = Reachability.Connection
    
   internal var connection: Connection {
        guard isReachableFlagSet else { return .none }
        
        // If we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
        #if targetEnvironment(simulator)
        return .wifi
        #else
        var connection = Connection.none
        
        if !isConnectionRequiredFlagSet {
            connection = .wifi
        }
        
        if isConnectionOnTrafficOrDemandFlagSet {
            if !isInterventionRequiredFlagSet {
                connection = .wifi
            }
        }
        
        if isOnWWANFlagSet {
            connection = .cellular
        }
        
        return connection
        #endif
    }
    
  internal  var isOnWWANFlagSet: Bool {
        #if os(iOS)
        return contains(.isWWAN)
        #else
        return false
        #endif
    }
  internal  var isReachableFlagSet: Bool {
        return contains(.reachable)
    }
   internal var isConnectionRequiredFlagSet: Bool {
        return contains(.connectionRequired)
    }
   internal var isInterventionRequiredFlagSet: Bool {
        return contains(.interventionRequired)
    }
   internal var isConnectionOnTrafficFlagSet: Bool {
        return contains(.connectionOnTraffic)
    }
   internal var isConnectionOnDemandFlagSet: Bool {
        return contains(.connectionOnDemand)
    }
   internal var isConnectionOnTrafficOrDemandFlagSet: Bool {
        return !intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }
   internal var isTransientConnectionFlagSet: Bool {
        return contains(.transientConnection)
    }
   internal var isLocalAddressFlagSet: Bool {
        return contains(.isLocalAddress)
    }
  internal  var isDirectFlagSet: Bool {
        return contains(.isDirect)
    }
   internal var isConnectionRequiredAndTransientFlagSet: Bool {
        return intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
    }
}
