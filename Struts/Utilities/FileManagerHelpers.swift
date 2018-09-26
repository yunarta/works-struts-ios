//
// Created by Yunarta on 19/9/18.
// Copyright (c) 2018 mobilesolution works. All rights reserved.
//

import Foundation

class FileManagerHelpers {

    static func applicationLibrary(`for` name: String) throws -> URL? {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
            let applicationLibrary = url.appendingPathComponent("Application Support/\(name)")
            try FileManager.default.createDirectory(at: applicationLibrary, withIntermediateDirectories: true)

            return applicationLibrary
        } else {
            fatalError("Cannot create directory for application library")
        }
    }
}