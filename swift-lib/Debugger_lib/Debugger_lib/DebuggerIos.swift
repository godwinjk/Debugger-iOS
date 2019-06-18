//
//  Debugger.swift
//  Debugger_lib
//
//  Created by Godwin Joseph on 17/06/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import UIKit

@objc
public class DebuggerIos: NSObject {

   private static var debugger : DebuggerIos?

    private var communicationManager : CommunicationManager?
    @objc
    public static func initWithDefault() -> DebuggerIos{
        if debugger == nil {
            debugger = DebuggerIos()
        }
        return debugger!
    }

    private override init() {
        communicationManager = CommunicationManager()
        communicationManager?.initializeSession()
    }
}
