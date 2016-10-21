//
//  NetworkService.swift
//  NSManchester
//
//  Created by Ross Butler on 15/01/2016.
//  Copyright © 2016 Ross Butler. All rights reserved.
//

import Foundation

let NSMNetworkUpdateNotification = "network-update-notification"

class NetworkService : NSObject {
    
    func update(_ completion: (()->())? = nil) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(url: URL(string: "https://raw.githubusercontent.com/NSManchester/nsmanchester-app/master/NSManchester/NSManchester.json")!)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            if (error == nil) {
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("Success: \(statusCode)")
                
                if let parsedData = ParsingService().parse(data!)
                {
                    
                    let text = String(data: data!, encoding: String.Encoding.utf8)
                    print(parsedData)
                    let file = "nsmanchester.json"
                    if let dir : String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
                        
                        let dirURL = URL(fileURLWithPath: dir).appendingPathComponent(file);
                        
                        do {
                            
                            try text!.write(toFile: dirURL.path, atomically: false, encoding: String.Encoding.utf8)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: NSMNetworkUpdateNotification), object: nil)
                            
                            if let successBlock = completion {
                                successBlock();
                            }
                            
                        }
                        catch {
                        }
                    }
                }
            }
            else {
                // Failure
                print("Failure:", error!.localizedDescription);
            }
        });
        task.resume()
    }
}
