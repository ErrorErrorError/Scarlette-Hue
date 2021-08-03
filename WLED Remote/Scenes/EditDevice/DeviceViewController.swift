//
//  DeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/12/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DeviceViewController: UICollectionViewController {
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

    let moreButton: UIButton = {
        let smallConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "ellipsis.circle.fill", withConfiguration: smallConfiguration)
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        return button
    }()

    private let backgroundBrightnessHeight: CGFloat = 50
    private var backgroundNavigationHeightLayout: NSLayoutConstraint!

    let backgroundNavigationView: GradientView = {
        let view = GradientView(frame: .zero)
        view.layer.shadowRadius = 8.0
        view.layer.shadowOpacity = 0.10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.cornerCurve = .continuous
        view.backgroundColor = .contentOverSystemBackground
        view.layer.cornerRadius = 14
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
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
        button.backgroundColor = .contentOverSystemBackground
        button.layer.cornerRadius = DeviceViewController.buttonSize / 2
        return button
    }()

    let effectsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "wand.and.stars.inverse"), for: .normal)
        button.backgroundColor = .contentOverSystemBackground
        button.layer.cornerRadius = DeviceViewController.buttonSize / 2
        return button
    }()

    let infoButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "info.circle")
        button.setImage(image, for: .normal)
        button.backgroundColor = .contentOverSystemBackground
        button.layer.cornerRadius = DeviceViewController.buttonSize / 2
        return button
    }()

    let colorsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Colors"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()

    let colorPicker: ChromaColorPicker = {
        let colorPicker = ChromaColorPicker(frame: .zero)
        return colorPicker
    }()

//    let colorWellPrimary: UIColorWell = {
//        let well = UIColorWell(frame: .zero)
//        well.title = "Primary Color"
//        well.selectedColor = .red
//        well.supportsAlpha = false
//        return well
//    }()
//
//    let colorWellSecondary: UIColorWell = {
//        let well = UIColorWell(frame: .zero)
//        well.title = "Secondary Color"
//        well.selectedColor = .green
//        well.supportsAlpha = false
//        return well
//    }()
//
//    let colorWellTertiary: UIColorWell = {
//        let well = UIColorWell(frame: .zero)
//        well.title = "Tertiary Color"
//        well.selectedColor = .blue
//        well.supportsAlpha = false
//        return well
//    }()

    let paletteLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Palette"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()

    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [effectsButton, infoButton, settingsButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()

    lazy var colorsStackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [colorsLabel, colorWellPrimary, colorWellSecondary, colorWellTertiary])
//        stackView.axis = .horizontal
        let stackView = UIStackView(arrangedSubviews: [colorsLabel, colorPicker])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 16
        return stackView
    }()

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle

extension DeviceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViewsAndConstraints()
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposeBag = DisposeBag()
        bindViewController()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundNavigationHeightLayout.constant = topBarHeight + backgroundBrightnessHeight
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            backgroundNavigationHeightLayout.constant += abs(scrollView.contentOffset.y)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
}

// MARK: - Setup

extension DeviceViewController {
    private func setupCollectionView() {
        collectionView.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader.self, withReuseIdentifier: "supplementary")
        collectionView.register(PaletteCollectionViewCell.self, forCellWithReuseIdentifier: PaletteCollectionViewCell.identifier)
        collectionView.bounces = true
        collectionView.delegate = self
        collectionView.dataSource = nil
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = true
        collectionView.contentInset.left = 16
        collectionView.contentInset.right = 16
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 4
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            let availableWidth = collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right - layout.sectionInset.left - layout.sectionInset.right
            layout.estimatedItemSize = CGSize(width: availableWidth / 2 - layout.minimumInteritemSpacing, height: 100)
            layout.headerReferenceSize = CGSize(width: availableWidth, height: 120)
        }
    }

    private func setupNavigationBar() {
        let switchBarButton = UIBarButtonItem(customView: switchButton)
        let moreBarButton = UIBarButtonItem(customView: moreButton)
        navigationItem.rightBarButtonItems = [switchBarButton, moreBarButton]

        let titleAppearance = UINavigationBarAppearance()
        titleAppearance.configureWithTransparentBackground()
        titleAppearance.shadowImage = nil
        titleAppearance.backgroundImage = nil

        navigationItem.standardAppearance = titleAppearance
        navigationItem.compactAppearance = titleAppearance
        navigationItem.scrollEdgeAppearance = titleAppearance
    }

    private func setupViewsAndConstraints() {
        view.backgroundColor = .mainSystemBackground

        backgroundNavigationView.addSubview(brightnessBar)

        view.addSubview(backgroundNavigationView)

        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: backgroundBrightnessHeight).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        backgroundNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundNavigationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundNavigationHeightLayout = backgroundNavigationView.heightAnchor.constraint(equalToConstant: topBarHeight + backgroundBrightnessHeight)
        backgroundNavigationHeightLayout.isActive = true

        brightnessBar.leadingAnchor.constraint(equalTo: backgroundNavigationView.layoutMarginsGuide.leadingAnchor, constant: 8).isActive = true
        brightnessBar.trailingAnchor.constraint(equalTo: backgroundNavigationView.layoutMarginsGuide.trailingAnchor, constant: -8).isActive = true
        brightnessBar.bottomAnchor.constraint(equalTo: backgroundNavigationView.layoutMarginsGuide.bottomAnchor, constant: -8).isActive = true
        brightnessBar.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
}

// MARK: - Rx Binding

extension DeviceViewController {
    private func bindViewController() {
        assert(viewModel != nil)

        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

//        let colorChanged = Driver.merge(colorWellPrimary.rx.controlEvent(.valueChanged).asDriver(),
//                                        colorWellSecondary.rx.controlEvent(.valueChanged).asDriver(),
//                                        colorWellTertiary.rx.controlEvent(.valueChanged).asDriver())
//            .debounce(.milliseconds(250))
//            .map { _ -> [[Int]] in
//                if let primary = self.colorWellPrimary.selectedColor,
//                   let secondary = self.colorWellSecondary.selectedColor,
//                   let tertiary = self.colorWellTertiary.selectedColor {
//                    return [primary.intArray, secondary.intArray, tertiary.intArray]
//                }
//                return []
//            }

        let input = DeviceViewModel.Input(effectTrigger: effectsButton.rx.tap.asDriver(),
                                          infoTrigger: infoButton.rx.tap.asDriver(),
                                          settingsTrigger: settingsButton.rx.tap.asDriver(),
                                          fetchState: viewWillAppear,
                                          updateColors: Driver.empty(),
                                          updateBrightness: brightnessBar.rx.value.asDriver()
                                            .debounce(.milliseconds(250))
                                            .map({ Int($0) }),
                                          updateOn: switchButton.rx.value.asDriver(),
                                          updatePalette: collectionView.rx.itemSelected.asDriver())

        let output = viewModel.transform(input: input)
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, PaletteItemViewModel>>(configureCell: { _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaletteCollectionViewCell.identifier, for: indexPath)
            if let cell = cell as? PaletteCollectionViewCell {
                cell.bind(item)
            }
            return cell
        }, configureSupplementaryView: { _, collectionView, string, indexPath in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader.self, withReuseIdentifier: "supplementary", for: indexPath)
            cell.addSubview(self.buttonStackView)
            cell.addSubview(self.colorPicker)
//            cell.addSubview(self.colorsStackView)
            cell.addSubview(self.paletteLabel)
            cell.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })

            self.buttonStackView.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor).isActive = true
            self.buttonStackView.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor).isActive = true
            self.buttonStackView.topAnchor.constraint(equalTo: cell.layoutMarginsGuide.topAnchor, constant: 8).isActive = true
            self.buttonStackView.heightAnchor.constraint(equalToConstant: DeviceViewController.buttonSize).isActive = true

            self.colorPicker.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor).isActive = true
            self.colorPicker.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor).isActive = true
            self.colorPicker.topAnchor.constraint(equalTo: self.buttonStackView.bottomAnchor, constant: 16).isActive = true

            self.paletteLabel.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor).isActive = true
            self.paletteLabel.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor).isActive = true
            self.paletteLabel.topAnchor.constraint(equalTo: self.colorPicker.bottomAnchor, constant: 8).isActive = true
            self.paletteLabel.bottomAnchor.constraint(equalTo: cell.layoutMarginsGuide.bottomAnchor, constant: 0).isActive = true

            return cell
        })

        output.palettes.compactMap({[SectionModel<String, PaletteItemViewModel>(model: "Palettes", items: $0)]})
            .drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)

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
//                vc.colorWellPrimary.selectedColor = firstColorUI

                let secondColor = segment.colors[1]
                let secondColorUI = UIColor(red: secondColor[0], green: secondColor[1], blue: secondColor[2])
//                vc.colorWellSecondary.selectedColor = secondColorUI

                let thirdColor = segment.colors[2]
                let thirdColorUI = UIColor(red: thirdColor[0], green: thirdColor[1], blue: thirdColor[2])
//                vc.colorWellTertiary.selectedColor = thirdColorUI

                if let paletteIndex = segment.palette, paletteIndex != -1 {
                    let indexPath = IndexPath(row: paletteIndex, section: 0)
                    vc.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                }
            } else {
//                vc.colorWellPrimary.selectedColor = UIColor.black
//                vc.colorWellSecondary.selectedColor = UIColor.black
//                vc.colorWellTertiary.selectedColor = UIColor.black
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

            vc.updateBackgroundGradient(colors: colors, textColor: deviceNameTextColor)
        })
    }
}

extension DeviceViewController {
    func updateBackgroundGradient(colors: [CGColor], textColor: UIColor) {
        if let gradientLayer = backgroundNavigationView.layer as? CAGradientLayer {
            gradientLayer.changeGradients(colors, animate: true)
        }

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.navigationItem.standardAppearance?.titleTextAttributes = [.foregroundColor: textColor]
            self?.navigationItem.scrollEdgeAppearance?.largeTitleTextAttributes = [.foregroundColor: textColor]
            self?.navigationItem.compactAppearance?.titleTextAttributes = [.foregroundColor: textColor]
            self?.navigationController?.navigationBar.tintColor = textColor
        }
    }
}

// MARK: Flow layout delegate

extension DeviceViewController: UICollectionViewDelegateFlowLayout {
}
