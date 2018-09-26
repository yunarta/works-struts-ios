//
// Created by Yunarta on 19/9/18.
// Copyright (c) 2018 mobilesolution works. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

public class RealmPlantCredentialManager: PlantCredentialManager {

    let realm: Realm

    internal init(_ configuration: Realm.Configuration) throws {
        realm = try Realm(configuration: configuration)
    }
}

public class RealmCredentialResolver<Credential>: SchaftCredentialResolver where Credential: Object & ShortCredential {

    let configuration: Realm.Configuration

    public init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }

    public func resolve(credential: ShortCredential) -> Maybe<Credential> {
        return Maybe.create { observer in
            do {
                if credential is Credential {
                    let realm = try Realm(configuration: self.configuration)
                    if let credential = realm.object(ofType: Credential.self, forPrimaryKey: credential.id) {
                        observer(.success(credential))
                    }
                }
                observer(.completed)
            } catch {
                observer(.error(error))
            }

            return Disposables.create()
        }
    }

}

public class RealmSchaftCredentialManager<Credential>: InternalSchaftCredentialManager
    where Credential: Object & ShortCredential {

    typealias StaticSelf = RealmSchaftCredentialManager<Credential>

    let reference: Realm

    let configuration: Realm.Configuration

    let internalCredentialResolved: RealmCredentialResolver<Credential>
    public var credentialResolver: RealmCredentialResolver<Credential> {
        return internalCredentialResolved
    }

    internal init(_ configuration: Realm.Configuration) throws {
        self.configuration = configuration

        internalCredentialResolved = RealmCredentialResolver(configuration: configuration)
        reference = try Realm(configuration: configuration)
    }

    public func list() -> Single<OnDemandArray<ShortCredential>> {
        return Single.create { observer in
            do {
                let realm = try Realm(configuration: self.configuration)
                let result: OnDemandArray<ShortCredential> = StaticSelf.create(transforming: AnyRealmCollection(realm.objects(Credential.self)))

                observer(.success(result))
            } catch {
                observer(.error(error))
            }

            return Disposables.create()
        }
    }

    public func observeList() -> Observable<OnDemandArray<ShortCredential>> {
        return Observable.deferred {
            return Observable.changeset(from: try Realm(configuration: self.configuration).objects(Credential.self))
                .map { (arg) -> OnDemandArray<ShortCredential> in
                    let (collection, _) = arg
                    return StaticSelf.create(transforming: AnyRealmCollection(collection))
                }
        }
    }

    public func get(id: String) -> Maybe<ShortCredential> {
        return Maybe.create { observer in
            do {
                let realm = try Realm(configuration: self.configuration)
                if let credential = realm.object(ofType: Credential.self, forPrimaryKey: id) {
                    observer(.success(credential))
                }
                observer(.completed)
            } catch {
                observer(.error(error))
            }

            return Disposables.create()
        }
    }

    public func insertOrReplace(_ credential: Credential) -> Completable {
        return Completable.create { observer in
            do {
                let realm = try Realm(configuration: self.configuration)
                try realm.write {
                    realm.add(credential, update: true)
                }
                observer(.completed)
            } catch {
                observer(.error(error))
            }

            return Disposables.create()
        }
    }

    public func remove(_ credential: Credential) -> Single<Bool> {
        return Single.create { observer in
            do {
                let realm = try Realm(configuration: self.configuration)
                try realm.write {
                    if let found = realm.object(ofType: Credential.self, forPrimaryKey: credential.id) {
                        realm.delete(found)
                        observer(.success(true))
                    } else {
                        observer(.success(false))
                    }
                }
            } catch {
                observer(.error(error))
            }

            return Disposables.create()
        }
    }

    static func create(transforming sequence: AnyRealmCollection<Credential>) -> OnDemandArray<ShortCredential> {
        return OnDemandArray<ShortCredential>(buffer: sequence, count: { [weak sequence = sequence] in
            sequence?.underestimatedCount ?? 0
        }, subscript: { [weak sequence = sequence] index -> ShortCredential in
            guard let sequence = sequence else {
                fatalError("calling array where the data is closed already")
            }
            return sequence[index]
        })
    }
}

public class RealmCredentialManagerFactory {

    let name: String

    public init(app name: String) {
        self.name = name
    }

    public func createPlantManager(inMemory: Bool = true) throws -> PlantCredentialManager {
        var configuration = Realm.Configuration()
        configuration.inMemoryIdentifier = "credential.realm"
        if (!inMemory) {
            configuration.fileURL = try FileManagerHelpers.applicationLibrary(for: name)?.appendingPathComponent("credentials.realm")
        }

        return try RealmPlantCredentialManager(configuration)
    }

    public func createSchaftManager<Credential>(id: String, for _: Credential.Type, inMemory: Bool = true) throws -> RealmSchaftCredentialManager<Credential>
        where Credential: Object & ShortCredential {
        var configuration = Realm.Configuration()
        configuration.inMemoryIdentifier = "\(id)-credential"

        if (!inMemory) {
            configuration.fileURL = try FileManagerHelpers.applicationLibrary(for: name)?.appendingPathComponent("\(id).realm")
        }

        return try RealmSchaftCredentialManager<Credential>(configuration)
    }
}
