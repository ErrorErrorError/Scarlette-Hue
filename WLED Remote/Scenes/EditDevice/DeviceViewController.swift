//
//  DeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/12/21.
//

import UIKit
import RxSwift
import RxCocoa
import simd

class DeviceViewController: UIViewController {
    static let buttonSize: CGFloat = 32

    var topBarHeight: CGFloat {
        var top = self.navigationController?.navigationBar.frame.height ?? 0.0
        if let manager = self.view.window?.windowScene?.statusBarManager {
           top += manager.statusBarFrame.height
        }

        return top
    }

    // MARK: Rx

    private var disposeBag = DisposeBag()

    // MARK: View Model

    var viewModel: DeviceViewModel!

    // MARK: Views

    let switchButton: UISwitch = {
        let view = UISwitch(frame: .zero)
        view.onTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20)
        view.tintColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
        return view
    }()

    let scrollView: UIScrollView = {
        let scroll = UIScrollView(frame: .zero)
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()

    private let backgroundNavigationHeight: CGFloat = 50
    private var backgroundNavigationHeightLayout: NSLayoutConstraint!

    let backgroundNavigationView: GradientView = {
        let view = GradientView(frame: .zero)
        view.backgroundColor = .contentOverSystembackground
        view.layer.cornerRadius = 14
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = true
        return view
    }()

    let brightnessBar: BrightnessSlider = {
        let bar = BrightnessSlider(frame: .zero)
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()

    let settingsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gearshape"), for: .normal)
        button.backgroundColor = .contentOverSystembackground
        button.layer.cornerRadius = DeviceViewController.buttonSize / 2
        return button
    }()

    let effectsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "wand.and.stars.inverse"), for: .normal)
        button.backgroundColor = .contentOverSystembackground
        button.layer.cornerRadius = DeviceViewController.buttonSize / 2
        return button
    }()

    let infoButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "info.circle")
        button.setImage(image, for: .normal)
        button.backgroundColor = .contentOverSystembackground
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
        well.title = "Primary Color"
        well.selectedColor = .red
        well.supportsAlpha = false
        return well
    }()

    let colorWellSecondary: UIColorWell = {
        let well = UIColorWell(frame: .zero)
        well.title = "Secondary Color"
        well.selectedColor = .green
        well.supportsAlpha = false
        return well
    }()

    let colorWellTertiary: UIColorWell = {
        let well = UIColorWell(frame: .zero)
        well.title = "Tertiary Color"
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

    // MARK: Original Appearance

    private var navigationBarCompact: UINavigationBarAppearance?
    private var navigationBarStandard: UINavigationBarAppearance?
    private var navigationBarScroll: UINavigationBarAppearance?
}

// MARK: - Lifecycle

extension DeviceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewsAndConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposeBag = DisposeBag()
        setupNavigationBar()
        bindViewController()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.standardAppearance = navigationBarStandard ?? UINavigationBarAppearance()
            navigationBar.scrollEdgeAppearance = navigationBarScroll
            navigationBar.compactAppearance = navigationBarCompact
            navigationBar.largeTitleTextAttributes = [.foregroundColor : UIColor.label]
            navigationBar.barStyle = .default
            navigationBarStandard = nil
            navigationBarScroll = nil
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundNavigationHeightLayout.constant = topBarHeight + backgroundNavigationHeight
    }
}

// MARK: - Setup

extension DeviceViewController {
    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            if navigationBarStandard == nil { navigationBarStandard = navigationBar.standardAppearance }
            if navigationBarScroll == nil { navigationBarScroll = navigationBar.scrollEdgeAppearance }
            if navigationBarCompact == nil { navigationBarCompact = navigationBar.compactAppearance }

            let titleAppearance = UINavigationBarAppearance()
            titleAppearance.configureWithTransparentBackground()
            titleAppearance.shadowImage = nil
            titleAppearance.backgroundImage = nil

            navigationBar.standardAppearance = titleAppearance
            navigationBar.scrollEdgeAppearance = titleAppearance
            navigationBar.compactAppearance = titleAppearance
        }
    }

    private func setupViewsAndConstraints() {
        let barButton = UIBarButtonItem(customView: switchButton)
        navigationItem.setRightBarButton(barButton, animated: true)
        view.backgroundColor = .mainSystemBackground

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

        backgroundNavigationView.addSubview(brightnessBar)

        scrollView.addSubview(buttonStackView)
        scrollView.addSubview(colorsStackView)
        scrollView.addSubview(paletteStackView)

        view.addSubview(backgroundNavigationView)
        view.addSubview(scrollView)

        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        scrollView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        backgroundNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundNavigationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundNavigationHeightLayout = backgroundNavigationView.heightAnchor.constraint(equalToConstant: topBarHeight + backgroundNavigationHeight)
        backgroundNavigationHeightLayout.isActive = true

        brightnessBar.leadingAnchor.constraint(equalTo: backgroundNavigationView.leadingAnchor, constant: 16).isActive = true
        brightnessBar.trailingAnchor.constraint(equalTo: backgroundNavigationView.trailingAnchor, constant: -16).isActive = true
        brightnessBar.bottomAnchor.constraint(equalTo: backgroundNavigationView.bottomAnchor, constant: -20).isActive = true
        brightnessBar.heightAnchor.constraint(equalToConstant: 28).isActive = true

        scrollView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: backgroundNavigationView.bottomAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true

        buttonStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        buttonStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16).isActive = true
        buttonStackView.heightAnchor.constraint(equalToConstant: DeviceViewController.buttonSize).isActive = true

        colorsStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        colorsStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        colorsStackView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 16).isActive = true

        paletteStackView.topAnchor.constraint(equalTo: colorsStackView.bottomAnchor, constant: 16).isActive = true
        paletteStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        paletteStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor ).isActive = true
        paletteStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}

// MARK: - Rx Binding

extension DeviceViewController {
    private func bindViewController() {
        assert(viewModel != nil)

        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let traitCollectionChanged = rx.sentMessage(#selector(UIViewController.traitCollectionDidChange(_:)))
            .map({ _ in self.switchButton.isOn })
            .asDriverOnErrorJustComplete()

        let colorChanged = Driver.merge(colorWellPrimary.rx.controlEvent(.valueChanged).asDriver(),
                                        colorWellSecondary.rx.controlEvent(.valueChanged).asDriver(),
                                        colorWellTertiary.rx.controlEvent(.valueChanged).asDriver())
            .debounce(.milliseconds(250))
            .map { _ -> [[Int]] in
                if let primary = self.colorWellPrimary.selectedColor,
                   let secondary = self.colorWellSecondary.selectedColor,
                   let tertiary = self.colorWellTertiary.selectedColor {
                    return [primary.intArray, secondary.intArray, tertiary.intArray]
                }
                return []
            }

        let input = DeviceViewModel.Input(effectTrigger: effectsButton.rx.tap.asDriver(),
                                          infoTrigger: infoButton.rx.tap.asDriver(),
                                          settingsTrigger: settingsButton.rx.tap.asDriver(),
                                          fetchState: viewWillAppear,
                                          updateColors: colorChanged,
                                          updateBrightness: brightnessBar.rx.value.asDriver()
                                            .debounce(.milliseconds(250))
                                            .map({ Int($0) }),
                                          updateOn: Driver.merge(switchButton.rx.value.asDriver(), traitCollectionChanged))

        let output = viewModel.transform(input: input)
        output.settings.drive().disposed(by: disposeBag)
        output.info.drive().disposed(by: disposeBag)
        output.effects.drive().disposed(by: disposeBag)
        output.device.drive(deviceBinding).disposed(by: disposeBag)
        output.state.drive(stateBinding).disposed(by: disposeBag)
        output.updated.drive().disposed(by: disposeBag)
    }

    var deviceBinding: Binder<Device> {
        return Binder(self) { vc, device in
            vc.title = device.name
        }
    }

    var stateBinding: Binder<State> {
        return Binder(self, binding: { (vc, state) in
            var colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
            var deviceNameTextColor = UIColor.label

            vc.switchButton.isOn = state.on == true
            vc.brightnessBar.value = Float(state.bri ?? 1)

            if let segment = state.firstSegment {
                let firstColor = segment.colors[0]
                let firstColorUI = UIColor(red: firstColor[0], green: firstColor[1], blue: firstColor[2])
                vc.colorWellPrimary.selectedColor = firstColorUI

                let secondColor = segment.colors[1]
                let secondColorUI = UIColor(red: secondColor[0], green: secondColor[1], blue: secondColor[2])
                vc.colorWellSecondary.selectedColor = secondColorUI

                let thirdColor = segment.colors[2]
                let thirdColorUI = UIColor(red: thirdColor[0], green: thirdColor[1], blue: thirdColor[2])
                vc.colorWellTertiary.selectedColor = thirdColorUI
            } else {
                vc.colorWellPrimary.selectedColor = UIColor.black
                vc.colorWellSecondary.selectedColor = UIColor.black
                vc.colorWellTertiary.selectedColor = UIColor.black
            }

            // Get colors

            if state.on == true, let segment = state.firstSegment {
                // Set background color
                let primary = segment.colors[0]
                let secondary = segment.colors[1]
                let tertiary = segment.colors[2]

                var newColors = [primary, secondary, tertiary]
                    .filter({ $0.reduce(0, +) != 0 })
                    .map({ UIColor(red: $0[0], green: $0[1], blue: $0[2]).cgColor })

                if newColors.count == 1 {
                    newColors.append(newColors[0])
                }

                colors = newColors

                if let first = newColors.first {
                    let color = UIColor(cgColor: first)
                    deviceNameTextColor = color.isLight ? .black : .white
                }
            }

            // Set colors to navigation

            if let gradientLayer = vc.backgroundNavigationView.layer as? CAGradientLayer {
                gradientLayer.changeGradients(colors, animate: true)
            }

            if let navigationBar = vc.navigationController?.navigationBar {
                navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: deviceNameTextColor]
                navigationBar.scrollEdgeAppearance?.largeTitleTextAttributes = [.foregroundColor: deviceNameTextColor]
                navigationBar.compactAppearance?.titleTextAttributes = [.foregroundColor: deviceNameTextColor]
                if deviceNameTextColor == .white || deviceNameTextColor == .black {
                    navigationBar.barStyle = deviceNameTextColor == .white ? .black : .default
                } else {
                    navigationBar.barStyle = .default
                }
    
                vc.setNeedsStatusBarAppearanceUpdate()

                UIView.animate(withDuration: 0.2) {
                    navigationBar.tintColor = deviceNameTextColor
                }
            }
        })
    }
}
