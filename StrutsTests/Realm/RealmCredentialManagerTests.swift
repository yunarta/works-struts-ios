//
//  RealmCredentialManagerTests.swift
//  StrutsTests
//
//  Created by Yunarta on 22/9/18.
//  Copyright © 2018 mobilesolution works. All rights reserved.
//

import XCTest
import Struts
import RealmSwift
import RxSwift
import RxBlocking

class RealmCredentialManagerTests: XCTestCase {

    func testListWithInjection() throws {
        var configuration = Realm.Configuration()
        configuration.inMemoryIdentifier = "Beryl-credential"

        let realm = try Realm(configuration: configuration)
        let credentialManager = try RealmCredentialManagerFactory(app: "Plant")
            .createStrutManager(id: "Beryl", for: RealmShortCredential.self, inMemory: true)

        try realm.write {
            realm.add(RealmShortCredential(id: "manager-one", name: "Manager One"))
        }
        XCTAssertEqual(1, try credentialManager.list().toBlocking().first()?.count)

        try realm.write {
            realm.add(RealmShortCredential(id: "manager-two", name: "Manager Two"))
        }
        XCTAssertEqual(2, try credentialManager.list().toBlocking().first()?.count)
    }

    func testObserveListWithInjection() throws {
        var configuration = Realm.Configuration()
        configuration.inMemoryIdentifier = "Beryl-credential"

        let realm = try Realm(configuration: configuration)
        let credentialManager = try RealmCredentialManagerFactory(app: "Plant")
            .createStrutManager(id: "Beryl", for: RealmShortCredential.self, inMemory: true)

        try realm.write {
            realm.add(RealmShortCredential(id: "manager-one", name: "Manager One"))
        }
        XCTAssertEqual(1, try credentialManager.observeList().toBlocking().first()?.count)

        try realm.write {
            realm.add(RealmShortCredential(id: "manager-two", name: "Manager Two"))
        }
        XCTAssertEqual(2, try credentialManager.observeList().toBlocking().first()?.count)
    }

    func testGet() throws {
        let credentialManager = try RealmCredentialManagerFactory(app: "Plant")
            .createStrutManager(id: "Beryl", for: RealmShortCredential.self, inMemory: true)

        XCTAssertNil(try credentialManager.insertOrReplace(RealmShortCredential(id: "manager-one", name: "Manager One")).toBlocking().first())
        XCTAssertEqual("manager-one", try credentialManager.get(id: "manager-one").toBlocking().first()?.id)
        XCTAssertNil(try credentialManager.get(id: "manager-two").toBlocking().first())
    }


    func testAdd() throws {
        let credentialManager = try RealmCredentialManagerFactory(app: "Plant")
            .createStrutManager(id: "Beryl", for: RealmShortCredential.self, inMemory: true)
        XCTAssertNil(try credentialManager.insertOrReplace(RealmShortCredential(id: "manager-one", name: "Manager One")).toBlocking().first())
        XCTAssertEqual(1, try credentialManager.list().toBlocking().first()?.count)

        XCTAssertNil(try credentialManager.insertOrReplace(RealmShortCredential(id: "manager-two", name: "Manager Two")).toBlocking().first())
        XCTAssertEqual(2, try credentialManager.list().toBlocking().first()?.count)
    }

    func testDelete() throws {
        let credentialManager = try RealmCredentialManagerFactory(app: "Plant")
            .createStrutManager(id: "Beryl", for: RealmShortCredential.self, inMemory: true)
        XCTAssertNil(try credentialManager.insertOrReplace(RealmShortCredential(id: "manager-one", name: "Manager One")).toBlocking().first())
        XCTAssertEqual(1, try credentialManager.list().toBlocking().first()?.count)

        XCTAssertTrue(try credentialManager.remove(RealmShortCredential(id: "manager-one", name: "Manager One")).toBlocking().first() ?? false)
        XCTAssertEqual(0, try credentialManager.list().toBlocking().first()?.count)
    }

    func testResolve() throws {
        let credentialManager = try RealmCredentialManagerFactory(app: "Plant")
            .createStrutManager(id: "Beryl", for: RealmShortCredential.self, inMemory: true)
        let credential = RealmShortCredential(id: "manager-one", name: "Manager One")

        XCTAssertNil(try credentialManager.insertOrReplace(credential).toBlocking().first())
        XCTAssertEqual(credential, try credentialManager.get(id: "manager-one").flatMap { credential in
            credentialManager.credentialResolver.resolve(credential: credential)
        }.toBlocking().first())
    }
}
