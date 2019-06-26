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

    private var dbPaths = [String]()
    private var communicationManager : CommunicationManager?

    @objc
    public static func initWithDefault() -> DebuggerIos{
        if debugger == nil {
            debugger = DebuggerIos()
        }
        return debugger!
    }

    @objc
    public static func initWithPath(dbPaths:[String]) -> DebuggerIos?{
        if debugger == nil {
            guard dbPaths.count>0 else {
                return nil
            }
            debugger = DebuggerIos()
            debugger?.dbPaths = dbPaths
        }
        return debugger
    }

    static  func  getInstance() -> DebuggerIos{
        return debugger!
    }

    func getDbPaths() -> [String] {
        return dbPaths
    }

    private override init() {
        communicationManager = CommunicationManager()
        communicationManager?.initializeSession()
    }
}
