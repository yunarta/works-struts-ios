//
// Created by Yunarta on 18/9/18.
// Copyright (c) 2018 mobilesolution works. All rights reserved.
//

import Foundation
import RxSwift

public protocol Schaft {

    func endPoint<E>(_ endPoint: E.Type) -> E? where E: EndPoint
}

extension Schaft {

    public func getEndPoint<E>(_ endPoint: E.Type) throws -> E where E: EndPoint {
        guard let realized: E = self.endPoint(endPoint) else {
            if let discovered: EndPoint = self.endPoint(endPoint) {
                throw SchaftError.discoveryFailed(reason: "endPoint \(type(of: endPoint)) found with type \(type(of: discovered))")
            } else {
                throw SchaftError.discoveryFailed(reason: ("endPoint \(type(of: endPoint)) is nil"))
            }
        }

        return realized
    }
}

public protocol PrivilegedSchaft: Schaft {

    func locator<L>(_ locator: L.Type) -> L? where L: Locator
}

extension PrivilegedSchaft {

    public func getLocator<L>(_ locator: L.Type) throws -> L where L: Locator {
        guard let realized: L = self.locator(locator) else {
            if let discovered: Locator = self.locator(locator) {
                throw SchaftError.discoveryFailed(reason: "locator \(type(of: locator)) found with type \(type(of: discovered))")
            } else {
                throw SchaftError.discoveryFailed(reason: ("locator \(type(of: locator)) is nil"))
            }
        }

        return realized
    }
}

class SchaftFacade<S>: Schaft where S: Schaft {

    let schaft: S

    init(_ schaft: S) {
        self.schaft = schaft
    }

    func endPoint<E>(_ endPoint: E.Type) -> E? where E: EndPoint {
        return schaft.endPoint(endPoint)
    }
}

open class SchaftImpl: PrivilegedSchaft {

    var endPoints = [String: EndPoint]()

    var locators = [String: Locator]()

    public init() {

    }

    public func endPoint<E>(_ endPoint: E.Type) -> E? where E: EndPoint {
        let key = "\(type(of: endPoint))"
        return endPoints[key] as? E
    }

    public func addEndPoint<E>(_ endPoint: E.Type, impl: E) where E: EndPoint {
        let key = "\(type(of: endPoint))"
        endPoints[key] = impl
    }

    public func locator<L>(_ locator: L.Type) -> L? where L: Locator {
        let key = "\(type(of: locator))"
        return locators[key] as? L
    }

    public func addLocator<L>(_ locator: L.Type, impl: L) where L: Locator {
        let key = "\(type(of: locator))"
        locators[key] = impl
    }
}

public protocol CoreSchaft: Schaft {

    var credentialManager: SchaftCredentialManager { get }

    var shafts: [String: Schaft] { get }
}

public protocol PrivilegedCoreSchaft: CoreSchaft {


}

class CoreSchaftFacade<S>: SchaftFacade<S>, PrivilegedCoreSchaft where S: CoreSchaft {

    override init(_ schaft: S) {
        super.init(schaft)
    }

    var credentialManager: SchaftCredentialManager {
        return schaft.credentialManager
    }

    var shafts: [String: Schaft] {
        return schaft.shafts
    }
}

open class CoreSchaftImpl<CredentialManager>: SchaftImpl, PrivilegedCoreSchaft

    where CredentialManager: InternalSchaftCredentialManager {

    public typealias Credential = CredentialManager.Credential

    internal (set) public var shafts = [String: Schaft]()

    public var credentialManager: SchaftCredentialManager {
        return internalCredentialManager
    }
    let internalCredentialManager: CredentialManager

    public init(credentialManager: CredentialManager) {
        self.internalCredentialManager = credentialManager
    }
}

public enum SchaftError: Error {
    case discoveryFailed(reason: String)
}