//
//  ViewController.swift
//  ios-social-slrequest-demo
//
//  Created by OkuderaYuki on 2017/03/07.
//  Copyright © 2017年 YukiOkudera. All rights reserved.
//

import UIKit
import Accounts
import Social

class ViewController: UIViewController {

    var accountStore = ACAccountStore()
    var twitterAcount: ACAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.twitterAccounts { [weak self] (accounts) in
            guard let weakSelf = self else { return }
            print("\(accounts.description)")
            
            if accounts.count == 1 {
                // アカウントが1つしかない場合
                weakSelf.twitterAcount = accounts[0]
            } else {
                // アカウントが複数ある場合
                weakSelf.selectTwitter(accounts: accounts)
            }
        }
    }
    
    //MARK:- setup
    
    /// 端末に登録されているTwitterアカウントの情報を取得する
    private func twitterAccounts(callback: @escaping ([ACAccount]) -> Void) {
        let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        
        // Twitterアカウントの利用要求
        accountStore.requestAccessToAccounts(with: accountType, options: nil) { [weak self] (granted, error) in
            guard let weakSelf = self else { return }
            
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            if !granted {
                print("Twitterアカウントの利用が許可されていません")
                return
            }
            guard let accounts = weakSelf.accountStore.accounts(with: accountType) as? [ACAccount] else {
                return
            }
            
            if accounts.count == 0 {
                print("Twitterアカウントが端末に登録されていません。\n設定アプリからアカウントを設定してください")
                return
            }
            print("アカウント取得完了")
            callback(accounts)
        }
    }
    
    /// 使用するアカウントを選択する
    private func selectTwitter(accounts: [ACAccount]) {
        let alertController = UIAlertController(title: "Twitter",
                                                message: "アカウントを選択してください",
                                                preferredStyle: .actionSheet)
        for account in accounts {
            alertController.addAction(UIAlertAction(title: account.username,
                                                    style: .default,
                                                    handler: { [weak self] (action) in
                                                        guard let weakSelf = self else { return }
                                                        weakSelf.twitterAcount = account
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- request
    
    /// 画像をアップロードする
    private func uploadImage(with account: ACAccount, image: UIImage, completion: @escaping (String?,Error?) -> Void) {
        let request = SLRequest.init(forServiceType: SLServiceTypeTwitter,
                                     requestMethod: .POST,
                                     url: URL.init(string: "https://upload.twitter.com/1.1/media/upload.json"),
                                     parameters: nil)
        
        request?.addMultipartData(UIImageJPEGRepresentation(image, 1.0),
                                  withName: "media",
                                  type: "image/jpeg",
                                  filename: "image.jpeg")
        request?.account = account
        request?.perform(handler: { (responseData, urlResponse, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let responseData = responseData else {
                completion(nil, error)
                return
            }
            
            let json: Dictionary<String, Any>?
            do {
                json = try JSONSerialization.jsonObject(with: responseData, options: [.mutableContainers]) as? Dictionary
            } catch {
                completion(nil, error)
                return
            }
            
            if let mediaIdString = json?["media_id_string"] as? String {
                completion(mediaIdString, nil)
            }
        })
    }
    
    
    /// ツイートする
    ///
    /// - Parameters:
    ///   - account: Twitterアカウント
    ///   - message: 投稿する文字列
    ///   - mediaIdString: 画像を投稿する場合のid(画像無しの場合はnilをセット)
    ///   - completion: completion
    private func post(with account: ACAccount, message: String, mediaIdString: String?, completion: @escaping (Error?) -> Void) {
        
        let params: Dictionary<String, Any>
        if let mediaIdString = mediaIdString {
            // 画像付きでツイートする場合
            params = ["media_ids": mediaIdString, "status": message]
        } else {
            // 画像なしの場合
            params = ["status": message]
        }
        
        
        let request = SLRequest.init(forServiceType: SLServiceTypeTwitter,
                                     requestMethod: .POST,
                                     url: URL.init(string: "https://api.twitter.com/1.1/statuses/update.json"),
                                     parameters: params)
        request?.account = account
        request?.perform(handler: { (responseData, urlResponse, error) in
            DispatchQueue.global(qos: .default).async {
                completion(error)
            }
        })
    }
    
    //MARK:- showAlert
    
    /// 画像付きでツイートするアラート
    private func imageTweetAlert(with account: ACAccount) {
        
        let titleString = String.init(format: "@%@", account.username)
        
        let alertController = UIAlertController(title: titleString,
                                                message: "Please enter your message",
                                                preferredStyle: .alert)
        
        //textfiledの追加
        alertController.addTextField(configurationHandler: nil)
        
        let tweetAction = UIAlertAction(title: "Tweet with images", style: .default, handler: { [weak self] (action) in
            guard let weakSelf = self else { return }
            
            let message = alertController.textFields?[0].text ?? "test tweet from ios"
            
            // テスト用の画像付きでツイートする
            weakSelf.uploadImage(with: account, image: #imageLiteral(resourceName: "image.jpeg")) { (mediaIdString, error) in
                print("mediaIdString:\(mediaIdString)")
                
                weakSelf.post(with: account,
                              message: message,
                              mediaIdString: mediaIdString,
                              completion: { (error) in
                                if let error = error {
                                    print("\(error.localizedDescription)")
                                    return
                                }
                                print("tweet success")
                })
            }
        })
        alertController.addAction(tweetAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// 画像無しでツイートするアラート
    private func tweetAlert(with account: ACAccount) {
        
        let titleString = String.init(format: "@%@", account.username)
        
        let alertController = UIAlertController(title: titleString,
                                                message: "Please enter your message",
                                                preferredStyle: .alert)
        
        //textfiledの追加
        alertController.addTextField(configurationHandler: nil)
        
        let tweetAction = UIAlertAction(title: "Tweet", style: .default, handler: { [weak self] (action) in
            guard let weakSelf = self else { return }
            
            let message = alertController.textFields?[0].text ?? "test tweet from ios"
            // ツイートする
            weakSelf.post(with: account,
                          message: message,
                          mediaIdString: nil,
                          completion: { (error) in
                            if let error = error {
                                print("\(error.localizedDescription)")
                                return
                            }
                            print("tweet success")
            })
        })
        alertController.addAction(tweetAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- IBAction

    @IBAction func tappedTwitter(_ sender: Any) {
        guard let twitterAcount = twitterAcount else { return }
        
        // サンプル画像付きでツイートする場合
        //        self.imageTweetAlert(with: twitterAcount)
        
        // サンプル画像無しでツイートする場合
        self.tweetAlert(with: twitterAcount)
    }
}

