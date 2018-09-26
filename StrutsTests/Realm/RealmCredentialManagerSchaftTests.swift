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

class RealmCredentialManagerSchaftTests: XCTestCase {

    typealias CoreSchaftImplWithRealm = CoreSchaftImpl<RealmSchaftCredentialManager<RealmShortCredential>>

    func testDiscoverSchaft() throws {
        var configuration = Realm.Configuration()
        configuration.inMemoryIdentifier = "Beryl-credential"

        let realm = try Realm(configuration: configuration)
        try realm.write {
            realm.add(RealmShortCredential(id: "manager-one", name: "Manager One"))
        }

        let factory = RealmCredentialManagerFactory(app: "Plant")
        let plant = try PlantBuilder(credentialManager: factory.createPlantManager())
            .add(resident: CoreSchaftImplWithRealm(credentialManager: factory.createSchaftManager(id: "Beryl", for: RealmShortCredential.self)), withId: "Beryl")
            .build()

        let coreSchaft: CoreSchaft = plant.discover(core: .core(id: "Beryl"))!
        let credential: ShortCredential = try coreSchaft.credentialManager.get(id: "manager-one").toBlocking().first()!
        XCTAssertEqual("Manager One", credential.get("name"))
    }
}
