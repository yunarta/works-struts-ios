//
// Created by Yunarta on 19/9/18.
// Copyright (c) 2018 mobilesolution works. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

public protocol PlantCredentialManager {

}

public protocol ShortCredential {

    var id: String { get }

    func get(_ key: String) -> Any?
}

extension ShortCredential {

    public func get<V>(_ key: String) -> V? {
        return get(key) as? V
    }
}

public protocol StrutCredentialManager {

    func list() -> Single<OnDemandArray<ShortCredential>>

    func observeList() -> Observable<OnDemandArray<ShortCredential>>

    func get(id: String) -> Maybe<ShortCredential>
    
    func observe(id: String) -> Observable<ShortCredential>
}

public protocol StrutCredentialResolver {

    associatedtype Credential

    func resolve(credential: ShortCredential) -> Maybe<Credential>
}

public protocol InternalStrutCredentialManager: StrutCredentialManager {

    associatedtype Credential where Credential: Object & ShortCredential

    associatedtype CredentialResolver: StrutCredentialResolver where CredentialResolver.Credential == Credential

    var credentialResolver: CredentialResolver { get }

    func insertOrReplace(_ credential: Credential) -> Completable

    func remove(_ credential: Credential) -> Single<Bool>
}
