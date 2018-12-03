//
// Created by Yunarta Kartawahyudi on 2018-11-24.
// Copyright (c) 2018 mobilesolution works. All rights reserved.
//

import Foundation

open class Module {

    var strut: PrivilegedStrut {
        guard let strut = strutDelegate else {
            fatalError("endPoint(_:) has not been implemented")
        }

        return strut
    }

    internal weak var strutDelegate: PrivilegedStrut?

    public init() {
    }

    func onCreate(strut: PrivilegedStrut) {
        strutDelegate = strut
    }

    open func onStart() {

    }
}