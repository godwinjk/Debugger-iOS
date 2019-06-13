//
//  DatabaseManager.swift
//  Debugger_app_lib
//
//  Created by Godwin Joseph on 27/05/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Foundation
import SQLite3

class DatabaseManager{
    
    let QUERY_TABLENAMES_SQL = "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
    public var handle: OpaquePointer { return _handle! }

    fileprivate var _handle: OpaquePointer? = nil

    public func listDatabases() throws -> String? {

        let databases = getDatabases()
        var dictionary : [String: Any] = [:]
        dictionary["rc"] = 1000
        var dbs: [String] = []
        for db in databases! {
            dbs.append(db.path)
        }

        dictionary["Data"] = dbs

        let finalObj =  try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return String(data: finalObj, encoding: .utf8)
    }

    public func listTables(databaseName : String) throws -> String? {
        let database = SQLiteDatabase()
        _ =    database.open(filename: databaseName)
        let statement = SQLiteStatement(database: database)
        if statement.prepare(sqlQuery: "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name") != .ok {
            /* handle error */
            print("Error")
        }

        var root : [String: Any] = [:]
        root["rc"] = 1001
        var tables: [String] = []
        while (statement.step() == .row){
            for i in 0..<statement.columnCount(){
                tables.append(statement.string(at: i) ?? "")
            }
        }
        root["Data"] = tables
        statement.finalizeStatement()

        let finalObj =  try JSONSerialization.data(withJSONObject: root, options: [])
        return String(data: finalObj, encoding: .utf8)
    }

    public func listTableDetails(tableName : String, databaseName : String) throws -> String? {
        let database = SQLiteDatabase()
        _ = database.open(filename: databaseName)
        let statement = SQLiteStatement(database: database)
        if statement.prepare(sqlQuery: "SELECT * FROM \(tableName)") != .ok {
            /* handle error */
            print("Error")
        }

        var root : [String: Any] = [:]
        root["rc"] = 1002
        var coulumnNames : [String] = []
        let columnCount = statement.columnCount()
        for i in 0..<columnCount{
            coulumnNames.append(statement.columnName(at: i) ?? "")
        }

        var rows: [[String]] = []
        var rowIndex = 0
        while (statement.step() == .row){
            var row = [String]()

            for j in 0..<columnCount{
                row.append(statement.string(at: j) ?? "")
            }
            rows.append(row)
            rowIndex += 1
        }

        statement.finalizeStatement()
        var data : [String: Any] = [:]
        data["columnCount"] = columnCount
        data["rowCount"] = rowIndex
        data["names"] = coulumnNames
        data["details"] = rows

        root["Data"] = data

        let finalObj =  try JSONSerialization.data(withJSONObject: root, options: [])
        return String(data: finalObj, encoding: .utf8)
    }

    public func getDatabases() -> [URL]?{
        let urls = getAllFiles(directory: nil)
        let databaseDirectory = filter(urls: urls)
        let dbArrays = getAllFiles(directory: databaseDirectory)
        let databases = filterDatabase(urls: dbArrays)
        return databases
    }

    private func getAllFiles(directory: URL?)-> [URL]? {
        let fileManager = FileManager.default
        var documentsURL : URL
        if directory == nil {
            documentsURL =  fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }else {
          documentsURL  = directory!;
        }

        var fileURLs:[URL]?
        do {
            fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        return fileURLs
    }

    private func filter(urls: [URL]?)-> URL?{
        if (urls !=  nil) {
            for url in urls! {

                if url.absoluteString.contains("DataBase")  {
                    return url
                }
            }
        }
        return nil
    }
    
    private func filterDatabase(urls: [URL]?) ->  [URL]?{
        let extensions = ["db", "sqlite", "sqlite3"]
        var  filteredFiles : [URL] = []
        if (urls !=  nil)  {
            for url in urls! {
                for pathExtension in extensions {
                    if pathExtension == url.pathExtension  {
                        filteredFiles.append(url)
                    }
                }
            }
        }
        return filteredFiles
    }
}
