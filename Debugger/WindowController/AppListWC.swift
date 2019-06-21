//
//  AppListWC.swift
//  Debugger
//
//  Created by Godwin Joseph on 20/06/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class AppListWC: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
   let appListVc =  self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("AppListVC")) as? AppListVC
        appListVc?.presentAsModalWindow(appListVc!)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
