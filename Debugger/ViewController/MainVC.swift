//
//  MainVC.swift
//  Debugger
//
//  Created by Godwin Joseph on 25/04/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class MainVC: NSViewController, PTChannelDelegate, ClickDelegate{



    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var dbList: NSOutlineView!
    @IBOutlet weak var dbTableView: NSTableView!
    
    var selectedDatabase : DDatabase?
    var selectedTable : DTable?

    var outlineView: DatabaseOutlineView!
    var tableView: DatabaseTableView!

    var connectingToDeviceID_: NSNumber?
    var connectedDeviceID_: NSNumber?
    var connectedDeviceProperties_: [AnyHashable : Any]?
    var remoteDeviceInfo_: [AnyHashable : Any] = [:]
    var notConnectedQueue_: DispatchQueue?
    var notConnectedQueueSuspended_ = false
    var connectedChannel_: PTChannel?
    var consoleTextAttributes_: [AnyHashable : Any] = [:]
    var consoleStatusTextAttributes_: [AnyHashable : Any] = [:]
    var pings_: [AnyHashable : Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        outlineView = DatabaseOutlineView(outlineView: dbList,delegate: self)
        tableView = DatabaseTableView(tableView: dbTableView)
        

//        enqueueconnectToLocalIPv4Port()
    }

    override func viewDidAppear() {
        perform(#selector(startListening), with: nil, afterDelay: 2)
//        startListening()
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
//            loadData()
        }
    }

    public func sendMessage(message : String){
        if connectedChannel_ != nil{
            let dispatchData  = PTExampleTextDispatchDataWithString(message)
            connectedChannel_?.sendFrame(ofType: PTExampleFrameTypeTextMessage, tag: PTFrameNoTag, withPayload: dispatchData, callback: { (error) in
                if (error != nil){
                    print("Error occurred address")
                }
            })
        }
    }

   @objc private func startListening(){
        let nc = NotificationCenter.default

        nc.addObserver(forName: NSNotification.Name.PTUSBDeviceDidAttach, object: PTUSBHub.shared(), queue: nil, using: { note in
            let deviceID = note.userInfo?["DeviceID"] as? NSNumber
            if let deviceID = deviceID {
                print("PTUSBDeviceDidAttachNotification: \(deviceID)")
            }

            DispatchQueue.main.async(execute: {
                if !(self.connectingToDeviceID_ != nil) || !(deviceID == self.connectingToDeviceID_) {
                    self.disconnectFromCurrentChannel()
                    self.connectingToDeviceID_ = deviceID
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
                if !(self.connectingToDeviceID_ == nil) || (deviceID == self.connectingToDeviceID_) {
                    self.connectingToDeviceID_ = nil
//                    self.connectedDeviceProperties_ = note.userInfo?["Properties"] as! [AnyHashable : Any]
                    if (self.connectedChannel_ != nil) {
                        self.connectedChannel_?.close()
                    }
                }
            })
        })
    }

    private func disconnectFromCurrentChannel(){
        if (connectedDeviceID_ != nil && connectedChannel_ != nil) {
            self.connectedChannel_?.close()
            self.connectedChannel_ = nil;
        }
    }

    private func didDisconnectFromDevice(deviceId: NSNumber){
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
        channel?.userInfo = connectingToDeviceID_
        channel?.connect(toPort: PTExampleProtocolIPv4PortNumber, overUSBHub: PTUSBHub.shared(), deviceID: connectingToDeviceID_) { (error) in
            if (error != nil) {
                print("Error")
                print("Failed to connect to device \(channel?.userInfo ?? "nil foudn on userinfo")");

                if (channel?.userInfo as? NSNumber == self.connectingToDeviceID_) {
                    self.perform(#selector(self.enqueueConnectToUSBDevice), with: nil, afterDelay: 1.0)
                }
            }else {
                self.disconnectFromCurrentChannel()
                self.connectedChannel_ = channel

                self.sendData(requestCode: 1000, database: nil, table: nil)
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
            processResponse(response: textData)
            print("kitya data \(textData)")
        } else if type == PTExampleFrameTypePing && (connectedChannel_ != nil) {
            connectedChannel_?.sendFrame(ofType: PTExampleFrameTypePong, tag: tag, withPayload: nil, callback: nil)
        }
    }

    func ioFrameChannel(_ channel: PTChannel!, didEndWithError error: Error!) {
        if connectedDeviceID_ != nil && connectedDeviceID_?.isEqual(to: channel.userInfo) ?? false{
            if connectedChannel_ == channel {
                //disconnected
                didDisconnectFromDevice(deviceId: connectedDeviceID_!)
                connectedChannel_ = nil
            }
        }
    }

    private func processResponse(response : String){
        let parser = ResponseParser()
        let code =   parser.parseCode(data: response)
        if code == 1000 {
            outlineView.setData(data: parser.parseDatabases(data: response) ?? [])
        }else if code == 1001{
            outlineView.setData(db: selectedDatabase!, tables: parser.parseTable(data: response) ?? [])
        }else if code == 1002{
            tableView.setData(table: parser.parseTableDetails(data: response, table: selectedTable!) ?? DTable())
        }
    }

    private func processRequest(requestCode : Int, database : DDatabase? , table : DTable?) -> String?{

        var root = [String : Any]()
        root["rc"] = requestCode
        if database != nil {
            root["db"] = database?.fullPath
            if table != nil {
                root["tbl"] = table?.name
            }
        }
        let data = try! JSONSerialization.data(withJSONObject: root, options: [])
        return String(data: data, encoding: .utf8)
    }

    private func sendData(requestCode : Int, database : DDatabase? , table : DTable?){
        let message = self.processRequest(requestCode: requestCode,database: database,table: table)
        if message != nil {
            self.sendMessage(message: message!)
        }
    }
    func onClick(obj: Any, index: Int) {
        if let database = obj as? DDatabase {
            self.selectedDatabase = database
            sendData(requestCode: 1001, database: self.selectedDatabase,  table: nil)
        }else  if let table = obj as? DTable {
            self.selectedTable = table
            sendData(requestCode: 1002, database: self.selectedDatabase, table: self.selectedTable)
        }
    }
}
