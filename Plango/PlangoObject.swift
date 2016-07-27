//
//  PlangoObject.swift
//  Plango
//
//  Created by Douglas Hewitt on 7/25/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import RealmSwift

class PlangoObject: NSObject {
    enum CodeKeys: String {
        case id = "id"
        case name = "name"
        case avatar = "avatar"
        case planDescription = "planDescription"
        case isPublic = "isPublic"
        case authorID = "authorID"
        case durationDays = "durationDays"
        case startDate = "startDate"
        case endDate = "endDate"
        case lastViewedDate = "lastViewedDate"
        case lastUpdatedDate = "lastUpdatedDate"
        case createdDate = "createdDate"
        case viewCount = "viewCount"
        case usedCount = "usedCount"
        case spamReported = "spamReported"
        case members = "members"
        case tags = "tags"
        case todos = "todos"
        case events = "events"
        case places = "places"
        case experiences = "experiences"
        case plangoFavorite = "plangoFavorite"
    }
    
    var id: String!

    convenience init(id: String) {
        self.init()
        self.id = id
    }
    
    func getPropertyNames() -> [String] {
        return Mirror(reflecting: self).children.flatMap { $0.label }
    }
    
//    override class func primaryKey() -> String? {
//        return CodeKeys.id.rawValue
//    }
    
}

class PlangoString: Object {
    dynamic var stringValue = ""
}