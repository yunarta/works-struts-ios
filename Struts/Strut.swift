//
// Created by Yunarta on 18/9/18.
// Copyright (c) 2018 mobilesolution works. All rights reserved.
//

import Foundation
import RxSwift

public protocol Strut: class
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

    func component<C>(_ component: C.Type) -> C? where C: Component
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

    public func getComponent<C>(_ component: C.Type) throws -> C where C: Component {
        guard let realized: C = self.component(component) else {
            if let discovered: Component = self.component(component) {
                throw StrutError.discoveryFailed(reason: "locator \(type(of: component)) found with type \(type(of: discovered))")
            } else {
                throw StrutError.discoveryFailed(reason: ("locator \(type(of: component)) is nil"))
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

    var components = [String: Component]()

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
        impl.dispatchOnCreate(strut: self)
    }

    public func component<C>(_ component: C.Type) -> C? where C: Component {
        let key = "\(type(of: locator))"
        return components[key] as? C
    }

    public func addComponent<C>(_ component: C.Type, impl: C) where C: Component {
        let key = "\(type(of: component))"
        components[key] = impl
        impl.dispatchOnCreate(strut: self)
    }

    public func locator<L>(_ locator: L.Type) -> L? where L: Locator {
        let key = "\(type(of: locator))"
        return locators[key] as? L
    }

    public func addLocator<L>(_ locator: L.Type, impl: L) where L: Locator {
        let key = "\(type(of: locator))"
        locators[key] = impl
        impl.dispatchOnCreate(strut: self)
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
    case illegalState
}
