//
//  HPetMainViewController.swift
//  MySampleApp
//
//  Created by Admin on 3/27/17.
//
//

import Foundation
import UIKit
import AWSMobileHubHelper

class HPetMainViewController: UIViewController {
    
    var signInObserver: AnyObject!
    var signOutObserver: AnyObject!
    var newUserObserver: AnyObject!
    
    fileprivate let loginButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
    
    // MARK: View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentSignInViewController()
        
        signInObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: AWSIdentityManager.default(), queue: OperationQueue.main, using: {[weak self] (note: Notification) -> Void in
            guard let strongSelf = self else { return }
            print("Sign In Observer observed sign in.")
            strongSelf.setupRightBarButtonItem()
        })
        
        signOutObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignOut, object: AWSIdentityManager.default(), queue: OperationQueue.main, using: {[weak self](note: Notification) -> Void in
            guard let strongSelf = self else { return }
            print("Sign Out Observer observed sign out.")
            strongSelf.setupRightBarButtonItem()
        })
        
        newUserObserver = NotificationCenter.default.addObserver(self, selector: #selector(HPetMainViewController.presentNewUserViewController), name: NSNotification.Name(rawValue: "newUser"), object: nil) as AnyObject!
        
        setupRightBarButtonItem()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(signInObserver)
        NotificationCenter.default.removeObserver(signOutObserver)
        NotificationCenter.default.removeObserver(newUserObserver)
    }
    
    func setupRightBarButtonItem() {
        navigationItem.rightBarButtonItem = loginButton
        navigationItem.rightBarButtonItem!.target = self
        
        if (AWSIdentityManager.default().isLoggedIn) {
            navigationItem.rightBarButtonItem!.title = NSLocalizedString("Sign-Out", comment: "Label for the logout button.")
            navigationItem.rightBarButtonItem!.action = #selector(MainViewController.handleLogout)
        }
    }
    
    // MARK: View presenting
    
    func presentSignInViewController() {
        if AWSIdentityManager.default().isLoggedIn == false {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "Initial")
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func presentNewUserViewController() {
        if AWSIdentityManager.default().isLoggedIn {
            let storyboard = UIStoryboard(name: "NewUser", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "NewUser")
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func handleLogout() {
        if (AWSIdentityManager.default().isLoggedIn) {
            AWSIdentityManager.default().logout(completionHandler: {(result: Any?, error: Error?) in
                self.setupRightBarButtonItem()
                self.presentSignInViewController()
            })
        } else {
            assert(false)
        }
    }
    
    // MARK: IB Actions
    
    @IBAction func didSelectLogout(_ sender: Any) {
        handleLogout()
    }
    
    @IBAction func didSelectSettings(_ sender: Any) {
        print("Settings")
    }
    
    @IBAction func didSelectAddFood(_ sender: Any) {
        print("Add food")
    }
    
}









