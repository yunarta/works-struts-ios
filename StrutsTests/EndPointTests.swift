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

    typealias CoreSchaftImplWithRealm = CoreSchaftImpl<RealmSchaftCredentialManager<RealmShortCredential>>

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

        let coreSchaft = try CoreSchaftImplWithRealm(credentialManager: factory.createSchaftManager(id: "app", for: RealmShortCredential.self))
        coreSchaft.addEndPoint(TestEndPoint.self, impl: TestEndPoint())

        let plant = try PlantBuilder(credentialManager: factory.createPlantManager())
            .add(resident: coreSchaft, withId: "app")
            .build()

        // test get without type reference
        let schaft: CoreSchaft? = plant.discover(core: .core(id: "app"))

        XCTAssertNotNil(schaft?.endPoint(TestEndPoint.self))
        XCTAssertNil(schaft?.endPoint(UnregisteredEndPoint.self))
    }

    func testGetEndPoint() throws {
        class TestEndPoint: EndPoint {  }

        class UnregisteredEndPoint: EndPoint { }

        let factory = RealmCredentialManagerFactory(app: "Plant")

        let coreSchaft = try CoreSchaftImplWithRealm(credentialManager: factory.createSchaftManager(id: "app", for: RealmShortCredential.self))
        coreSchaft.addEndPoint(TestEndPoint.self, impl: TestEndPoint())

        let plant = try PlantBuilder(credentialManager: factory.createPlantManager())
            .add(resident: coreSchaft, withId: "app")
            .build()

        // test get without type reference
        let schaft: CoreSchaft? = plant.discover(core: .core(id: "app"))

        XCTAssertNotNil(try schaft?.getEndPoint(TestEndPoint.self))
        XCTAssertThrowsError(try schaft?.getEndPoint(UnregisteredEndPoint.self))
    }
}
