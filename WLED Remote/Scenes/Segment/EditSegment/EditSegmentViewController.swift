//
//  EditSegmentViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/12/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Then

class EditSegmentViewController: UIViewController, Bindable {

    private enum CollectionViewStates {
        case colorPicker
        case palettes
        case effects
        case effectSettings
    }

    // MARK: - Rx

    private var disposeBag = DisposeBag()

    // MARK: View Model

    var viewModel: EditSegmentViewModel!

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

    let exitButton = UIButton(type: .custom).then {
        let configuration = UIImage.SymbolConfiguration.init(pointSize: 13, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: configuration)
        $0.setImage(image, for: .normal)
        $0.backgroundColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
        $0.layer.cornerRadius = EditSegmentViewController.buttonSize / 2
    }

    let segmentSettingsButton = UIButton(type: .custom).then {
        let largeConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "ellipsis", withConfiguration: largeConfiguration)
        $0.setImage(image, for: .normal)
        $0.backgroundColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
        $0.layer.cornerRadius = EditSegmentViewController.buttonSize / 2
    }

    let effectSettingsButton = UIButton(type: .custom).then {
        let largeConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        let image = UIImage(systemName: "gearshape", withConfiguration: largeConfiguration)
        $0.setImage(image, for: .normal)
        $0.backgroundColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
        $0.layer.cornerRadius = EditSegmentViewController.buttonSize / 2
        $0.tintColor = .label
    }

    let onSwitch = UISwitch().then {
        $0.onTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20)
        $0.tintColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
    }

    let brightnessSlider = BrightnessSlider().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Color Picker

    let colorPicker = ChromaColorPicker().then {
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    // MARK: Brightness

    let colorPickerBrightness = ChromaBrightnessSlider().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    // MARK: Color Selectors

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

    lazy var containerCollectionView = UICollectionView(frame: .zero,
                                                        collectionViewLayout: generateCollectionViewLayout()).then {
        $0.register(CommonCell.self, forCellWithReuseIdentifier: CommonCell.identifier)
        $0.register(UICollectionViewCell.self, forSupplementaryViewOfKind: "color-picker-header", withReuseIdentifier: "header")
        $0.register(CollectionViewHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        $0.alwaysBounceHorizontal = false
        $0.alwaysBounceVertical = false
        $0.dataSource = nil
        $0.isScrollEnabled = true
        $0.backgroundColor = .clear
        $0.allowsSelection = true
        $0.allowsMultipleSelection = true
    }

    // MARK: - Properties

    static let buttonSize: CGFloat = 32

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle

extension EditSegmentViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViewsAndConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for index in containerCollectionView.indexPathsForSelectedItems ?? [] {
            containerCollectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        }
    }
}

// MARK: - Setup

extension EditSegmentViewController {
    private func setupNavigationBar() {
        let exitBarButton = UIBarButtonItem(customView: exitButton).then {
            $0.customView?.translatesAutoresizingMaskIntoConstraints = false
            $0.customView?.heightAnchor.constraint(equalToConstant: onSwitch.frame.height).isActive = true
            $0.customView?.widthAnchor.constraint(equalToConstant: onSwitch.frame.height).isActive = true
        }

        let moreBarButton = UIBarButtonItem(customView: segmentSettingsButton).then {
            $0.customView?.translatesAutoresizingMaskIntoConstraints = false
            $0.customView?.heightAnchor.constraint(equalToConstant: onSwitch.frame.height).isActive = true
            $0.customView?.widthAnchor.constraint(equalToConstant: onSwitch.frame.height).isActive = true
        }
        let switchBarButton = UIBarButtonItem(customView: onSwitch)

        navigationItem.rightBarButtonItems = [switchBarButton, moreBarButton]
        navigationItem.leftBarButtonItem = exitBarButton

        let titleAppearance = UINavigationBarAppearance().then {
            $0.configureWithTransparentBackground()
            $0.shadowImage = nil
            $0.backgroundImage = nil
        }

        navigationItem.do {
            $0.largeTitleDisplayMode = .never
            $0.standardAppearance = titleAppearance
            $0.compactAppearance = titleAppearance
            $0.scrollEdgeAppearance = titleAppearance
        }
    }

    private func setupViewsAndConstraints() {
        view.backgroundColor = .mainSystemBackground
        colorPicker.delegate = self

        colorPicker.do {
            $0.addHandle(colorHandlerPrimary)
            $0.addHandle(colorHandlerSecondary)
            $0.addHandle(colorHandlerTertiary)
            $0.connect(colorPickerBrightness)
        }

        view.do {
            $0.addSubview(backgroundNavigationView)
            $0.addSubview(brightnessSlider)
            $0.addSubview(containerCollectionView)
            $0.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        }

        backgroundNavigationView.do {
            $0.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: brightnessSlider.bottomAnchor, constant: 8).isActive = true
        }

        brightnessSlider.do {
            $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        }

        containerCollectionView.do {
            $0.topAnchor.constraint(equalTo: backgroundNavigationView.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }
}

// MARK: - Rx Binding

extension EditSegmentViewController: ChromaColorPickerDelegate {
    func colorPickerHandleDidChange(_ colorPicker: ChromaColorPicker, handle: ChromaColorHandle, to color: UIColor) {
        // Just fix the text color so that it doesnt blend in with the color
        if let label = handle.accessoryView as? UILabel {
            label.textColor = color.isLight ? .black : .white
        }
    }
}

// MARK: - View Model

extension EditSegmentViewController {
    func bindViewModel() {
        let colorsChanged = colorPicker.rx.handleDidChange
            .asDriver()
            .map {
                (first: self.colorHandlerPrimary.color.intArray,
                 second: self.colorHandlerSecondary.color.intArray,
                 third: self.colorHandlerTertiary.color.intArray)
            }

        let input = EditSegmentViewModel.Input(
            loadTrigger: Driver.just(()),
            exitTrigger: exitButton.rx.tap.asDriver(),
            segmentSettingsTrigger: segmentSettingsButton.rx.tap.asDriver(),
            effectSettingsTrigger: effectSettingsButton.rx.tap.asDriver(),
            on: onSwitch.rx.value.changed.asDriver(),
            brightness: brightnessSlider.rx.value.changed.asDriver(),
            colors: colorsChanged,
            selectedPalette: containerCollectionView.rx.itemSelected.asDriver(),
            selectedEffect: containerCollectionView.rx.itemSelected.asDriver()
        )

        let output = viewModel.transform(input, disposeBag: disposeBag)

        let commonDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<AnyHashable, String>> { _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommonCell.identifier, for: indexPath)

            if let cell = cell as? CommonCell {
                cell.bind(item)
            }

            return cell
        } configureSupplementaryView: { [unowned self] data, collectionView, kind, indexPath in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            if let cell = cell as? CollectionViewHeaderCell {
                if let palettes = data.sectionModels[indexPath.section].model as? EditSegmentViewModel.PalettesSection {
                    cell.bind(text: palettes.sectionTitle)
                } else if let effects = data.sectionModels[indexPath.section].model as? EditSegmentViewModel.EffectsSection {
                    cell.bind(text: effects.sectionTitle, accessory: effectSettingsButton)
                }
            } else if let cell = cell as? UICollectionViewCell, indexPath.section == 0 {
                cell.do {
                    $0.addSubview(colorPicker)
                    $0.addSubview(colorPickerBrightness)
                    $0.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
                }

                colorPicker.do {
                    $0.topAnchor.constraint(equalTo: cell.topAnchor, constant: colorPicker.handleSize.height / 2).isActive = true
                    $0.widthAnchor.constraint(equalTo: cell.widthAnchor, constant: -colorPicker.handleSize.height).isActive = true
                    $0.heightAnchor.constraint(equalTo: $0.widthAnchor).isActive = true
                    $0.centerXAnchor.constraint(equalTo: cell.layoutMarginsGuide.centerXAnchor).isActive = true
                }

                colorPickerBrightness.do {
                    $0.topAnchor.constraint(equalTo: colorPicker.bottomAnchor, constant: 8).isActive = true
                    $0.widthAnchor.constraint(equalTo: colorPicker.widthAnchor).isActive = true
                    $0.centerXAnchor.constraint(equalTo: colorPicker.centerXAnchor).isActive = true
                }

            } else {
                cell.isHidden = true
            }
            return cell
        }

        let palettesData = output.$palettes.asDriver()
        let effectsData = output.$effects.asDriver()

        Driver.combineLatest(palettesData, effectsData)
            .map { (palettes, effects) -> [SectionModel<AnyHashable, String>] in
                var sections: [SectionModel<AnyHashable, String>] = []
                sections.append(.init(model: palettes, items: palettes.items))
                sections.append(.init(model: effects, items: effects.items))
                return sections
            }
            .drive(containerCollectionView.rx.items(dataSource: commonDataSource))
            .disposed(by: disposeBag)

        output.$name
            .asDriver()
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)

        output.$on
            .take(1)
            .asDriverOnErrorJustComplete()
            .drive(onSwitch.rx.value)
            .disposed(by: disposeBag)

        output.$brightness
            .take(1)
            .asDriverOnErrorJustComplete()
            .drive(brightnessSlider.rx.value)
            .disposed(by: disposeBag)

        output.$colors
            .take(1)
            .asDriverOnErrorJustComplete()
            .drive(colorsBinding)
            .disposed(by: disposeBag)

        output.$selectedPalette
            .asDriverOnErrorJustComplete()
            .filter({ $0.section == 0 })
            .drive(onNext: { [containerCollectionView] selected in
                if let indexPaths = containerCollectionView.indexPathsForSelectedItems?.filter({ $0.section == 0 }) {
                    indexPaths.forEach {
                        self.containerCollectionView.deselectItem(at: $0, animated: false)
                    }
                }
                self.containerCollectionView.selectItem(at: selected, animated: true, scrollPosition: .centeredHorizontally)
            })
            .disposed(by: disposeBag)

        containerCollectionView.rx.itemDeselected
            .asDriver()
            .filter({ $0.section == 0 })
            .filter({ [unowned self] _ in (self.containerCollectionView.indexPathsForSelectedItems?.filter({ $0.section == 0 }) ?? []).count == 0 })
            .drive(onNext: { [unowned self] reselect in
                self.containerCollectionView.selectItem(at: reselect, animated: true, scrollPosition: .centeredHorizontally)
            })
            .disposed(by: disposeBag)

        output.$selectedEffect
            .asDriverOnErrorJustComplete()
            .filter({ $0.section == 1 })
            .drive(onNext: { [unowned self] selected in
                if let indexPaths = containerCollectionView.indexPathsForSelectedItems?.filter({ $0.section == 1 }) {
                    indexPaths.forEach {
                        self.containerCollectionView.deselectItem(at: $0, animated: false)
                    }
                }
                self.containerCollectionView.selectItem(at: selected, animated: true, scrollPosition: .centeredHorizontally)
            })
            .disposed(by: disposeBag)

        containerCollectionView.rx.itemDeselected
            .asDriver()
            .filter({ $0.section == 1 })
            .filter({ [unowned self] _ in (self.containerCollectionView.indexPathsForSelectedItems?.filter({ $0.section == 1 }) ?? []).count == 0 })
            .drive(onNext: { [unowned self] reselect in
                self.containerCollectionView.selectItem(at: reselect, animated: true, scrollPosition: .centeredHorizontally)
            })
            .disposed(by: disposeBag)

        Driver.combineLatest(output.$colors.asDriver(), output.$on.asDriver())
            .map { (colors, on) in
                (first: colors.first, second: colors.second, third: colors.third, on: on)
            }
            .drive(animationBinding)
            .disposed(by: disposeBag)
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
            var textColor = UIColor.label

            if state.on {
                let primary = state.first

                var newColors = [primary]
                    .filter({ $0.reduce(0, +) != 0 })
                    .map({ UIColor(red: $0[0], green: $0[1], blue: $0[2]).cgColor })

                if newColors.count == 1 {
                    newColors.append(newColors[0])
                }

                colors = newColors

                if let first = newColors.first {
                    let color = UIColor(cgColor: first)
                    textColor = color.isLight ? .black : .white
                }
            }

            // Set colors to background navigation

            if let gradientLayer = vc.backgroundNavigationView.layer as? CAGradientLayer {
                gradientLayer.gradientChangeAnimation(colors, animate: true)
            }

            // Animate colors on changed

            let dictAppearance = [NSAttributedString.Key.foregroundColor: textColor]

            UIView.animate(withDuration: 0.2) {
                vc.navigationItem.standardAppearance?.titleTextAttributes = dictAppearance
                vc.navigationItem.scrollEdgeAppearance?.titleTextAttributes = dictAppearance
                vc.navigationItem.compactAppearance?.titleTextAttributes = dictAppearance
                if #available(iOS 15.0, *) {
                    vc.navigationItem.compactScrollEdgeAppearance?.titleTextAttributes = dictAppearance
                }
                vc.navigationController?.navigationBar.tintColor = textColor
                vc.segmentSettingsButton.tintColor = textColor
                vc.exitButton.tintColor = textColor
                vc.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
}

extension EditSegmentViewController {
    func generateCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { index, environment in
            let fraction: CGFloat = 1 / 2
            let insets = 4.0

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: insets, leading: insets, bottom: insets, trailing: insets)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(94))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: insets, leading: insets, bottom: insets, trailing: insets)
            section.orthogonalScrollingBehavior = .continuous

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(28))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)

            if index == 0 {
                let colorPickerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1.10))
                let colorPickerHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: colorPickerSize, elementKind: "color-picker-header", alignment: .top)

                section.boundarySupplementaryItems = [colorPickerHeader, header]
            } else {
                section.boundarySupplementaryItems = [header]
            }

            return section
        }
        return layout
    }
}

extension EditSegmentViewController {
    internal func updateHandlerColor(_ handle: ChromaColorHandle, to color: UIColor) {
        colorPicker.setColor(handle, with: color)

        if let label = handle.accessoryView as? UILabel {
            label.textColor = color.isLight ? .black : .white
        }
    }
}
