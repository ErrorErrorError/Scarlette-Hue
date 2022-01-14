//
//  ManuallyAddDeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/16/21.
//

import UIKit
import Then

class ManuallyAddDeviceViewController: UIViewController {

    let titleLabel = UILabel().then {
        $0.text = "Set WLED Information"
        $0.font = UIFont.boldSystemFont(ofSize: 24)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
