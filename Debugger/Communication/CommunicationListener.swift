//
//  CommunicationListener.swift
//  Debugger
//
//  Created by Godwin Joseph on 17/06/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

protocol CommunicationListener : class {
    func onDeviceConnected(device : DDevice)
    func onDeviceDisconnected(device : DDevice)

    func onGetMessage(data : String)
}
