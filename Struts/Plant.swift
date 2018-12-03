//
// Created by Yunarta on 18/9/18.
// Copyright (c) 2018 mobilesolution works. All rights reserved.
//

import Foundation
import SwifterSwift

public protocol Plant {

    func discover(strut: Discovery) -> Strut?
}

public extension Plant {

    public func discover(core: Discovery) -> CoreStrut? {
        return self.discover(strut: core).flatMap { strut -> CoreStrut? in
            assert(strut is CoreStrut)
            return strut as? CoreStrut
        }
    }
}

public class PlantBuilder {

    var credentialManager: PlantCredentialManager

    var residents = [String: PrivilegedCoreStrutImpl]()

    public init(credentialManager: PlantCredentialManager) {
        self.credentialManager = credentialManager
    }

    public func add(withId id: String, populate: (PrivilegedCoreStrutImpl) -> Void = { _ in }) -> Self {
        assert(false == residents.keys.contains(id))
        let strut: PrivilegedCoreStrutImpl = PrivilegedCoreStrutImpl()
        residents[id] = strut
        populate(strut)
        strut.start()

        return self
    }

    public func build() -> Plant {
        return PlantImpl(
                credentialManager: credentialManager,
                residents: residents
        )
    }
}

class PlantFacade : Plant  {

    let delegate: Plant

    public init(delegate: Plant) {
        self.delegate = delegate
    }

    func discover(strut: Discovery) -> Strut? {
        return self.delegate.discover(strut: strut)
    }
}

class PlantImpl: Plant {

    private let residents: [String: PrivilegedCoreStrutImpl]
    private(set) var credentialManager: PlantCredentialManager

    init(credentialManager: PlantCredentialManager, residents: [String: PrivilegedCoreStrutImpl]) {
        self.credentialManager = credentialManager
        self.residents = residents
    }

    func discover(strut: Discovery) -> Strut? {
        switch strut {
        case .core(let id):
            let resident = residents[id]
            assert(resident != nil)

            return resident.map { strut -> Strut in
                return CoreStrutFacade(delegate: strut)
            }

        case .strut(let owner, let id):
            let resident = residents[owner]
            assert(resident != nil)

            return resident?.struts[id].map { strut -> Strut in
                return StrutFacade(delegate: strut)
            }
        }
    }
}

public enum Discovery {

    case core(id: String)
    case strut(owner: String, id: String)
}