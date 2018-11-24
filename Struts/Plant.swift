//
// Created by Yunarta on 18/9/18.
// Copyright (c) 2018 mobilesolution works. All rights reserved.
//

import Foundation
import SwifterSwift

public protocol Plant {

    var credentialManager: PlantCredentialManager { get }

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

    var residents = Dictionary<String, CoreStrut>()

    public init(credentialManager: PlantCredentialManager) {
        self.credentialManager = credentialManager
    }

    public func add<CS>(resident: CS, withId id: String) -> Self where CS: CoreStrut {
        assert(false == residents.keys.contains(id))
        residents[id] = CoreStrutFacade<CS>(resident)

        return self
    }

    public func build() -> Plant {
        return PlantImpl(
            credentialManager: credentialManager,
            residents: residents
        )
    }
}

class PlantImpl: Plant {

    let residents: [String: CoreStrut]
    private(set) var credentialManager: PlantCredentialManager

    init(credentialManager: PlantCredentialManager, residents: [String: CoreStrut]) {
        self.credentialManager = credentialManager
        self.residents = residents
    }

    func discover(strut: Discovery) -> Strut? {
        switch strut {
        case .core(let id):
            let resident = residents[id]
            assert(resident != nil)

            return resident


        case .strut(let owner, let id):
            let resident = residents[owner]
            assert(resident != nil)

            return resident?.struts[id]
        }
    }


//    func get<S>(strut: Discovery, withType of: S.Type) throws -> S where S: Strut {
//        guard let discovery: Strut = discover(strut: strut) else {
//            throw PlantError.discoveryFailed(reason: "not struts with discovery \(strut) can be found")
//        }
//
//        guard let instance = discovery as? S else {
//            throw PlantError.discoveryFailed(reason: "struts with discovery \(strut) is no \(S.self), but instead \(type(of: discovery))")
//        }
//
//        return instance
//    }
}

public enum Discovery {

    case core(id: String)
    case strut(owner: String, id: String)
}

public enum PlantError: Error {
    case discoveryFailed(reason: String)
}
