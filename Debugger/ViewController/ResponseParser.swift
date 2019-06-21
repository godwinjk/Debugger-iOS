//
//  ResponseParser.swift
//  Debugger
//
//  Created by Godwin Joseph on 11/06/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class ResponseParser: NSObject {

    public func parseCode(data : String) -> Int{
        let json = try? JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: [])
        if let dictionary = json as? [String: Any] {
            return dictionary["rc"] as? Int ?? 0
        }
        return 0
    }

    public func parseAppDetails(data : String) -> (DApplication, String?, String?){
        var application = DApplication()

        let json = try? JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: [])


        if let dictionary = json as? [String: Any] {

            let errorCode = dictionary["errorCode"] as? String
            let errorMessage = dictionary["errorMessage"] as? String

            if errorCode != nil {
                return (application,errorCode,errorMessage)
            }

            let appName = dictionary["appName"] as? String
            let bundleId = dictionary["id"] as? String
            let icon = dictionary["icon"] as? String
            let build = dictionary["build"] as? String
            let version = dictionary["version"] as? String

            application.applicationName = appName ?? "Dummy Name"
            application.applicationId = bundleId  ?? "com.godwin.bundle"
            application.iconString = icon
            application.build = build  ?? "0"
            application.version = version ?? "0.0.0"
        }

        return(application,nil,nil)
    }
    public func parseDatabases(data : String) -> ([DDatabase]?, String?, String?){
        let json = try? JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: [])

        var dbs = [DDatabase]()

        if let dictionary = json as? [String: Any] {
            if let arr = dictionary["Error"] as? [String: Any]  {
                let errorCode = arr["errorCode"] as? String
                let errorMessage = arr["errorMessage"] as? String
                return (nil,errorCode,errorMessage)
            }
            if let arr = dictionary["Data"] as? [String] {
                // access individual value in dictionary
                for path in arr {
                    let db = DDatabase()
                    let url =  URL(fileURLWithPath: path)
                    db.name = url.lastPathComponent
                    db.fullPath = path

                    dbs.append(db)
                }
            }
        }

        return (dbs,nil,nil)
    }

    public func parseTable(data : String) -> ([DTable]?, String?, String?){
        let json = try? JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: [])

        var dbs = [DTable]()

        if let dictionary = json as? [String: Any] {
            if let arr = dictionary["Error"] as? [String: Any]  {
                let errorCode = arr["errorCode"] as? String
                let errorMessage = arr["errorMessage"] as? String
                return (nil,errorCode,errorMessage)
            }
            if let arr = dictionary["Data"] as? [String] {
                // access individual value in dictionary
                for name in arr {
                    let table = DTable()
                    table.name = name

                    dbs.append(table)
                }
            }
        }

        return (dbs,nil,nil)
    }

    public func parseTableDetails(data : String,table : DTable) -> (DTable?, String?, String?){

        let json = try? JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: [])

        if let dictionary = json as? [String: Any] {

            if let arr = dictionary["Error"] as? [String: Any]  {
                let errorCode = arr["errorCode"] as? String
                let errorMessage = arr["errorMessage"] as? String
                return (nil,errorCode,errorMessage)
            }

            if let dict = dictionary["Data"] as? [String : Any] {

                let columnCount = dict["columnCount"] as? Int
                let rowCount = dict["rowCount"] as? Int
                let names = dict["names"] as? [String]
                let details = dict["details"] as? [[String]]

                table.coloumnCount = columnCount!
                table.rowCount = rowCount!

                table.columnNames = names!
                table.rows = details!

                return (table,nil,nil)
            }
        }

        return (nil,nil,nil)
    }
}
