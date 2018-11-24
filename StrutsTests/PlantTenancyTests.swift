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

    typealias CoreStrutImplWithRealm = CoreStrutImpl<RealmStrutCredentialManager<RealmShortCredential>>

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDiscoverStrut() throws {
        let factory = RealmCredentialManagerFactory(app: "Plant")
        let plant = try PlantBuilder(credentialManager: factory.createPlantManager())
            .add(resident: CoreStrutImplWithRealm(credentialManager: factory.createStrutManager(id: "app", for: RealmShortCredential.self)), withId: "app")
            .build()

        // test get without type reference
        XCTAssertNotNil(plant.discover(strut: .core(id: "app")))

        // test get with type reference
        let strut: Strut? = plant.discover(strut: .core(id: "app"))
        XCTAssertNotNil(strut)

        // test get with subtype reference
        let coreStrut: CoreStrut? = plant.discover(core: .core(id: "app"))
        XCTAssertNotNil(coreStrut)
    }

    func testDiscoverSubStrut() throws {
        let factory = RealmCredentialManagerFactory(app: "Plant")

        let coreStrut = try CoreStrutImplWithRealm(credentialManager: factory.createStrutManager(id: "app", for: RealmShortCredential.self))
        coreStrut.struts["1"] = StrutImpl()

        let plant = try PlantBuilder(credentialManager: factory.createPlantManager())
            .add(resident: coreStrut, withId: "app")
            .build()

        let strut: CoreStrut? = plant.discover(core: .core(id: "app"))
        XCTAssertNotNil(strut)

        let strutOne: Strut? = plant.discover(strut: .strut(owner: "app", id: "1"))
        XCTAssertNotNil(strutOne)
    }
}
