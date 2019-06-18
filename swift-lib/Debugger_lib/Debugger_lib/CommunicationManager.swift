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
                    if number == Constants.KEY_APP_DETAILS{
                        return try getAppDetails()
                    }else if number == Constants.KEY_DB_LIST{
                        return try dbManager.listDatabases()
                    } else if number == Constants.KEY_TABLES{
                        if let dbName = dictionary["db"] as? String {
                            return try dbManager.listTables(databaseName: dbName)
                        }
                    } else if number == Constants.KEY_TABLE_DETAILS{
                        if let dbName = dictionary["db"] as? String, let tblName = dictionary["tbl"] as? String  {
                            return try dbManager.listTableDetails(tableName: tblName, databaseName: dbName)
                        }
                    }else if number == Constants.KEY_QUERY{
                        if let dbName = dictionary["db"] as? String, let query = dictionary["query"] as? String  {
                            return try dbManager.getResults(databaseName: dbName, query: query)
                        }
                    }
                }
            }
        } catch{
            print("Error")
        }
        return ""
    }

    private func getAppDetails() throws -> String? {
        let icon = getIcon()
        let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String
        let bundleIdentifier = Bundle.main.bundleIdentifier
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String

        var root : [String: Any] = [:]
        root["rc"] = 1000
        root["icon"] = icon
        root["appName"] = appName
        root["id"] = bundleIdentifier
        root["build"] = build
        root["version"] = version

        let finalObj =  try JSONSerialization.data(withJSONObject: root, options: [])
        return String(data: finalObj, encoding: .utf8)
    }

    private func getIcon() -> String?{
        var icon: UIImage? {
            if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
                let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
                let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
                let lastIcon = iconFiles.last {
                return UIImage(named: lastIcon)
            }
            return nil
        }


        if icon != nil {
            var data  = icon?.pngData()
            return data?.base64EncodedString()
        }
        return nil
    }
}
