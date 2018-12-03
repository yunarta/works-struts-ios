////
//// Created by Yunarta on 22/9/18.
//// Copyright (c) 2018 mobilesolution works. All rights reserved.
////
//
//import Foundation
//import RealmSwift
//import Struts
//
//class RealmShortCredential: Object, ShortCredential {
//
//    @objc dynamic public var id: String = ""
//
//    @objc dynamic public var name: String = ""
//
//    override public static func primaryKey() -> String? {
//        return "id"
//    }
//
//    func get(_ key: String) -> Any? {
//        switch key {
//        case "name":
//            return name
//
//        default:
//            return nil
//        }
//    }
//
//    public convenience init(id: String, name: String) {
//        self.init()
//        self.id = id
//        self.name = name
//    }
//}
//
//extension OnDemandArray where Element == ShortCredential {
//
//    convenience init(transforming sequence: AnyRealmCollection<RealmShortCredential>) {
//        self.init(buffer: sequence, count: { [weak sequence = sequence] in
//            sequence?.underestimatedCount ?? 0
//        }, subscript: { [weak sequence = sequence] index -> ShortCredential in
//            guard let sequence = sequence else {
//                fatalError("calling array where the data is closed already")
//            }
//            return sequence[index]
//        })
//    }
//}