//
//  EndPointTests.swift
//  StrutsTests
//
//  Created by Yunarta on 24/9/18.
//  Copyright © 2018 mobilesolution works. All rights reserved.
//

import XCTest
import Struts

class EndPointTests: XCTestCase {

    func testDiscoverEndPoint() throws {
        class TestEndPoint: EndPoint {
        }

        class UnregisteredEndPoint: EndPoint {
        }

        let plant = PlantBuilder(credentialManager: TestPlantCredentialManager())
                .add(withId: "app") { core in
                    core.addEndPoint(of: TestEndPoint.self, TestEndPoint())
                }
                .build()

        // test get without type reference
        let strut: CoreStrut? = plant.discover(core: .core(id: "app"))

        XCTAssertNotNil(strut?.endPoint(of: TestEndPoint.self))
        XCTAssertNil(strut?.endPoint(of: UnregisteredEndPoint.self))
    }

    func testGetEndPoint() throws {
        class TestEndPoint: EndPoint {
        }

        class UnregisteredEndPoint: EndPoint {
        }

//        let factory = RealmCredentialManagerFactory(app: "Plant")
//
//        let coreStrut = try CoreStrutImplWithRealm(credentialManager: factory.createStrutManager(id: "app", for: RealmShortCredential.self))
//        coreStrut.addEndPoint(TestEndPoint.self, endpoint: TestEndPoint())

        let plant = PlantBuilder(credentialManager: TestPlantCredentialManager())
                .add(withId: "app") { core in
                    core.addEndPoint(of: TestEndPoint.self, TestEndPoint())
                }
                .build()

        // test get without type reference
        let strut: CoreStrut? = plant.discover(core: .core(id: "app"))

        XCTAssertNotNil(try strut?.getEndPoint(of: TestEndPoint.self))
        XCTAssertThrowsError(try strut?.getEndPoint(of: UnregisteredEndPoint.self))
    }
}
