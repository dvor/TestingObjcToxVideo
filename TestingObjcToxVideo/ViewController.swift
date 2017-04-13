//
//  ViewController.swift
//  TestingObjcToxVideo
//
//  Created by Dmytro Vorobiov on 12/04/2017.
//  Copyright © 2017 dvor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var toxManager: OCTManager!
    var requestsToken: RLMNotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        DDLog.add(DDASLLogger.sharedInstance())
        DDLog.add(DDTTYLogger.sharedInstance())

        let configuration = OCTManagerConfiguration.default()
        OCTManagerFactory.manager(with: configuration, encryptPassword: "123", successBlock: { [weak self] manager in
            self?.toxManager = manager
            self?.didCreateManager()
        }) { error in
            print(error)
        }
    }

    func didCreateManager() {
        print("Tox ID: " + toxManager.user.userAddress)

        toxManager.bootstrap.addPredefinedNodes()
        toxManager.bootstrap.bootstrap()
        toxManager.calls.delegate = self

        autoApproveFriendRequests()
    }

    func autoApproveFriendRequests() {
        let results = toxManager.objects.objects(for: .friendRequest, predicate: nil)
        requestsToken = results?.addNotificationBlock({ [weak self] (results, change, error) in
            guard let results = results else {
                return
            }

            for index in 0..<results.count {
                guard let request = results[UInt(index)] as? OCTFriendRequest else {
                    continue
                }

                _ = try? self?.toxManager.friends.approve(request)
            }
        })
    }
}

extension ViewController: OCTSubmanagerCallDelegate {
    func callSubmanager(_ callSubmanager: OCTSubmanagerCalls!, receive call: OCTCall!, audioEnabled: Bool, videoEnabled: Bool) {
        _ = try? toxManager.calls.answer(call, enableAudio: true, enableVideo: true)
    }
}
