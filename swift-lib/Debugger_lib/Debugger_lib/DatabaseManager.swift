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

        var databases = DebuggerIos.getInstance().getDbPaths()
        if databases.count <= 0 {
            databases = searchDatabaseFiles(directory: nil, files: &databases)
        }
        var dictionary : [String: Any] = [:]
        dictionary["rc"] = Constants.KEY_DB_LIST
        var dbs: [String] = []
        for db in databases {
            dbs.append(db)
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
        root["rc"] = Constants.KEY_TABLES
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
        root["rc"] = Constants.KEY_TABLE_DETAILS
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

    public func getResults( databaseName : String , query : String)  throws -> String?{
        let database = SQLiteDatabase()
        _ = database.open(filename: databaseName)
        let statement = SQLiteStatement(database: database)
        if let status = statement.prepare(sqlQuery: query) {
            /* handle error */
            print(status)
            if status != .ok {
                return try createErrorBlockForQuery(status: status)
            }
        }

        var root : [String: Any] = [:]
        root["rc"] = Constants.KEY_QUERY
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

    //  MARK: private funcs
    private func getDatabases() -> [URL]?{
        let urls = getAllFiles(directory: nil)
        let databaseDirectory = filter(urls: urls)
        let dbArrays = getAllFiles(directory: databaseDirectory)
        let databases = filterDatabase(urls: dbArrays)
        return databases
    }

    private func searchDatabaseFiles(directory: URL?,files: inout [String]) -> [String]{
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
        if fileURLs != nil {
            for url in fileURLs! {
                if url.hasDirectoryPath {
                    searchDatabaseFiles(directory: url, files: &files)
                }else if isDatabaseFile(url:  url){
                    files.append(url.path)
                }
            }
        }
        return files
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

    private func isDatabaseFile(url: URL) ->  Bool{
        let extensions = ["db", "sqlite", "sqlite3"]

        for pathExtension in extensions {
            if pathExtension == url.pathExtension {
                return true
            }
        }
        return false
    }

    private func createErrorBlockForQuery(status: SQLiteStatusCode) throws -> String?{
        var root : [String: Any] = [:]
        root["rc"] = Constants.KEY_QUERY

        var data : [String: Any] = [:]
        data["errorCode"] = "\(status)"

        switch status {
        case .ok :
            data["errorMessage"] =  "Successful result "
            /* beginning-of-error-codes */
            case .error :
                data["errorMessage"] = "SQL error or missing database "
            case .internalLogicError :
                data["errorMessage"] = "Internal logic error in SQLite "
            case .accessPermissionDenied :
                data["errorMessage"] = "Access permission denied "
            case .abort :
                data["errorMessage"] = "Callback routine requested an abort "
            case .busy :
                data["errorMessage"] = "The database file is locked "
            case .locked :
                data["errorMessage"] = "A table in the database is locked "
            case .noMemory :
                data["errorMessage"] = "A malloc() failed "
            case .readOnly :
                data["errorMessage"] = "Attempt to write a readonly database "
            case .interrupt :
                data["errorMessage"] = "Operation terminated by sqlite3_interrupt()"
            case .ioError :
                data["errorMessage"] = "Some kind of disk I/O error occurred "
            case .corrupt :
                data["errorMessage"] = "The database disk image is malformed "
            case .notFound :
                data["errorMessage"] = "Unknown opcode in sqlite3_file_control() "
            case .full :
                data["errorMessage"] = "Insertion failed because database is full "
            case .cantOpen :
                data["errorMessage"] = "Unable to open the database file "
            case .`protocol` :
                data["errorMessage"] = "Database lock protocol error "
            case .empty :
                data["errorMessage"] = "Database is empty "
            case .schema :
                data["errorMessage"] = "The database schema changed "
            case .tooBig :
                data["errorMessage"] = "String or BLOB exceeds size limit "
            case .constraint :
                data["errorMessage"] = "Abort due to constraint violation "
            case .mismatch :
                data["errorMessage"] = "Data type mismatch "
            case .misuse :
                data["errorMessage"] = "Library used incorrectly "
            case .noLFS :
                data["errorMessage"] = "Uses OS features not supported on host "
            case .authDeniedUTH :
                data["errorMessage"] = "Authorization denied "
            case .format :
                data["errorMessage"] = "Auxiliary database format error "
            case .range :
                data["errorMessage"] = "2nd parameter to sqlite3_bind out of range "
            case .notADatabase :
                data["errorMessage"] = "File opened that is not a database file "
            case .row :
                data["errorMessage"] = "sqlite3_step() has another row ready "
            case .done :
                data["errorMessage"] = "sqlite3_step() has finished executing "
            }

        root["Error"] = data

        let finalObj =  try JSONSerialization.data(withJSONObject: root, options: [])
        return String(data: finalObj, encoding: .utf8)
    }
}
