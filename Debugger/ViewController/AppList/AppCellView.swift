//
//  AppCellView.swift
//  Debugger
//
//  Created by Godwin Joseph on 18/06/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class AppCellView:  NSTableCellView {

    @IBOutlet weak var iConView: NSImageView!
    @IBOutlet weak var appNameView: NSTextField!
    @IBOutlet weak var appBundleId: NSTextField!

    var object : Any?
    var index: Int?

    var clickDelegate : ClickDelegate?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
