//
//  User.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.12
//

import Foundation
import UIKit
import AWSDynamoDB

class User: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _currentFoodAmounts: [String: String]?
    var _currentFoodId: String?
    var _email: String?
    var _firstName: String?
    var _lastName: String?
    var _machineId: String?
    var _currentFoodTimes: [NSNumber]?
    var _petIds: [String]?
    
    class func dynamoDBTableName() -> String {

        return "hpet-mobilehub-642847546-User"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_userId" : "userId",
               "_currentFoodAmounts" : "currentFoodAmounts",
               "_currentFoodId" : "currentFoodId",
               "_email" : "email",
               "_firstName" : "firstName",
               "_lastName" : "lastName",
               "_machineId" : "machineId",
               "_petIds" : "petIds",
               "_currentFoodTimes" : "currentFoodTimes",
        ]
    }
}
