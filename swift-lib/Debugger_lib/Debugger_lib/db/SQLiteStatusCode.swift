//
//  SQLiteStatusCode.swift
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

public enum SQLiteStatusCode: Int32 {
    case ok = 0                         /* Successful result */
    /* beginning-of-error-codes */
    case error = 1                      /* SQL error or missing database */
    case internalLogicError = 2         /* Internal logic error in SQLite */
    case accessPermissionDenied = 3     /* Access permission denied */
    case abort = 4                      /* Callback routine requested an abort */
    case busy = 5                       /* The database file is locked */
    case locked = 6                     /* A table in the database is locked */
    case noMemory = 7                   /* A malloc() failed */
    case readOnly = 8                   /* Attempt to write a readonly database */
    case interrupt = 9                  /* Operation terminated by sqlite3_interrupt()*/
    case ioError = 10                   /* Some kind of disk I/O error occurred */
    case corrupt = 11                   /* The database disk image is malformed */
    case notFound = 12                  /* Unknown opcode in sqlite3_file_control() */
    case full = 13                      /* Insertion failed because database is full */
    case cantOpen = 14                  /* Unable to open the database file */
    case `protocol` = 15                  /* Database lock protocol error */
    case empty = 16                     /* Database is empty */
    case schema = 17                    /* The database schema changed */
    case tooBig = 18                    /* String or BLOB exceeds size limit */
    case constraint = 19                /* Abort due to constraint violation */
    case mismatch = 20                  /* Data type mismatch */
    case misuse = 21                    /* Library used incorrectly */
    case noLFS = 22                     /* Uses OS features not supported on host */
    case authDeniedUTH = 23             /* Authorization denied */
    case format = 24                    /* Auxiliary database format error */
    case range = 25                     /* 2nd parameter to sqlite3_bind out of range */
    case notADatabase = 26              /* File opened that is not a database file */
    case row = 100                      /* sqlite3_step() has another row ready */
    case done = 101                     /* sqlite3_step() has finished executing */
}
