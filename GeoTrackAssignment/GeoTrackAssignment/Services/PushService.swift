//
//  PushService.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import Foundation
import UserNotifications
import UIKit

public final class PushService: NSObject, UNUserNotificationCenterDelegate {
    public func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        if granted {
            await MainActor.run { UIApplication.shared.registerForRemoteNotifications() }
        }
    }
}
