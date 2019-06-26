//
//  CommunicationManager.swift
//  Debugger
//
//  Created by Godwin Joseph on 17/06/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class CommunicationManager: NSObject , PTChannelDelegate{

    private static var sInstance: CommunicationManager?

    var connectingToDeviceID: NSNumber?
    var connectedDeviceID_: NSNumber?
    var connectedDeviceProperties_: [AnyHashable : Any]?
    var remoteDeviceInfo_: [AnyHashable : Any] = [:]
    var notConnectedQueue_: DispatchQueue?
    var notConnectedQueueSuspended_ = false
    var connectedChannel_: PTChannel?
    var consoleTextAttributes_: [AnyHashable : Any] = [:]
    var consoleStatusTextAttributes_: [AnyHashable : Any] = [:]
    var pings_: [AnyHashable : Any] = [:]

    var communicationListener: CommunicationListener?

    public static func getInstance() -> CommunicationManager{
        if sInstance == nil {
            sInstance = CommunicationManager()
        }
        return sInstance!
    }

    private override init() {
        super.init()
        startListening()
    }
    public func setListener(listener : CommunicationListener){
        self.communicationListener = listener
    }

    private func startListening(){
        let nc = NotificationCenter.default

        nc.addObserver(forName: NSNotification.Name.PTUSBDeviceDidAttach, object: PTUSBHub.shared(), queue: nil, using: { note in
            let deviceID = note.userInfo?["DeviceID"] as? NSNumber
            if let deviceID = deviceID {
                print("PTUSBDeviceDidAttachNotification: \(deviceID)")
            }

            DispatchQueue.main.async(execute: {
                if !(self.connectingToDeviceID != nil) || !(deviceID == self.connectingToDeviceID) {
                    self.disconnectFromCurrentChannel()
                    self.connectingToDeviceID = deviceID
                    self.connectedDeviceID_ = deviceID
                    //                    self.connectedDeviceProperties_ = note.userInfo?["Properties"] as! [AnyHashable : Any]
                    self.enqueueConnectToUSBDevice()
                }
            })
        })
        nc.addObserver(forName: NSNotification.Name.PTUSBDeviceDidDetach, object: PTUSBHub.shared(), queue: nil, using: { note in
            let deviceID = note.userInfo?["DeviceID"] as? NSNumber
            //NSLog(@"PTUSBDeviceDidAttachNotification: %@", note.userInfo);
            if let deviceID = deviceID {
                print("PTUSBDeviceDidAttachNotification: \(deviceID)")
            }

            DispatchQueue.global().async(execute: {
                if !(self.connectingToDeviceID == nil) || (deviceID == self.connectingToDeviceID) {
                    self.connectingToDeviceID = nil
                    //                    self.connectedDeviceProperties_ = note.userInfo?["Properties"] as! [AnyHashable : Any]
                    if (self.connectedChannel_ != nil) {
                        self.connectedChannel_?.close()
                    }
                }
            })
        })
    }

     func disconnectFromCurrentChannel(){
        if (connectedDeviceID_ != nil && connectedChannel_ != nil) {
            self.connectedChannel_?.close()
            self.connectedChannel_ = nil;
        }
    }

     func didDisconnectFromDevice(deviceId: NSNumber){
        if connectedDeviceID_ == deviceId {
            self.connectedDeviceID_ = nil
            enqueueConnectToUSBDevice()
        }
    }

    @objc private func enqueueconnectToLocalIPv4Port(){
        DispatchQueue.main.async {
            self.connectToLocalIPv4Port()
        }
    }

    private func connectToLocalIPv4Port(){
        let channel = PTChannel(delegate: self)
        channel?.userInfo = "127.0.0.1:\(PTExampleProtocolIPv4PortNumber)"
        channel?.connect(toPort: in_port_t(PTExampleProtocolIPv4PortNumber), iPv4Address: INADDR_LOOPBACK, callback: { (error , ptAddress) in
            if (error != nil) {
                print("Error")
            }else {
                self.disconnectFromCurrentChannel()
                self.connectedChannel_ = channel
                channel?.userInfo = ptAddress

                let device = DDevice()
                device.connectedChannel = channel
                self.communicationListener?.onDeviceConnected(device: device)

                CallbackSubscriber.getInstance().publishDeviceConnected(device: device)
            }
            self.perform(#selector(self.enqueueconnectToLocalIPv4Port), with: nil, afterDelay: 1.0)
        })
    }

    @objc private func enqueueConnectToUSBDevice(){
        DispatchQueue.main.async {
            self.connectToUSBDevice()
        }
    }

    private func connectToUSBDevice(){
        let channel = PTChannel(delegate: self)
        channel?.delegate = self
        channel?.userInfo = connectingToDeviceID
        channel?.connect(toPort: PTExampleProtocolIPv4PortNumber, overUSBHub: PTUSBHub.shared(), deviceID: connectingToDeviceID) { (error) in
            if (error != nil) {
                print("Error")
                print("Failed to connect to device \(channel?.userInfo ?? "nil foudn on userinfo")");

                if (channel?.userInfo as? NSNumber == self.connectingToDeviceID) {
                    self.perform(#selector(self.enqueueConnectToUSBDevice), with: nil, afterDelay: 1.0)
                }
            }else {
                self.disconnectFromCurrentChannel()
                self.connectedChannel_ = channel

                let device = DDevice()
                device.connectedChannel = channel
                device.connectingToDeviceID = self.connectingToDeviceID

                self.communicationListener?.onDeviceConnected(device: device)

                CallbackSubscriber.getInstance().publishDeviceConnected(device: device)

                self.sendData(requestCode: 1000, database: nil, table: nil, query: nil)
            }
        }
    }


    func ioFrameChannel(_ channel: PTChannel!, shouldAcceptFrameOfType type: UInt32, tag: UInt32, payloadSize: UInt32) -> Bool {
        if (   type != PTExampleFrameTypeDeviceInfo
            && type != PTExampleFrameTypeTextMessage
            && type != PTExampleFrameTypePing
            && type != PTExampleFrameTypePong
            && type != PTFrameTypeEndOfStream) {
            print("Unexpected frame of type \(type)");
            channel.close()
            return false;
        } else {
            return true;
        }
    }

    func ioFrameChannel(_ channel: PTChannel!, didReceiveFrameOfType type: UInt32, tag: UInt32, payload: PTData!) {
        if type == PTExampleFrameTypeDeviceInfo{
            let deviceInfo = NSDictionary.init(contentsOfDispatchData: payload.dispatchData)
            print(deviceInfo?.description ?? "")
        }
        if type == PTExampleFrameTypeTextMessage {
            let textData = payload.textFrameMessage
            print("Data recieved \(textData)")
            communicationListener?.onGetMessage(data: textData)

            CallbackSubscriber.getInstance().publishGetMessage(device: nil, message: textData)

        } else if type == PTExampleFrameTypePing && (connectedChannel_ != nil) {
            connectedChannel_?.sendFrame(ofType: PTExampleFrameTypePong, tag: tag, withPayload: nil, callback: nil)
        }
    }

    func ioFrameChannel(_ channel: PTChannel!, didEndWithError error: Error!) {
        if connectedDeviceID_ != nil && connectedDeviceID_?.isEqual(to: channel.userInfo) ?? false{
            if connectedChannel_ == channel {
                let device = DDevice()
                device.connectedChannel = channel
                communicationListener?.onDeviceDisconnected(device: device)

                CallbackSubscriber.getInstance().publishDeviceDisconnected(device:  device)

                //disconnected
                didDisconnectFromDevice(deviceId: connectedDeviceID_!)
                connectedChannel_ = nil
                connectedDeviceID_ = nil
            }
        }
    }

    private func processRequest(requestCode : Int, database : DDatabase? , table : DTable?, query: String?) -> String?{

        var root = [String : Any]()
        root["rc"] = requestCode
        if database != nil {
            root["db"] = database?.fullPath
            if table != nil {
                root["tbl"] = table?.name
            }
            if query != nil {
                root["query"] = query!
            }
        }
        let data = try! JSONSerialization.data(withJSONObject: root, options: [])
        return String(data: data, encoding: .utf8)
    }

    private func sendMessage(message : String){
        if connectedChannel_ != nil{
            let dispatchData  = PTExampleTextDispatchDataWithString(message)
            connectedChannel_?.sendFrame(ofType: PTExampleFrameTypeTextMessage, tag: PTFrameNoTag, withPayload: dispatchData, callback: { (error) in
                if (error != nil){
                    print("Error occurred address")
                }
            })
        }
    }

    public func sendData(requestCode : Int, database : DDatabase? , table : DTable?, query: String?){
        let message = self.processRequest(requestCode: requestCode,database: database,table: table, query: query)
        if message != nil {
            self.sendMessage(message: message!)
        }
    }
}
