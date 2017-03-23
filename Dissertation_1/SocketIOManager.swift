//
//  SocketIOManager.swift
//  Dissertation_1
//
//  Created by Christopher Carr on 06/03/2017.
//  Copyright © 2017 Christopher Carr. All rights reserved.
//

import UIKit
var urlString = "217.182.64.177:8000"
let url = URL(string: urlString)
class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    override init() {
        super.init()
    }
    
    let socket = SocketIOClient (socketURL: url!)
    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        SocketIOManager.sharedInstance.establishConnection()
    }
    func applicationDidEnterBackground(application: UIApplication) {
        SocketIOManager.sharedInstance.closeConnection()
    }
}
