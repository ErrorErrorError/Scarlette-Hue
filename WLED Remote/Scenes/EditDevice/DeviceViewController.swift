//
//  DeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/12/21.
//

import UIKit

class DeviceViewController: UIViewController {

    var presets: [Preset] = []
    var device: Device?

    let switchButton = UISwitch(frame: .zero)

    static let buttonSize: CGFloat = 32

    let scrollView: UIScrollView = {
        let scroll = UIScrollView(frame: .zero)
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()

    let brightnessBar: BrightnessSlider = {
        let bar = BrightnessSlider(frame: .zero)
        return bar
    }()

    let settingsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gearshape"), for: .normal)
        button.backgroundColor = UIColor.secondarySystemBackground
        button.layer.cornerRadius = DeviceViewController.buttonSize / 2
        return button
    }()

    let effectsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "wand.and.stars.inverse"), for: .normal)
        button.backgroundColor = UIColor.secondarySystemBackground
        button.layer.cornerRadius = DeviceViewController.buttonSize / 2
        return button
    }()

    let infoButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "info.circle")
        button.setImage(image, for: .normal)
        button.backgroundColor = UIColor.secondarySystemBackground
        button.layer.cornerRadius = DeviceViewController.buttonSize / 2
        return button
    }()

    let colorsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Colors"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()

    let colorWellPrimary: UIColorWell = {
        let well = UIColorWell(frame: .zero)
        well.selectedColor = .red
        well.supportsAlpha = false
        return well
    }()

    let colorWellSecondary: UIColorWell = {
        let well = UIColorWell(frame: .zero)
        well.selectedColor = .green
        well.supportsAlpha = false
        return well
    }()

    let colorWellTertiary: UIColorWell = {
        let well = UIColorWell(frame: .zero)
        well.selectedColor = .blue
        well.supportsAlpha = false
        return well
    }()

    let paletteLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Palette"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()

    let paletteCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()

    var oldNavColor: UIColor! = nil

    var oldShadowLine: UIImage! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        let barButton = UIBarButtonItem(customView: switchButton)
        navigationItem.setRightBarButton(barButton, animated: true)

        brightnessBar.layer.cornerRadius = 28 / 2
        brightnessBar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        brightnessBar.clipsToBounds = true

        oldNavColor = navigationController!.navigationBar.standardAppearance.backgroundColor
//        oldShadowLine = self.navigationController?.navigationBar.shadowImage
//        brightnessBar.backgroundColor = oldNavColor
//        self.navigationController?.navigationBar.shadowImage = UIImage() // remove shadow image

        // Add brightness

        let buttonStackView = UIStackView(arrangedSubviews: [effectsButton, infoButton, settingsButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 16

        let colorsStackView = UIStackView(arrangedSubviews: [colorsLabel, colorWellPrimary, colorWellSecondary, colorWellTertiary])
        colorsStackView.axis = .horizontal
        colorsStackView.alignment = .center
        colorsStackView.distribution = .fill
        colorsStackView.spacing = 16

        let paletteStackView = UIStackView(arrangedSubviews: [paletteLabel, paletteCollectionView])
        paletteStackView.axis = .vertical
        paletteStackView.spacing = 8

        view.addSubview(scrollView)
        view.addSubview(brightnessBar)

        scrollView.addSubview(buttonStackView)
        scrollView.addSubview(colorsStackView)
        scrollView.addSubview(paletteStackView)

        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        scrollView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        // Auto Layout
        brightnessBar.heightAnchor.constraint(equalToConstant: 28).isActive = true
        brightnessBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        brightnessBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        brightnessBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true

        scrollView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: brightnessBar.bottomAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true

        buttonStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        buttonStackView.topAnchor.constraint(equalTo: brightnessBar.bottomAnchor, constant: 16).isActive = true
        buttonStackView.heightAnchor.constraint(equalToConstant: DeviceViewController.buttonSize).isActive = true

        colorsStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        colorsStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        colorsStackView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 16).isActive = true

        paletteStackView.topAnchor.constraint(equalTo: colorsStackView.bottomAnchor, constant: 16).isActive = true
        paletteStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        paletteStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor ).isActive = true
        paletteStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        if let device = device {
            title = device.name
            if let state = device.state {
                setData(from: state)
            }
        }
    }

    private func setData(from state: State) {
        switchButton.isOn = state.on == true
        if (switchButton.isOn) {
            // Animate view

            brightnessBar.value = Float(state.bri ?? 0)

            if let segment = state.firstSegment {
                if let firstColor = segment.colors?[0] {
                    colorWellPrimary.selectedColor = UIColor.getColor(red: firstColor[0], green: firstColor[1], blue: firstColor[2])
                }

                if let secondColor = segment.colors?[1] {
                    colorWellSecondary.selectedColor = UIColor.getColor(red: secondColor[0], green: secondColor[1], blue: secondColor[2])
                }

                if let thirdColor = segment.colors?[2] {
                    colorWellTertiary.selectedColor = UIColor.getColor(red: thirdColor[0], green: thirdColor[1], blue: thirdColor[2])
                }
            }
        } else {
            brightnessBar.backgroundColor = oldNavColor
            navigationController?.navigationBar.standardAppearance.backgroundColor = oldNavColor
            navigationController?.navigationBar.shadowImage = oldShadowLine
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.standardAppearance.backgroundColor = oldNavColor
//        navigationController?.navigationBar.shadowImage = oldShadowLine
    }
}

extension DeviceViewController: UICollectionViewDelegate {
    
}

extension DeviceViewController: UICollectionViewDelegateFlowLayout {

}

private extension UIColor {
    static func getColor(red: Int, green: Int, blue: Int) -> UIColor {
        return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1.0)
    }
}
