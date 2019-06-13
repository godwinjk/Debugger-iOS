//
//  CommunicationManager.swift
//  Debugger_lib
//
//  Created by Godwin Joseph on 13/06/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Foundation
import SQLite3

public class CommunicationManager: NSObject,PTChannelDelegate {

    fileprivate var serverChannel : PTChannel?
    fileprivate var peerChannel : PTChannel?

    @objc
    func initializeSession(){

        serverChannel?.delegate = self
        let channel = PTChannel(delegate: self)
        channel?.listen(onPort: in_port_t(PTExampleProtocolIPv4PortNumber), iPv4Address: INADDR_LOOPBACK, callback: { error in
            if error != nil {
                if let error = error {
                    print("Failed to listen on 127.0.0.1:\(PTExampleProtocolIPv4PortNumber): \(error)")
                }
            } else {
                print("Listening on 127.0.0.1:\(PTExampleProtocolIPv4PortNumber)")
                self.serverChannel = channel
            }
        })
    }

    private func sendMessage(message : String){
        if peerChannel != nil{
            let dispatchData  = PTExampleTextDispatchDataWithString(message)
            peerChannel?.sendFrame(ofType: PTExampleFrameTypeTextMessage, tag: PTFrameNoTag, withPayload: dispatchData, callback: { (error) in
                print("Error occurred address")
            })
        }
    }

    public func ioFrameChannel(_ channel: PTChannel!, didReceiveFrameOfType type: UInt32, tag: UInt32, payload: PTData!) {

        if type == PTExampleFrameTypeTextMessage {

            let textData = payload.textFrameMessage
            print("Error occurred address \(textData)")

            let data = processResponse(request: textData)
            if data != nil{
                sendMessage(message: data!)
            }
        } else if type == PTExampleFrameTypePing && (peerChannel != nil) {
            peerChannel?.sendFrame(ofType: PTExampleFrameTypePong, tag: tag, withPayload: nil, callback: nil)
        }
    }

    public func ioFrameChannel(_ channel: PTChannel!, didEndWithError error: Error!) {
        print("Error occurred address ")
    }

    public func ioFrameChannel(_ channel: PTChannel!, didAcceptConnection otherChannel: PTChannel!, from address: PTAddress!) {
        if self.peerChannel != nil {
            self.peerChannel?.cancel()
        }
        self.peerChannel = otherChannel
        peerChannel?.userInfo = address
        print("Connected channel)")

        //        sendMessage(message: "Enna setupadave")
    }

    public func ioFrameChannel(_ channel: PTChannel!, shouldAcceptFrameOfType type: UInt32, tag: UInt32, payloadSize: UInt32) -> Bool {
        if channel != peerChannel {
            // A previous channel that has been canceled but not yet ended. Ignore.
            return false
        } else if type != PTExampleFrameTypeTextMessage && type != PTExampleFrameTypePing {
            print("Unexpected frame of type \(type)")
            channel.close()
            return false
        } else {
            return true
        }
    }



    private func processResponse(request: String) -> String?{
        let dbManager = DatabaseManager()
        do {
            let json = try? JSONSerialization.jsonObject(with: request.data(using: .utf8)!, options: [])

            if let dictionary = json as? [String: Any] {
                if let number = dictionary["rc"] as? Int {
                    // access individual value in dictionary
                    if number == 1000{
                        return try dbManager.listDatabases()
                    } else if number == 1001{
                        if let dbName = dictionary["db"] as? String {
                            return try dbManager.listTables(databaseName: dbName)
                        }
                    } else if number == 1002{
                        if let dbName = dictionary["db"] as? String, let tblName = dictionary["tbl"] as? String  {
                            return try dbManager.listTableDetails(tableName: tblName, databaseName: dbName)
                        }
                    }
                }
            }
        } catch{
            print("Error")
        }
        return ""
    }
}
