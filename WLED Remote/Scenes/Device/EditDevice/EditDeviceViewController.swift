//
//  EditDeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/12/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class EditDeviceViewController: UIViewController {

    // MARK: - Rx

    private var disposeBag = DisposeBag()

    // MARK: View Model

    let viewModel: EditDeviceViewModel

    // MARK: - Views

    let backgroundNavigationView = GradientView().then {
        $0.layer.shadowRadius = 8.0
        $0.layer.shadowOpacity = 0.10
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 5)
        $0.layer.cornerCurve = .continuous
        $0.backgroundColor = .contentOverSystemBackground
        $0.layer.cornerRadius = 14
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    let moreButton = UIButton(type: .custom).then {
        let smallConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "ellipsis", withConfiguration: smallConfiguration)
        $0.setImage(image, for: .normal)
        $0.backgroundColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
        $0.layer.cornerRadius = EditDeviceViewController.buttonSize / 2
    }

    let switchButton = UISwitch().then {
        $0.onTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20)
        $0.tintColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
    }

    let brightnessBar = BrightnessSlider().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    let settingsButton = UIButton().then {
        $0.setImage(UIImage(systemName: "gearshape"), for: .normal)
        $0.backgroundColor = .contentOverSystemBackground
        $0.layer.cornerRadius = EditDeviceViewController.buttonSize / 2
    }

    let effectsButton = UIButton().then {
        $0.setImage(UIImage(systemName: "wand.and.stars.inverse"), for: .normal)
        $0.backgroundColor = .contentOverSystemBackground
        $0.layer.cornerRadius = EditDeviceViewController.buttonSize / 2
    }

    let infoButton = UIButton().then {
        let image = UIImage(systemName: "info.circle")
        $0.setImage(image, for: .normal)
        $0.backgroundColor = .contentOverSystemBackground
        $0.layer.cornerRadius = EditDeviceViewController.buttonSize / 2
    }

    lazy var actionButtonStackView = UIStackView().then {
        $0.addArrangedSubview(UIView())
        $0.addArrangedSubview(effectsButton)
        $0.addArrangedSubview(infoButton)
        $0.addArrangedSubview(settingsButton)
        $0.axis = .horizontal
        $0.alignment = .trailing
        $0.spacing = 16
    }

    let colorPicker = ChromaColorPicker().then {
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    let colorPickerBrightness = ChromaBrightnessSlider().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    lazy var colorPickerStackView = UIStackView().then {
        $0.addArrangedSubview(colorPicker)
        $0.addArrangedSubview(colorPickerBrightness)
        $0.axis = .vertical
        $0.spacing = 16
        $0.distribution = .fill
    }

    let colorHandlerPrimary = ChromaColorHandle().then {
        let textField = UILabel(frame: .zero)
        textField.textAlignment = .center
        textField.text = "1"
        textField.tintColor = .white
        textField.font = .boldSystemFont(ofSize: 16)
        $0.accessoryView = textField
    }

    let colorHandlerSecondary = ChromaColorHandle().then {
        let textField = UILabel(frame: .zero)
        textField.textAlignment = .center
        textField.text = "2"
        textField.tintColor = .white
        textField.font = .boldSystemFont(ofSize: 16)
        $0.accessoryView = textField
    }

    let colorHandlerTertiary = ChromaColorHandle().then {
        let textField = UILabel(frame: .zero)
        textField.textAlignment = .center
        textField.text = "3"
        textField.tintColor = .white
        textField.font = .boldSystemFont(ofSize: 16)
        $0.accessoryView = textField
    }

    let paletteLabel = UILabel().then {
        $0.text = "Palette"
        $0.font = UIFont.boldSystemFont(ofSize: 12)
    }

    let presetsCompositionalLayout: UICollectionViewCompositionalLayout = {
        let fraction: CGFloat = 1 / 2
        let insets = 4.0

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: insets, leading: insets, bottom: insets, trailing: insets)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(fraction / 2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: insets, leading: insets, bottom: insets, trailing: insets)
        section.orthogonalScrollingBehavior = .continuous

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(fraction / 3))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)

        section.boundarySupplementaryItems = [header]
        let configutationLayout = UICollectionViewCompositionalLayout(section: section)

        return configutationLayout
    }()

    lazy var palettesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: presetsCompositionalLayout).then {
        $0.register(PaletteCollectionViewCell.self, forCellWithReuseIdentifier: PaletteCollectionViewCell.identifier)
        $0.register(CollectionViewHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        $0.alwaysBounceHorizontal = true
        $0.alwaysBounceVertical = false
        $0.dataSource = nil
        $0.isScrollEnabled = true
        $0.backgroundColor = .clear
        $0.allowsSelection = true
    }

    lazy var palettesStackView = UIStackView().then {
        $0.addArrangedSubview(palettesCollectionView)
        $0.axis = .vertical
        $0.spacing = 8
    }

    // MARK: - Properties

    static let buttonSize: CGFloat = 32
    private let backgroundBrightnessHeight: CGFloat = 42

    init(viewModel: EditDeviceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle

extension EditDeviceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViewsAndConstraints()
        bindViewController()
    }
}

// MARK: - Setup

extension EditDeviceViewController {
    private func setupNavigationBar() {
        let switchBarButton = UIBarButtonItem(customView: switchButton)
        let moreBarButton = UIBarButtonItem(customView: moreButton).then {
            $0.customView?.translatesAutoresizingMaskIntoConstraints = false
            $0.customView?.heightAnchor.constraint(equalToConstant: switchButton.frame.height).isActive = true
            $0.customView?.widthAnchor.constraint(equalToConstant: switchButton.frame.height).isActive = true
        }

        navigationItem.rightBarButtonItems = [switchBarButton, moreBarButton]

        let titleAppearance = UINavigationBarAppearance().then {
            $0.configureWithTransparentBackground()
            $0.shadowImage = nil
            $0.backgroundImage = nil
        }

        navigationItem.do {
            $0.standardAppearance = titleAppearance
            $0.compactAppearance = titleAppearance
            $0.scrollEdgeAppearance = titleAppearance
        }
    }

    private func setupViewsAndConstraints() {
        view.backgroundColor = .mainSystemBackground
        colorPicker.delegate = self

        backgroundNavigationView.addSubview(brightnessBar)

        colorPicker.do {
            $0.addHandle(colorHandlerPrimary)
            $0.addHandle(colorHandlerSecondary)
            $0.addHandle(colorHandlerTertiary)
            $0.connect(colorPickerBrightness)
        }

        view.do {
            $0.addSubview(backgroundNavigationView)
            $0.addSubview(actionButtonStackView)
            $0.addSubview(colorPickerStackView)
            $0.addSubview(palettesStackView)
            $0.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        }

        backgroundNavigationView.do {
            $0.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: backgroundBrightnessHeight).isActive = true
        }

        brightnessBar.do {
            $0.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: backgroundNavigationView.bottomAnchor, constant: -12).isActive = true
        }

        actionButtonStackView.do {
            $0.topAnchor.constraint(equalTo: backgroundNavigationView.bottomAnchor, constant: 8).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: EditDeviceViewController.buttonSize).isActive = true
        }

        colorPickerStackView.do {
            $0.topAnchor.constraint(equalTo: actionButtonStackView.bottomAnchor, constant: 8).isActive = true
            $0.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor).isActive = true
            $0.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        }

        palettesStackView.do {
            $0.topAnchor.constraint(equalTo: colorPickerStackView.bottomAnchor, constant: 8).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
    }
}

// MARK: - Rx Binding

extension EditDeviceViewController: ChromaColorPickerDelegate {
    func colorPickerHandleDidChange(_ colorPicker: ChromaColorPicker, handle: ChromaColorHandle, to color: UIColor) {
        // Just fix the text color so that it doesnt blend in with the color
        if let label = handle.accessoryView as? UILabel {
            label.textColor = color.isLight ? .black : .white
        }
    }
}

extension EditDeviceViewController {
    private func bindViewController() {
        let colorsChanged = colorPicker.rx.handleDidChange
            .asDriver()
            .map({
                (first: self.colorHandlerPrimary.color.intArray,
                 second: self.colorHandlerSecondary.color.intArray,
                 third: self.colorHandlerTertiary.color.intArray)
            })

        let input = EditDeviceViewModel.Input(loadTrigger: Driver.just(()),
                                          effectTrigger: effectsButton.rx.tap.asDriver(),
                                          infoTrigger: infoButton.rx.tap.asDriver(),
                                          settingsTrigger: settingsButton.rx.tap.asDriver(),
                                          colors: colorsChanged,
                                          brightness: brightnessBar.rx.value.changed.asDriver(),
                                          on: switchButton.rx.value.changed.asDriver(),
                                          selectedPalette: palettesCollectionView.rx.itemSelected.asDriver())

        let output = viewModel.transform(input: input, disposeBag: disposeBag)

        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, PaletteItemViewModel>>.init {  _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaletteCollectionViewCell.identifier, for: indexPath)
            if let cell = cell as? PaletteCollectionViewCell {
                cell.bind(item)
            }
            return cell
        } configureSupplementaryView: { uhh, collectionView, kind, indexPath in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            if let cell = cell as? CollectionViewHeaderCell {
                cell.bind(text: uhh.sectionModels[indexPath.row].model)
            }
            return cell
        }

        output.$deviceName
            .asDriver()
            .drive(rx.title)
            .disposed(by: disposeBag)

        output.$palettes
            .asDriver()
            .map({ $0.map({ PaletteItemViewModel(title: $0) }) })
            .compactMap({[SectionModel<String, PaletteItemViewModel>(model: "Palettes", items: $0)]})
            .drive(palettesCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        output.$selectedPalette
            .take(1)
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] selected in
                self?.palettesCollectionView.selectItem(at: selected, animated: true, scrollPosition: .centeredHorizontally)
            })
            .disposed(by: disposeBag)

        output.$on
            .take(1)
            .asDriverOnErrorJustComplete()
            .drive(switchButton.rx.value)
            .disposed(by: disposeBag)

        output.$brightness
            .take(1)
            .asDriverOnErrorJustComplete()
            .drive(brightnessBar.rx.value)
            .disposed(by: disposeBag)

        output.$colors
            .take(1)
            .asDriverOnErrorJustComplete()
            .drive(colorsBinding)
            .disposed(by: disposeBag)

        Driver.combineLatest(output.$colors.asDriver(), output.$on.asDriver())
            .map { (colors, on) in
                (first: colors.first, second: colors.second, third: colors.third, on: on)
            }
            .drive(animationBinding)
            .disposed(by: disposeBag)

//        output.$store
//            .map({ $0.state })
//            .asDriverOnErrorJustComplete()
//            .drive(stateBinding)
//            .disposed(by: disposeBag)
    }

    var colorsBinding: Binder<(first: [Int], second: [Int], third: [Int])> {
        Binder(self) { vc, colors in
            let firstColorUI = UIColor(red: colors.first[0], green: colors.first[1], blue: colors.first[2])
            vc.updateHandlerColor(vc.colorHandlerPrimary, to: firstColorUI)

            let secondColorUI = UIColor(red: colors.second[0], green: colors.second[1], blue: colors.second[2])
            vc.updateHandlerColor(vc.colorHandlerSecondary, to: secondColorUI)

            let thirdColorUI = UIColor(red: colors.third[0], green: colors.third[1], blue: colors.third[2])
            vc.updateHandlerColor(vc.colorHandlerTertiary, to: thirdColorUI)
        }
    }

    var animationBinding: Binder<(first: [Int], second: [Int], third: [Int], on: Bool)> {
        Binder(self) { vc, state in
            var colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
            var deviceNameTextColor = UIColor.label

            if state.on {
                // Set background color
                let primary = state.first
                let secondary = state.second
                let tertiary = state.third

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

            // Set colors to background navigation

            if let gradientLayer = vc.backgroundNavigationView.layer as? CAGradientLayer {
                gradientLayer.changeGradients(colors, animate: true)
            }

            // Animate colors on changed

            UIView.animate(withDuration: 0.2) {
                vc.setNeedsStatusBarAppearanceUpdate()

                vc.navigationItem.standardAppearance?.titleTextAttributes = [.foregroundColor: deviceNameTextColor]
                vc.navigationItem.scrollEdgeAppearance?.largeTitleTextAttributes = [.foregroundColor: deviceNameTextColor]
                vc.navigationItem.compactAppearance?.titleTextAttributes = [.foregroundColor: deviceNameTextColor]
                vc.navigationController?.navigationBar.tintColor = deviceNameTextColor
            }
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
                
                vc.updateHandlerColor(vc.colorHandlerPrimary, to: firstColorUI)

                let secondColor = segment.colors[1]
                let secondColorUI = UIColor(red: secondColor[0], green: secondColor[1], blue: secondColor[2])

                vc.updateHandlerColor(vc.colorHandlerSecondary, to: secondColorUI)

                let thirdColor = segment.colors[2]
                let thirdColorUI = UIColor(red: thirdColor[0], green: thirdColor[1], blue: thirdColor[2])

                vc.updateHandlerColor(vc.colorHandlerTertiary, to: thirdColorUI)

                if let paletteIndex = segment.palette, paletteIndex != -1 {
                    let indexPath = IndexPath(row: paletteIndex, section: 0)
                    vc.palettesCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                }
            } else {
                vc.updateHandlerColor(vc.colorHandlerPrimary, to: .black)
                vc.updateHandlerColor(vc.colorHandlerSecondary, to: .black)
                vc.updateHandlerColor(vc.colorHandlerTertiary, to: .black)
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

            // Set colors to background navigation

            if let gradientLayer = vc.backgroundNavigationView.layer as? CAGradientLayer {
                gradientLayer.changeGradients(colors, animate: true)
            }

            // Animate colors on changed

            UIView.animate(withDuration: 0.2) {
                vc.setNeedsStatusBarAppearanceUpdate()

                vc.navigationItem.standardAppearance?.titleTextAttributes = [.foregroundColor: deviceNameTextColor]
                vc.navigationItem.scrollEdgeAppearance?.largeTitleTextAttributes = [.foregroundColor: deviceNameTextColor]
                vc.navigationItem.compactAppearance?.titleTextAttributes = [.foregroundColor: deviceNameTextColor]
                vc.navigationController?.navigationBar.tintColor = deviceNameTextColor
            }
        })
    }
}

extension EditDeviceViewController {
    internal func updateHandlerColor(_ handle: ChromaColorHandle, to color: UIColor) {
        colorPicker.positionHandle(handle, with: color)

        if let label = handle.accessoryView as? UILabel {
            label.textColor = color.isLight ? .black : .white
        }
    }
}
