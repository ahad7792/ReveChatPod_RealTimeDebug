//
//  ViewController.swift
//  ReveChatDemoPod
//
//  Created by Ahad on 15/3/26.
//

import UIKit
import UserNotifications
import AVFoundation
import ReveChatSDK

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    // MARK: - ReveChatSDK visitor fields (storyboard)

    @IBOutlet weak var name_field: UITextField!
    @IBOutlet weak var accountID_field: UITextField!
    @IBOutlet weak var email_field: UITextField!
    @IBOutlet weak var mobile_field: UITextField!

    var visitor_name: String = ""
    var visitor_accountID: String = ""
    var visitor_email: String = ""
    var visitor_mobile: String = ""
    private var activeAccountID: String?
    private let lastAccountIDKey = "ReveChatDemo_LastAccountID"

    override func viewDidLoad() {
        super.viewDidLoad()

        requestPermissions()

        //accountID_field.text = "1361965"
        //accountID_field.text = "7871954"
        //accountID_field.text = "2552651"
        accountID_field.text = UserDefaults.standard.string(forKey: lastAccountIDKey) ?? "1487773"
        activeAccountID = UserDefaults.standard.string(forKey: lastAccountIDKey)
        name_field.text = "ahad"
        email_field.text = "ahad@gmail.com"
        mobile_field.text = "123123123"
        
//        ReveChatManager.shared().token = "Basic eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHRlcm5hbF9zeXN0ZW1fZW1haWwiOiJkdW1teTUwQG1haWxpbmF0b3IuY29tIiwiZmlyc3ROYW1lIjoiRHVtbXkiLCJsYXN0TmFtZSI6IkNhbmRpZGF0ZSBGaWZ0eSIsImNvbXBhbnlfaWQiOjE2NjAsInVzZXJfbmFtZSI6ImR1bW15NTBAbWFpbGluYXRvci5jb20iLCJzY29wZSI6WyJyZWFkIl0sImV4cCI6MTc3MjQyNjQ2OCwiYXV0aG9yaXRpZXMiOlsiY3JldyJdLCJqdGkiOiJmZDAzMWJmYy1mOWYxLTQ4ZTQtYWM2YS0wMTE5ODY2Nzc0ZTQiLCJjbGllbnRfaWQiOiJjcmV3YXBwX29hdXRoX3Byb2QifQ.CBvFZC3vnxV1_U7ipXF03SIHj99VmvaDnVjYMigUyNMKT_4v1eJnMHtKsh4rSjWmaoodUQdkxbHBJ4FQoHO-yt_6PYSQYihn86KBhLg4Vp6jnmqSD6eJ-UOjOr2bW5s7UmUk6chF2taK8WrSC9MB5FWezG1ZRIne8v2qeQooGHoOrw09e2Ui7LuejkbUsFixOGojJXywtjDUdHavv1QqhpxmFKeMMTZ_AX2fMB0im9-5r-lzc8uS7Xe9yuhnPykym56EYodmikAmGBbJplIdtvvh01U7GdMpZ2Lqeq_MVbI7MioWsBaf_ca0OhxA9Ip7G_A5pRQ2tGNjB-izkFDC0A"

        // ReveChatSDK: open chat when user taps push notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification(_:)),
                                               name: Notification.Name("MyNotification"),
                                               object: nil)

        // Fields disabled until user taps Edit
        name_field.isEnabled = false
        email_field.isEnabled = false
        mobile_field.isEnabled = false
        accountID_field.isEnabled = false
    }

    // MARK: - Permissions (ReveChatSDK: chat, camera, mic, push)

    func requestPermissions() {
        requestMicrophonePermission {
            self.requestCameraPermission {
                self.requestNotificationPermission()
            }
        }
    }

    func requestMicrophonePermission(completion: @escaping () -> Void) {
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { _ in
            DispatchQueue.main.async { completion() }
        }
    }

    func requestCameraPermission(completion: @escaping () -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { _ in
                DispatchQueue.main.async { completion() }
            }
        } else {
            completion()
        }
    }

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    // MARK: - ReveChatSDK: open chat from push

    @objc func handleNotification(_ notification: Notification) {
        ReveChatManager.shared()?.initiateReveChat(with: visitor_name, visitorEmail: visitor_email, visitorMobile: visitor_mobile, onNavigationViewController: self.navigationController)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Chat button (ReveChatSDK: launch chat with visitor details)

    @IBAction func ChatPressed(_ sender: UIButton) {
        print("[ReveChatDemo] ChatPressed called")
        visitor_name = name_field.text ?? ""
        visitor_accountID = accountID_field.text ?? ""
        visitor_email = email_field.text ?? ""
        visitor_mobile = mobile_field.text ?? ""

        print("[ReveChatDemo] visitor: name=\(visitor_name), accountID=\(visitor_accountID), email=\(visitor_email), mobile=\(visitor_mobile)")

        guard !visitor_name.isEmpty, !visitor_accountID.isEmpty, !visitor_email.isEmpty else {
            print("[ReveChatDemo] Validation failed: missing required fields")
            let alert = UIAlertController(title: "REVE Chat", message: "Edit and add details", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let navVC = self.navigationController
        print("[ReveChatDemo] navigationController is \(navVC == nil ? "nil" : "non-nil") – SDK needs nav to present chat")

        guard let manager = ReveChatManager.shared() else {
            print("[ReveChatDemo] ERROR: ReveChatManager.shared() is nil")
            return
        }

        let switchedAccount = activeAccountID != nil && activeAccountID != visitor_accountID
        if switchedAccount {
            print("[ReveChatDemo] Account changed from \(activeAccountID ?? "") to \(visitor_accountID). Clearing SDK session before switching.")
            manager.clearSessionInternalAndSetAccountId(visitor_accountID)
        }

        print("[ReveChatDemo] Calling setupAccount(with: \(visitor_accountID))")
        manager.setupAccount(with: visitor_accountID)
        activeAccountID = visitor_accountID
        UserDefaults.standard.set(visitor_accountID, forKey: lastAccountIDKey)

        if let nav = navVC {
            print("[ReveChatDemo] Calling initiateReveChat with navigationController")
            manager.initiateReveChat(with: visitor_name, visitorEmail: visitor_email, visitorMobile: visitor_mobile, onNavigationViewController: nav)
        } else {
            print("[ReveChatDemo] No navigationController – using initiateReveChat onViewController:self (modal from this VC)")
            manager.initiateReveChat(with: visitor_name, visitorEmail: visitor_email, visitorMobile: visitor_mobile, on: self)
        }
        print("[ReveChatDemo] ChatPressed finished")
    }

    // MARK: - Logout (ReveChatSDK: optional logout)

    @IBAction func logoutBtn(_ sender: UIButton) {
        // ReveChatManager.shared()?.logout()
    }

    // MARK: - Edit: allow editing visitor fields

    @IBAction func editBtn(_ sender: Any) {
        accountID_field.isEnabled = true
        name_field.isEnabled = true
        email_field.isEnabled = true
        mobile_field.isEnabled = true
    }

    // MARK: - UNUserNotificationCenterDelegate (ReveChatSDK push)

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let notificationIdentifier = response.notification.request.identifier

        if let aps = userInfo["aps"] as? [String: Any] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                ReveChatManager.shared()?.initiateReveChat(with: self.visitor_name, visitorEmail: self.visitor_email, visitorMobile: self.visitor_mobile, onNavigationViewController: self.navigationController)
            }
        } else if notificationIdentifier == "OutsideNotification"
            || notificationIdentifier.hasPrefix("ReveChatAgent_")
            || notificationIdentifier.hasPrefix("ReveChatLanding_") {
            let name = visitor_name.isEmpty ? (name_field.text ?? "") : visitor_name
            let email = visitor_email.isEmpty ? (email_field.text ?? "") : visitor_email
            let mobile = visitor_mobile.isEmpty ? (mobile_field.text ?? "") : visitor_mobile
            ReveChatManager.shared()?.initiateReveChat(with: name, visitorEmail: email, visitorMobile: mobile, onNavigationViewController: self.navigationController)
        }

        completionHandler()
    }
}
