//
//  Feeding.swift
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

class Feeding: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _petId: String?
    var _amountEaten: NSNumber?
    var _date: NSNumber?
    var _foodName: String?
    var _time: NSNumber?
    var _foodId: String?
    
    class func dynamoDBTableName() -> String {

        return "hpet-mobilehub-642847546-Feeding"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {

        return "_petId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_userId" : "userId",
               "_petId" : "petId",
               "_amountEaten" : "amountEaten",
               "_date" : "date",
               "_foodName" : "foodName",
               "_time" : "time",
               "_foodId" : "foodId",
        ]
    }
}
