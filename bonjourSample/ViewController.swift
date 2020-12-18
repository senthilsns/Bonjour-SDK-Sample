//
//  ViewController.swift
//  bonjourSample
//
//  Created by Senthil Kumar2 on 26/11/20.
//  Copyright © 2020 Mavenir. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController,NetServiceDelegate,NetServiceBrowserDelegate,GCDAsyncSocketDelegate {
    
    
    
    
    @IBAction func hostAction(_ sender: Any) {
        startPublisher()

    }
    
    @IBAction func clientAction(_ sender: Any) {
    }
    
    private var service: NetService!
    private var socket: GCDAsyncSocket!

    

    func startPublisher(){
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        var error: NSError?
        do {
            try socket.accept(onPort: 7001)
            print("Socket Created")
            // Random
            let nameStr = "linkM\(getRandomNumber())"
            print(nameStr)
               
            // Publish
            service = NetService(domain: "local.", type: "_multipeertest._tcp.", name: nameStr, port: Int32(socket.localPort))
            
            print("Local port \(socket.localPort)")
            service.delegate = self
            service.publish()
            
            
        }catch let err as NSError{
            error = err
            print("Unable to Create Socket. \(String(describing: error!))")
            
        }
    
    }

    var dataCache = Data()
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
           print("Closed with error: \(String(describing: err))")
           if socket == socket {
               socket.delegate = nil
               self.socket = nil
           }
       }
    
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
          print("Did Accept New Socket")
          // Socket
          self.socket = newSocket

          // Read Data from Socket
          newSocket.readData(toLength: UInt(MemoryLayout<UInt64>.size), withTimeout: -1.0, tag: 0)
      }


    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        dataCache.append(data)
        sock.readData(withTimeout: -1, tag: 0)
        
        let str = String(decoding: dataCache, as: UTF8.self)
        print(str)
    }

    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        sock.readData(withTimeout: -1, tag: 0)
    }


   
    func socketDidCloseReadStream(_ sock: GCDAsyncSocket) {
        print("Closed successfully")
        processData()
    }

    func processData() {
        // Do something with dataCache eg print it out:
        print("The following read payload:\(String(data:dataCache, encoding: .utf8) ?? "Read data invalid")")
        dataCache = Data()

    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
      
    }


    //MARK: NetService Delegate
    func netServiceDidPublish(_ sender: NetService){
        
         print("Bonjour service published. domain: \(sender.domain), type: \(sender.type), name: \(sender.name), port: \(sender.port)")
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        
          print("Unable to create socket. domain: \(sender.domain), type: \(sender.type), name: \(sender.name), port: \(sender.port), Error \(errorDict)")
        
    }
    
    


    
    //MARK: 4 Digit Random Number
     func getRandomNumber() -> String {
        var result = ""
        repeat {
            result = String(format:"%04d", arc4random_uniform(10000) )
        } while result.count < 4
        return result
    }

}

