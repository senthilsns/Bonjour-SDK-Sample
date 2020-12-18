//
//  bonjourClientViewController.swift
//  bonjourSample
//
//  Created by Senthil Kumar2 on 01/12/20.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit
import CocoaAsyncSocket



class bonjourClientViewController: UIViewController,NetServiceDelegate,NetServiceBrowserDelegate,GCDAsyncSocketDelegate,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet var serviceTableView: UITableView!
    
    private var socket: GCDAsyncSocket!
    private var serviceBrowser: NetServiceBrowser!
    var services = [AnyObject]()


    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        serviceTableView.delegate = self
        serviceTableView.dataSource = self
        
        startBrowsing()
    }
    
    func startBrowsing() {
        if services.isEmpty == false {
            services.removeAll()
        } else {
            services = [AnyObject]()
        }

        // Initialize Service Browser
        serviceBrowser = NetServiceBrowser()

        // Configure Service Browser
        serviceBrowser.delegate = self
        serviceBrowser.searchForServices(ofType: "_multipeertest._tcp.", inDomain: "local.")
    }
    
    
    func stopBrowsing() {
        
        if (serviceBrowser != nil) {
            serviceBrowser.stop()
            serviceBrowser.delegate = nil
            self.serviceBrowser = nil
        }
    }

    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool){
        
        services.append(service)

        if !moreComing {
            // Sort Services
         //   services = services.sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)]) as? [AnyHashable] ?? services

            // Update Table View
            serviceTableView.reloadData()
        }
    }

    
     func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool)
     {
        
        // Update Services
        services.removeAll { $0 as AnyObject === service as AnyObject }

        if !moreComing {
            // Update Table View
            serviceTableView.reloadData()
        }
        
    }

    
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser){
        
        stopBrowsing()
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]){
        
        stopBrowsing()
    }

    
    // Connection
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]){
        
        sender.delegate = nil
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        
        
    }

    
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print(String(format: "Socket Did Connect to Host: %@ Port: %hu", host, port))

        // Start Reading
        sock.readData(withTimeout: -1, tag: 0)

    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Socket Did Disconnect with Error \(String(describing: err)) with User Info \((err! as NSError).userInfo).")

             socket.delegate = nil
             self.socket = nil
    }
      

    
    func connect(with service: NetService?) -> Bool {
        var _isConnected = false

        // Copy Service Addresses
        let addresses = service?.addresses

        if !(socket != nil) || !socket.isConnected {
            // Initialize Socket
            socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)

            // Connect
            while !_isConnected && addresses?.count != nil {
                let address = addresses?[0]

                var error: Error? = nil
                
//               // if socket.connect(toAddress: address, error: &error) {
//                    _isConnected = true
//                } else if let error = error {
//                    print("Unable to connect to address. Error \(error) with user info \((error as NSError).userInfo).")
//                }
            }
        } else {
            _isConnected = socket.isConnected
        }

        return _isConnected
    }
 
}



extension bonjourClientViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Fetch Service
        let service = services[indexPath.row] as? NetService

        // Resolve Service
        service?.delegate = self
        service?.resolve(withTimeout: 30.0)
      
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          
        return services.count
    }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell",
                    for: indexPath) as! ImageCell
        
        let service = services[indexPath.row] as? NetService
        
        cell.titleLbl?.text = service?.name
        return cell

      }
    
}

