//
// Created by Yunarta on 18/9/18.
// Copyright (c) 2018 mobilesolution works. All rights reserved.
//

import Foundation
import RxSwift

public protocol Strut
{
    func endPoint<E>(_ endPoint: E.Type) -> E? where E: EndPoint
}

extension Strut {

    public func getEndPoint<E>(_ endPoint: E.Type) throws -> E where E: EndPoint {
        guard let realized: E = self.endPoint(endPoint) else {
            if let discovered: EndPoint = self.endPoint(endPoint) {
                throw StrutError.discoveryFailed(reason: "endPoint \(type(of: endPoint)) found with type \(type(of: discovered))")
            } else {
                throw StrutError.discoveryFailed(reason: ("endPoint \(type(of: endPoint)) is nil"))
            }
        }

        return realized
    }
}

public protocol PrivilegedStrut: Strut {

    func locator<L>(_ locator: L.Type) -> L? where L: Locator
}

extension PrivilegedStrut {

    public func getLocator<L>(_ locator: L.Type) throws -> L where L: Locator {
        guard let realized: L = self.locator(locator) else {
            if let discovered: Locator = self.locator(locator) {
                throw StrutError.discoveryFailed(reason: "locator \(type(of: locator)) found with type \(type(of: discovered))")
            } else {
                throw StrutError.discoveryFailed(reason: ("locator \(type(of: locator)) is nil"))
            }
        }

        return realized
    }
}

class StrutFacade<S>: Strut where S: Strut {

    let strut: S

    init(_ strut: S) {
        self.strut = strut
    }

    func endPoint<E>(_ endPoint: E.Type) -> E? where E: EndPoint {
        return strut.endPoint(endPoint)
    }
}

open class StrutImpl: PrivilegedStrut {

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

public protocol CoreStrut: Strut {

    var credentialManager: StrutCredentialManager { get }

    var struts: [String: Strut] { get }
}

public protocol PrivilegedCoreStrut: CoreStrut {


}

class CoreStrutFacade<S>: StrutFacade<S>, PrivilegedCoreStrut where S: CoreStrut {

    override init(_ strut: S) {
        super.init(strut)
    }

    var credentialManager: StrutCredentialManager {
        return strut.credentialManager
    }

    var struts: [String: Strut] {
        return strut.struts
    }
}

open class CoreStrutImpl<CredentialManager>: StrutImpl, PrivilegedCoreStrut

    where CredentialManager: InternalStrutCredentialManager {

    public typealias Credential = CredentialManager.Credential

    internal (set) public var struts = [String: Strut]()

    public var credentialManager: StrutCredentialManager {
        return internalCredentialManager
    }
    let internalCredentialManager: CredentialManager

    public init(credentialManager: CredentialManager) {
        self.internalCredentialManager = credentialManager
    }
}

public enum StrutError: Error {
    case discoveryFailed(reason: String)
}
