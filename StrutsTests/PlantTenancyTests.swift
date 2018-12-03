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

    func testDiscoverStrut() throws {
        let plant = PlantBuilder(credentialManager: TestPlantCredentialManager())
            .add(withId: "app")
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
        let plant = PlantBuilder(credentialManager: TestPlantCredentialManager())
            .add(withId: "app") { core in
                core.struts["1"] = PrivilegedStrutImpl()
            }
            .build()

        let strut: CoreStrut? = plant.discover(core: .core(id: "app"))
        XCTAssertNotNil(strut)

        let strutOne: Strut? = plant.discover(strut: .strut(owner: "app", id: "1"))
        XCTAssertNotNil(strutOne)
    }
}
