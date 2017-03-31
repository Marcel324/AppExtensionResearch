//
//  TodayViewController.swift
//  Example Extension
//
//  Created by Marcel Chaucer on 3/29/17.
//  Copyright © 2017 Marcel Chaucer. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    var fileSystemSize: Int?
    var freeSize: Int?
    var usedSize: Int?
    let RATE_KEY = "kUDRateUsed"
    let kWClosedHeight =  37.0
    let kWExpandedHeight = 106.0
    var usedRate: Double? {
        return UserDefaults.standard.double(forKey: RATE_KEY)
    }
    
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateInterface()
        detailLabel.alpha = 0.0
        //extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
    }
    
    
    func updateDetailsLabel() {
        let formatter = ByteCountFormatter.init()
        formatter.countStyle = .file
        detailLabel.text = String(format: "Used:\t%@\nFree:\t%@\nTotal:\t%@", formatter.string(fromByteCount: Int64(usedSize!)), formatter.string(fromByteCount: Int64(freeSize!)), formatter.string(fromByteCount: Int64(fileSystemSize!)))
    }
    
    
    func setUsedRate(usedRate: Double) -> Void {
        let defaults = UserDefaults.standard
        defaults.set(usedRate, forKey: RATE_KEY)
        defaults.synchronize()
    }
    
    func updateInterface() {
        let rate = usedRate
        percentageLabel.text = String(format: "%.1f%%", rate! * 100)
        progressView.progress = Float(rate!)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.updateDetailsLabel()
        self.preferredContentSize = CGSize(width: 0.1, height: kWExpandedHeight)
        self.detailLabel.alpha = 1.0
        print("I'm being tapped")
    }
    
    
    func updateSizes() {
        
    var dict = try! FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        
    // Set the values
    self.fileSystemSize = dict[.systemSize] as? Int
    self.freeSize = dict[.systemFreeSize] as? Int
    self.usedSize  = self.fileSystemSize! - self.freeSize!
        
    }
    
 
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
       updateSizes()
        
        let newRate: Double = Double(self.usedSize!) / Double(self.fileSystemSize!)
        if (Double(newRate) - Double(usedRate!)) < 0.0001 {
            completionHandler(NCUpdateResult.newData)
        } else {
            setUsedRate(usedRate: Double(newRate))
            updateInterface()
            completionHandler(NCUpdateResult.newData)
        }
    }
}
