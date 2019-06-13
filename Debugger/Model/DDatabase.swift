//
//  DDatabase.swift
//  Debugger
//
//  Created by Godwin Joseph on 25/04/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class DDatabase: IBaseModel {
    public var name: String = ""
    public var fullPath : String = ""
    public var tables: [DTable] = []
}
