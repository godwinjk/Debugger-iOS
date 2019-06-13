//
//  SQLiteStatement.swift
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

let isoStringFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"

// Taken from: http://stackoverflow.com/questions/30760353/cannot-invoke-initializer-for-type-sqlite3-destructor-type

internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

public extension Date {
    
    public func toString() -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = isoStringFormat
        
        return dateFormatter.string(from: self)
    }
}

public extension String {
    
    public func toDate() -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = isoStringFormat
        
        return dateFormatter.date(from: self)
    }
}

public class SQLiteStatement: NSObject {
    
    // Swift
    internal var database: SQLiteDatabase
    
    // C
    internal var cStatement: OpaquePointer?
    
    public init(database: SQLiteDatabase) {
        
        self.database = database
    }
    
    // MARK: Prepare
    
    @discardableResult
    public func prepare(sqlQuery: String) -> SQLiteStatusCode? {
        
        if let cSqlQuery = sqlQuery.cString(using: String.Encoding.utf8) {
            
            let rawStatusCode = sqlite3_prepare_v2(self.database.cDb, cSqlQuery, -1, &self.cStatement, nil)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return nil
    }
    
    // MARK: Reset
    
    @discardableResult
    public func reset() -> SQLiteStatusCode? {
        
        if let cStatement = self.cStatement {
            
            let rawStatusCode = sqlite3_reset(cStatement)
        
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return nil
    }
    
    // MARK: Binding
    
    @discardableResult
    public func bindNull(at index: Int) -> SQLiteStatusCode? {
        
        if let cStatement = self.cStatement {
        
            let rawStatusCode = sqlite3_bind_null(cStatement, Int32(index))
        
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return nil
    }
    
    @discardableResult
    public func bind(string: String?, at index: Int) -> SQLiteStatusCode? {
        
        if let cStatement = self.cStatement, let _string = string, let cStringValue = _string.cString(using: String.Encoding.utf8) {
            
            let rawStatusCode = sqlite3_bind_text(cStatement, Int32(index), cStringValue, -1, SQLITE_TRANSIENT)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return bindNull(at: index)
    }
    
    @discardableResult
    public func bind(date: Date?, at index: Int) -> SQLiteStatusCode? {
        
        if let cStatement = self.cStatement, let _date = date, let cString = _date.toString()?.cString(using: String.Encoding.utf8) {
            
            let rawStatusCode = sqlite3_bind_text(cStatement, Int32(index), cString, -1, SQLITE_TRANSIENT)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return self.bindNull(at: index)
    }
    
    @discardableResult
    public func bind(primaryKeyInt: Int?, at index: Int) -> SQLiteStatusCode? {
        
        if let _primaryKeyInt = primaryKeyInt, _primaryKeyInt > 0 {
            
            return self.bind(int: _primaryKeyInt, at: index)
        }
        
        return self.bindNull(at: index)
    }
    
    @discardableResult
    public func bind(int: Int?, at index: Int) -> SQLiteStatusCode? {
        
        if let cStatement = self.cStatement, let _int = int {
            
            let rawStatusCode = sqlite3_bind_int(cStatement, Int32(index), Int32(_int))
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return self.bindNull(at: index)
    }
    
    @discardableResult
    public func bind(bool: Bool?, at index: Int) -> SQLiteStatusCode? {
        
        if let cStatement = self.cStatement, let _bool = bool {
            
            let intValue: Int32 = _bool ? 1 : 0
            
            let rawStatusCode = sqlite3_bind_int(cStatement, Int32(index), intValue)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return self.bindNull(at: index)
    }
    
    @discardableResult
    public func bind(data: Data?, at index: Int) -> SQLiteStatusCode? {
        
        if let cStatement = self.cStatement, let _data = data, _data.count > 0 {
            
            let rawStatusCode = sqlite3_bind_blob(cStatement, Int32(index), (_data as NSData).bytes, Int32(_data.count), nil)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return self.bindNull(at: index)
    }
    
    @discardableResult
    public func bind(double: Double?, at index: Int) -> SQLiteStatusCode? {
        
        if let cStatement = self.cStatement, let _double = double {
            
            let rawStatusCode = sqlite3_bind_double(cStatement, Int32(index), _double)
            
            return SQLiteStatusCode(rawValue: rawStatusCode)
        }
        
        return self.bindNull(at: index)
    }
    
    // MARK: Getters
    
    public func string(at column: Int) -> String? {
        
        if let cStatement = self.cStatement, let cString = sqlite3_column_text(cStatement, Int32(column)) {
            
            let cStringPtr = UnsafePointer<UInt8>(cString)
            
            return String(cString: cStringPtr)
        }
        else {
            return nil
        }
    }
    
    public func int(at column: Int) -> Int? {
        
        if let cStatement = self.cStatement {
            
            return Int(sqlite3_column_int(cStatement, Int32(column)))
        }
        
        return nil
    }
    
    public func bool(at column: Int) -> Bool? {
        
        if let cStatement = self.cStatement {
            
            let intValue = sqlite3_column_int(cStatement, Int32(column))
        
            return intValue != 0
        }
        
        return nil
    }
    
    public func date(at column: Int) -> Date? {
        
        if let cString = sqlite3_column_text(self.cStatement, Int32(column)) {
            
            let cStringPtr = UnsafePointer<UInt8>(cString)
            
            return String(cString: cStringPtr).toDate()
        }
        else {
            
            return nil
        }
    }
    
    public func double(at column: Int) -> Double? {
        
        if let cStatement = self.cStatement {
            return Double(sqlite3_column_double(cStatement, Int32(column)))
        }
        
        return nil
    }
    
    public func data(at column: Int) -> Data? {
        
        if let cStatement = self.cStatement {
            
            let _column = Int32(column)
            
            if let pointer = sqlite3_column_blob(cStatement, _column) {
                
                let numberOfBytes = Int(sqlite3_column_bytes(cStatement, _column))
                
                return Data(bytes: pointer, count: numberOfBytes)
            }
        }
        
        return nil
    }
    
    public func columnCount() -> Int{
        if let cStatement = self.cStatement {
            return Int(sqlite3_column_count(cStatement ))
        }

        return -1
    }

    public func columnName(at column: Int) -> String?{
        if let cStatement = self.cStatement, let cString = sqlite3_column_name(cStatement, Int32(column)) {

            let cStringPtr = UnsafePointer(cString)

            return String(cString: cStringPtr)
        }
        return nil
    }
    // Other stuff
    
    @discardableResult
    public func step() -> SQLiteStatusCode? {
        
        return SQLiteStatusCode(rawValue: sqlite3_step(self.cStatement))
    }
    
    @discardableResult
    public func finalizeStatement() -> SQLiteStatusCode? {
        
        return SQLiteStatusCode(rawValue: sqlite3_finalize(self.cStatement))
    }
}
