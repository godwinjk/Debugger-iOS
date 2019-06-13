//
//  PTDataExtn.swift
//  app_lb
//
//  Created by Godwin Joseph on 24/05/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Foundation

extension PTData {
    var textFrameMessage: String {
        let textFrame = self.data.assumingMemoryBound(to: PTExampleTextFrame.self)
        let length = Int(textFrame.pointee.length.bigEndian)
        let utf8text = self.data
            .advanced(by: MemoryLayout<UInt32>.size) // <- Sadly enough, `MemoryLayout.offset(of:)` does not work as expected for `utf8text`
            .assumingMemoryBound(to: UInt8.self)
        let bytes = UnsafeBufferPointer(start: utf8text, count: length)
        let message = String(bytes: bytes, encoding: .utf8)! // <- This may crash, if the message is not encoded in UTF-8
        return message
    }
}
