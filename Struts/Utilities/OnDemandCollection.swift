//
// Created by Yunarta on 21/9/18.
// Copyright (c) 2018 mobilesolution works. All rights reserved.
//

import Foundation

public class OnDemandArray<Element> {

    private let buffer: Any

    private let countFunction: () -> Int
    private let subscriptFunction: (_ index: Int) -> Element

    public init(buffer: Any, count: @escaping () -> Int, subscript function: @escaping (_ index: Int) -> Element) {
        self.buffer = buffer
        self.countFunction = count
        self.subscriptFunction = function
    }

    public var count: Int {
        return countFunction()
    }

    public subscript(index: Int) -> Element {
        return subscriptFunction(index)
    }
}

extension OnDemandArray {

    convenience init<S>(sequence: S) where S: Collection, S.Index == Int, S.Element == Element {
        self.init(buffer: sequence, count: {
            sequence.underestimatedCount
        }, subscript: { (index: Int) -> Element in
            sequence[index]
        })
    }
}
