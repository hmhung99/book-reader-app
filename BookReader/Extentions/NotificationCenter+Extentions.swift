//
//  NotificationCenter+Extentions.swift
//  BookReader
//
//  Created by hung on 27/06/2021.
//

import Foundation

extension Notification.Name {
    static var finishReview: Notification.Name {
          return .init(rawValue: "finishReview") }
    static var didLoginLogout: Notification.Name {
          return .init(rawValue: "didLoginLogout") }
    static var tapLikeBook: Notification.Name {
          return .init(rawValue: "tapLikeBook") }
}
