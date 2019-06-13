//
//  DTable.swift
//  Debugger
//
//  Created by Godwin Joseph on 25/04/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class DTable: IBaseModel {
    public var name: String = ""
    public var databaseName = ""

    public var columnNames = [String]()
    public var rows = [[String]]()
    public var coloumnCount =  0
    public var rowCount =  0
}
