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

    typealias CoreStrutImplWithRealm = CoreStrutImpl<RealmStrutCredentialManager<RealmShortCredential>>

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDiscoverEndPoint() throws {
        class TestEndPoint: EndPoint {  }

        class UnregisteredEndPoint: EndPoint { }
        
        let factory = RealmCredentialManagerFactory(app: "Plant")

        let coreStrut = try CoreStrutImplWithRealm(credentialManager: factory.createStrutManager(id: "app", for: RealmShortCredential.self))
        coreStrut.addEndPoint(TestEndPoint.self, impl: TestEndPoint())

        let plant = try PlantBuilder(credentialManager: factory.createPlantManager())
            .add(resident: coreStrut, withId: "app")
            .build()

        // test get without type reference
        let strut: CoreStrut? = plant.discover(core: .core(id: "app"))

        XCTAssertNotNil(strut?.endPoint(TestEndPoint.self))
        XCTAssertNil(strut?.endPoint(UnregisteredEndPoint.self))
    }

    func testGetEndPoint() throws {
        class TestEndPoint: EndPoint {  }

        class UnregisteredEndPoint: EndPoint { }

        let factory = RealmCredentialManagerFactory(app: "Plant")

        let coreStrut = try CoreStrutImplWithRealm(credentialManager: factory.createStrutManager(id: "app", for: RealmShortCredential.self))
        coreStrut.addEndPoint(TestEndPoint.self, impl: TestEndPoint())

        let plant = try PlantBuilder(credentialManager: factory.createPlantManager())
            .add(resident: coreStrut, withId: "app")
            .build()

        // test get without type reference
        let strut: CoreStrut? = plant.discover(core: .core(id: "app"))

        XCTAssertNotNil(try strut?.getEndPoint(TestEndPoint.self))
        XCTAssertThrowsError(try strut?.getEndPoint(UnregisteredEndPoint.self))
    }
}
