//
//  ViewController.swift
//  BluetoothDiscoveryApp
//
//  Created by Venky on 21/10/23.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    var centralManager: CBCentralManager?
    var names: [String] = []
    var RSSIs: [NSNumber] = []
    var timer: Timer?

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
   
    
    

    @IBAction func refreshTapped(_ sender: Any) {
        startScan()
        startTimer()
        
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] (timer) in
            self?.startScan()
        })
    }
    
    func startScan() {
        
        names = []
        RSSIs = []
        tableView.reloadData()
        centralManager?.stopScan()
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
        
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "bluecell", for: indexPath) as? BlueTableViewCell else { return UITableViewCell() }
        cell.nameLabel.text = names[indexPath.row]
        cell.rssiLabel.text = "RSSI: \(RSSIs[indexPath.row])"
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ViewController: CBCentralManagerDelegate {
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name {
            print("Peripherial Name: \(name)")
            names.append(name)
        } else {
            names.append(peripheral.identifier.uuidString)
        }
        RSSIs.append(RSSI)
        tableView.reloadData()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScan()
            startTimer()
            
        } else {
            let alertVC = UIAlertController(title: "Bluetooth isn't working", message: "Make sure your bluetooth is on and ready to rock and roll! ", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok",style: .default) { (action) in
                alertVC.dismiss(animated: true)
            }
            alertVC.addAction(okAction)
            present(alertVC, animated: true)
        }
    }
    
    
}
