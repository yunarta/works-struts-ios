//
// Created by Yunarta on 18/9/18.
// Copyright (c) 2018 mobilesolution works. All rights reserved.
//

import Foundation
import SwifterSwift

public protocol Plant {

    var credentialManager: PlantCredentialManager { get }

    func discover(schaft: Discovery) -> Schaft?
}

public extension Plant {

    public func discover(core: Discovery) -> CoreSchaft? {
        return self.discover(schaft: core).flatMap { schaft -> CoreSchaft? in
            assert(schaft is CoreSchaft)
            return schaft as? CoreSchaft
        }
    }
}

public class PlantBuilder {

    var credentialManager: PlantCredentialManager

    var residents = Dictionary<String, CoreSchaft>()

    public init(credentialManager: PlantCredentialManager) {
        self.credentialManager = credentialManager
    }

    public func add<CS>(resident: CS, withId id: String) -> Self where CS: CoreSchaft {
        assert(false == residents.keys.contains(id))
        residents[id] = CoreSchaftFacade<CS>(resident)

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

    let residents: [String: CoreSchaft]
    private(set) var credentialManager: PlantCredentialManager

    init(
        credentialManager: PlantCredentialManager,
        residents: [String: CoreSchaft]
    ) {
        self.credentialManager = credentialManager
        self.residents = residents
    }

    func discover(schaft: Discovery) -> Schaft? {
        switch schaft {
        case .core(let id):
            let resident = residents[id]
            assert(resident != nil)

            return resident


        case .schaft(let owner, let id):
            let resident = residents[owner]
            assert(resident != nil)

            return resident?.shafts[id]
        }
    }


//    func get<S>(schaft: Discovery, withType of: S.Type) throws -> S where S: Schaft {
//        guard let discovery: Schaft = discover(schaft: schaft) else {
//            throw PlantError.discoveryFailed(reason: "not struts with discovery \(schaft) can be found")
//        }
//
//        guard let instance = discovery as? S else {
//            throw PlantError.discoveryFailed(reason: "struts with discovery \(schaft) is no \(S.self), but instead \(type(of: discovery))")
//        }
//
//        return instance
//    }
}

public enum Discovery {

    case core(id: String)
    case schaft(owner: String, id: String)
}

public enum PlantError: Error {
    case discoveryFailed(reason: String)
}
