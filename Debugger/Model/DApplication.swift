//
//  DApplication.swift
//  Debugger
//
//  Created by Godwin Joseph on 25/04/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class DApplication: IBaseModel {
    public var device : DDevice?
    
    public var applicationId: String = ""
    public var applicationName: String = ""
    public var version:String = ""
    public var build:String = ""
    public var iconData : Data?
    public var iconString: String?

}
