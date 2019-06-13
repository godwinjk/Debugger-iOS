//
//  DatabaseCellView.swift
//  Debugger
//
//  Created by Godwin Joseph on 25/04/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class DatabaseCellView: NSTableCellView {
    @IBOutlet weak var lblDatabaseName: NSTextField!
    @IBOutlet weak var ivIcon: NSImageView!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func onClick(_ sender: Any) {
    }
}
