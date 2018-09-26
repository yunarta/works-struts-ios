//
//  PlantTenancyTests.swift
//  StrutsTests
//
//  Created by Yunarta on 19/9/18.
//  Copyright © 2018 mobilesolution works. All rights reserved.
//

import XCTest
@testable import Struts

class PlantTenancyTests: XCTestCase {

    typealias CoreSchaftImplWithRealm = CoreSchaftImpl<RealmSchaftCredentialManager<RealmShortCredential>>

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDiscoverSchaft() throws {
        let factory = RealmCredentialManagerFactory(app: "Plant")
        let plant = try PlantBuilder(credentialManager: factory.createPlantManager())
            .add(resident: CoreSchaftImplWithRealm(credentialManager: factory.createSchaftManager(id: "app", for: RealmShortCredential.self)), withId: "app")
            .build()

        // test get without type reference
        XCTAssertNotNil(plant.discover(schaft: .core(id: "app")))

        // test get with type reference
        let schaft: Schaft? = plant.discover(schaft: .core(id: "app"))
        XCTAssertNotNil(schaft)

        // test get with subtype reference
        let coreSchaft: CoreSchaft? = plant.discover(core: .core(id: "app"))
        XCTAssertNotNil(coreSchaft)
    }

    func testDiscoverSubSchaft() throws {
        let factory = RealmCredentialManagerFactory(app: "Plant")

        let coreSchaft = try CoreSchaftImplWithRealm(credentialManager: factory.createSchaftManager(id: "app", for: RealmShortCredential.self))
        coreSchaft.shafts["1"] = SchaftImpl()

        let plant = try PlantBuilder(credentialManager: factory.createPlantManager())
            .add(resident: coreSchaft, withId: "app")
            .build()

        let schaft: CoreSchaft? = plant.discover(core: .core(id: "app"))
        XCTAssertNotNil(schaft)

        let schaftOne: Schaft? = plant.discover(schaft: .schaft(owner: "app", id: "1"))
        XCTAssertNotNil(schaftOne)
    }
}
