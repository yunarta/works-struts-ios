//
// Created by Yunarta on 18/9/18.
// Copyright (c) 2018 mobilesolution works. All rights reserved.
//

import Foundation
import RxSwift

public protocol Strut: class {
    func endPoint<E>(of: E.Type) -> E? where E: EndPoint
}

extension Strut {

    public func getEndPoint<E>(of: E.Type) throws -> E where E: EndPoint {
        guard let realized: E = self.endPoint(of: of) else {
            if let discovered: EndPoint = self.endPoint(of: of) {
                throw StrutError.discoveryFailed(reason: "endPoint \(type(of: of)) found with type \(type(of: discovered))")
            } else {
                throw StrutError.discoveryFailed(reason: ("endPoint \(type(of: of)) is nil"))
            }
        }

        return realized
    }
}

public protocol PrivilegedStrut: Strut {

    func component<C>(of: C.Type) -> C? where C: Component

    func locator<L>(of: L.Type) -> L? where L: Locator
}

extension PrivilegedStrut {

    public func getLocator<L>(of: L.Type) throws -> L where L: Locator {
        guard let realized: L = self.locator(of: of) else {
            if let discovered: Locator = self.locator(of: of) {
                throw StrutError.discoveryFailed(reason: "locator \(type(of: of)) found with type \(type(of: discovered))")
            } else {
                throw StrutError.discoveryFailed(reason: ("locator \(type(of: of)) is nil"))
            }
        }

        return realized
    }

    public func getComponent<C>(of: C.Type) throws -> C where C: Component {
        guard let realized: C = self.component(of: of) else {
            if let discovered: Component = self.component(of: of) {
                throw StrutError.discoveryFailed(reason: "locator \(type(of: component)) found with type \(type(of: discovered))")
            } else {
                throw StrutError.discoveryFailed(reason: ("locator \(type(of: component)) is nil"))
            }
        }

        return realized
    }
}

class StrutFacade: Strut {

    private let delegate: Strut

    init(delegate: Strut) {
        self.delegate = delegate
    }

    func endPoint<E>(of: E.Type) -> E? where E: EndPoint {
        return delegate.endPoint(of: of)
    }
}

public protocol CoreStrut: Strut {

}

public protocol PrivilegedCoreStrut: CoreStrut, PrivilegedStrut {

    var credentialManager: StrutCredentialManager? { get }

    var struts: [String: Strut] { get }
}

class CoreStrutFacade: StrutFacade, CoreStrut {

    private var delegate: CoreStrut

    init(delegate: CoreStrut) {
        self.delegate = delegate
        super.init(delegate: delegate)
    }
}

open class PrivilegedStrutImpl: PrivilegedStrut {

    var endPoints = [String: EndPoint]()

    var components = [String: Component]()

    var locators = [String: Locator]()

    public init() {

    }

    public func endPoint<E>(of: E.Type) -> E? where E: EndPoint {
        let key = "\(type(of: of))"
        return endPoints[key] as? E
    }

    public func addEndPoint<E>(of: E.Type, _ endpoint: E) where E: EndPoint {
        let key = "\(type(of: of))"
        endPoints[key] = endpoint
        endpoint.onCreate(strut: self)
    }

    public func locator<L>(of: L.Type) -> L? where L: Locator {
        let key = "\(type(of: of))"
        return locators[key] as? L
    }

    public func addLocator<L>(of: L.Type, _ locator: L) where L: Locator {
        let key = "\(type(of: of))"
        locators[key] = locator
        locator.onCreate(strut: self)
    }

    public func component<C>(of: C.Type) -> C? where C: Component {
        let key = "\(type(of: of))"
        return components[key] as? C
    }

    public func addComponent<C>(of: C.Type, _ component: C) where C: Component {
        let key = "\(type(of: of))"
        components[key] = component
        component.onCreate(strut: self)
    }

    internal func start() {
        components.values.forEach {
            $0.onStart()
        }

        locators.values.forEach {
            $0.onStart()
        }

        endPoints.values.forEach {
            $0.onStart()
        }
    }
}

open class PrivilegedCoreStrutImpl/*<CredentialManager>*/: PrivilegedStrutImpl, PrivilegedCoreStrut/*
        where CredentialManager: InternalStrutCredentialManager */{

//    public typealias Credential = CredentialManager.Credential

    internal (set) public var struts = [String: Strut]()

    public var credentialManager: StrutCredentialManager?/* {
        return internalCredentialManager
    }
    let internalCredentialManager: CredentialManager

    public init(credentialManager: CredentialManager) {
        self.internalCredentialManager = credentialManager
    }*/

    override init() {

    }
}

public enum StrutError: Error {
    case discoveryFailed(reason: String)
    case illegalState
}
