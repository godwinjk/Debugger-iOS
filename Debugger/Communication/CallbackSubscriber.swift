//
//  CallbackSubscriber.swift
//  Debugger
//
//  Created by Godwin Joseph on 17/06/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class CallbackSubscriber {
    static let sInstance = CallbackSubscriber ()

    private init() {
        //restrict object creation
    }

    public static func getInstance() -> CallbackSubscriber{
        return sInstance
    }

    var callbackList: [CommunicationListener] = []

    public func subscribe(callback: CommunicationListener){
        if  !callbackList.contains { $0 === callback }{
            callbackList.append(callback)
        }
    }

    public func unSubscribe(callback: CommunicationListener){
        let index = callbackList.firstIndex { $0 === callback }
        if (index != nil && index! > 0) {
            callbackList.remove(at: index!)
        }
    }

    public func getSubscriberCount() -> Int {
        return callbackList.count
    }

    func publishDeviceConnected(device: DDevice){
        for callback in callbackList {
            if let c = callback as? CommunicationListener{
                c.onDeviceConnected(device: device)
            }
        }
    }

    func publishDeviceDisconnected(device: DDevice){
        for callback in callbackList {
            if let c = callback as? CommunicationListener{
                c.onDeviceDisconnected(device: device)
            }
        }
    }

    func publishGetMessage(device: DDevice?,message: String){
        for callback in callbackList {
            if let c = callback as? CommunicationListener{
                c.onGetMessage(data: message)
            }
        }
    }
}
