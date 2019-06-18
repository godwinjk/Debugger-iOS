//
//  AppDelegate.swift
//  Debugger
//
//  Created by Godwin Joseph on 25/04/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        CommunicationManager.getInstance()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

