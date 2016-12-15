//
//  Functions.swift
//  Location Journal
//
//  Created by David Wang on 12/15/16.
//  Copyright © 2016 David Wang. All rights reserved.
//

import Foundation
import Dispatch

let MyManagedObjectContextSaveDidFailNotification = Notification.Name(
    rawValue: "MyManagedObjectContextSaveDidFailNotification")
func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(
        name: MyManagedObjectContextSaveDidFailNotification, object: nil)
}

