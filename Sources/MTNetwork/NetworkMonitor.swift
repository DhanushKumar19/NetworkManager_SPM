//
//  NetworkMonitor.swift
//  
//
//  Created by Dhanushkumar Kanagaraj on 06/11/22.
//

import Foundation
import Network

extension Notification.Name {
    public static let connectivityStatus = Notification.Name(rawValue: "connectivityStatusChanged")
}

extension NWInterface.InterfaceType: CaseIterable {
    public static var allCases: [NWInterface.InterfaceType] = [
        .other,
        .wifi,
        .cellular,
        .loopback,
        .wiredEthernet
    ]
}

public class NetworkMonitor {
    public static let shared = NetworkMonitor()
    
    private let queue = DispatchQueue(label: "NetworkConnectivityMonitor")
    private let monitor: NWPathMonitor
    
    public private(set) var isConnected = false
    public private(set) var isExpensive = false
    public private(set) var currentConnectionType: NWInterface.InterfaceType?
    
    // MARK: - Initialisers
    private init() {
        monitor = NWPathMonitor()
    }
    
    // MARK: - Custom Methods
    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status != .unsatisfied)
            self?.isExpensive = path.isExpensive
            self?.currentConnectionType = NWInterface.InterfaceType.allCases.filter { path.usesInterfaceType($0) }.first
            
            NotificationCenter.default.post(name: .connectivityStatus, object: nil)
        }
        monitor.start(queue: queue)
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
}
