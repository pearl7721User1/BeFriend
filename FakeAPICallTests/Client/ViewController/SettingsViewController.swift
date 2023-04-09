//
//  SettingsViewController.swift
//  FakeAPICallTests
//
//  Created by Giwon Seo on 2023/04/07.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var responseTimeSegment: UISegmentedControl!
    
    @IBOutlet weak var failureRatioSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        responseTimeSegment.selectedSegmentIndex = ServerSettings.shared.responseTime.rawValue
        failureRatioSegment.selectedSegmentIndex = ServerSettings.shared.failureRatio.rawValue
        
    }
    
    @IBAction func responseTimeChanged(_ sender: UISegmentedControl) {
        if let newValue = ServerSettings.ResponseTime.init(rawValue: sender.selectedSegmentIndex) {
            ServerSettings.shared.updateResponseTime(to: newValue)
        }
    }
    
    @IBAction func failureRatioChanged(_ sender: UISegmentedControl) {
        if let newValue = ServerSettings.FailureRatio.init(rawValue: sender.selectedSegmentIndex) {
            ServerSettings.shared.updateFailureRatio(to: newValue)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
