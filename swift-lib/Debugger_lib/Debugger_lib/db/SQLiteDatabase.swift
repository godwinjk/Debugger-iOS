//
//  SQLiteDatabase.swift
//  SwiftSQLite
//
//  Copyright (c) 2014-2017 Chris Simpson (chris.m.simpson@icloud.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

public class SQLiteDatabase {
    
    internal var cDb: OpaquePointer?
    
    public init() {
        
    }
    
    @discardableResult
    public func open(filename: String) -> SQLiteStatusCode? {
        
        if let cFilename = filename.cString(using: String.Encoding.utf8) {
            
            return SQLiteStatusCode(rawValue: sqlite3_open(cFilename, &self.cDb))
        }
        
        return nil
    }
    
    @discardableResult
    public class func delete(filename: String) -> Bool {
        
        var pathToDocuments = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let documentsDirectory = pathToDocuments[0]
        
        let databasePath = documentsDirectory.appending(filename)
        
        if FileManager.default.isReadableFile(atPath: databasePath) {
            
            do {
                
                try FileManager.default.removeItem(atPath: databasePath)
            }
            catch {
                
                print("Failed to delete database")
                return false
            }
        }
        
        return true
    }
    
    @discardableResult
    public class func createDatabase(withFilename filename: String, blankDatabaseFilename: String) -> Bool {
        
        if let pathToResources = Bundle.main.resourcePath, let blankDatabasePath = URL(string: pathToResources)?.appendingPathComponent(blankDatabaseFilename) {
            
            let pathToDocuments = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            
            if let documentsDirectoryString = pathToDocuments.first, let documentsDirectory = URL(string: documentsDirectoryString) {
                
                let databasePath = documentsDirectory.appendingPathComponent(filename)
                
                if !FileManager.default.isReadableFile(atPath: databasePath.path) {
                    
                    do {
                        
                        try FileManager.default.copyItem(at: blankDatabasePath, to: databasePath)
                    }
                    catch {
                        
                        return false
                    }
                }
                
                return true
            }
        }
        
        return false
    }
    
    // MARK: Transaction
    
    @discardableResult
    public func beginTransaction() -> SQLiteStatusCode? {
        
        if let cSqlQuery = "BEGIN TRANSACTION".cString(using: String.Encoding.utf8) {
            
            let rawStatusCode = sqlite3_exec(self.cDb, cSqlQuery, nil, nil, nil)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return nil
    }
    
    @discardableResult
    public func commitTransaction() -> SQLiteStatusCode? {
        
        if let cSqlQuery = "COMMIT TRANSACTION".cString(using: String.Encoding.utf8) {
            
            let rawStatusCode = sqlite3_exec(self.cDb, cSqlQuery, nil, nil, nil)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return nil
    }
    
    @discardableResult
    public func rollbackTransaction() -> SQLiteStatusCode? {
        
        if let cSqlQuery = "ROLLBACK TRANSACTION".cString(using: String.Encoding.utf8) {
            
            let rawStatusCode = sqlite3_exec(self.cDb, cSqlQuery, nil, nil, nil)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return nil
    }
    
    // MARK: Error
    
    public var errorMessage: String? {
        
        return String(cString: sqlite3_errmsg(self.cDb))
    }
}
