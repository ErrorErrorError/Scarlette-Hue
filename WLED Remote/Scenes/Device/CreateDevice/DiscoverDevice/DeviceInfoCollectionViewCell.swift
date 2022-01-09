//
//  DeviceInfoCell.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/15/21.
//

import UIKit
import CoreData


class DeviceInfoCollectionViewCell: UICollectionViewCell {

    static let identifier = "device-info-cell"

    private let deviceImage: UIImageView = {
        let image = UIImage(systemName: "lightbulb.fill")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .label
        return imageView
    }()

    private let deviceNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "WLED"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    private let ipAddressLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "IP ADDRESS HERE"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous

        addSubview(deviceImage)
        addSubview(deviceNameLabel)
        addSubview(ipAddressLabel)

        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let inset: CGFloat = 8

        deviceImage.topAnchor.constraint(equalTo: topAnchor, constant: inset).isActive = true
        deviceImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset).isActive = true
        deviceImage.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25).isActive = true
        deviceImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.25).isActive = true

        deviceNameLabel.topAnchor.constraint(equalTo: deviceImage.bottomAnchor, constant: inset * 2).isActive = true
        deviceNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset).isActive = true
        deviceNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant:  -inset).isActive = true

        ipAddressLabel.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: inset / 4).isActive = true
        ipAddressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset).isActive = true
        ipAddressLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset).isActive = true
        ipAddressLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(viewModel: DeviceInfoItemViewModel) {
        deviceNameLabel.text = viewModel.name
        ipAddressLabel.text = viewModel.ip
    }
}
