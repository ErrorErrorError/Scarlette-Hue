//
//  AddSegmentFooterCell.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/15/22.
//

import Foundation
import UIKit

class AddSegmentFooterCell: UICollectionViewCell {
    let imageView = UIImageView().then {
        let largeConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "plus", withConfiguration: largeConfiguration)
        $0.tintColor = .label
        $0.contentMode = .center
        $0.image = image
        $0.backgroundColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.4)
        $0.layer.cornerRadius = 42/2
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    let label = UILabel().then {
        $0.text = "Add Segment"
        $0.font = .boldSystemFont(ofSize: 12)
        $0.textColor = .label
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)
        addSubview(label)

        backgroundColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
        layer.cornerRadius = 32 / 2

        imageView.do {
            $0.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
            $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 42).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 42).isActive = true
        }

        label.do {
            $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
            $0.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
