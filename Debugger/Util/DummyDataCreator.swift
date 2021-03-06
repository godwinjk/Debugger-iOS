//
//  DummyDataCreator.swift
//  Debugger
//
//  Created by Godwin Joseph on 25/04/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class DummyDataCreator: IBaseModel {
    public static func getDummyApplication() -> DApplication{
        let application = DApplication()
        application.applicationId = "com.godwin.dummy"
        application.applicationName = "Dummy"
        application.build = "1"
        application.version = "1.0.0"

        return application
    }

    public static func getDummyDatabase(_ number: Int)-> [DDatabase]{
        var databases:[DDatabase] = []
        
        for i in 1...number {
            let database = DDatabase()
            database.name = "Database \(i)"
            database.tables = getDummyTables(Int.random(in: 0...5))
            databases.append(database)
        }
        return databases
    }
    
    public static func getDummyTables(_ number: Int)-> [DTable]{
        var tables:[DTable] = []
        guard number > 1 else {
            return tables
        }
        
        for i in 1...number {
            let table = DTable()
            table.name = "Table \(i)"
            
            tables.append(table)
        }
    
        return tables
    }
}
