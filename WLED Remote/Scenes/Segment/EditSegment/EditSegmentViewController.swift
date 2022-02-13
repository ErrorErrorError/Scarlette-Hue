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

class EditSegmentViewController: UIViewController {

    // MARK: - Rx

    private var disposeBag = DisposeBag()

    // MARK: View Model

    let viewModel: EditSegmentViewModel

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

    let moreButton = UIButton(type: .custom).then {
        let largeConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "ellipsis", withConfiguration: largeConfiguration)
        $0.setImage(image, for: .normal)
        $0.backgroundColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
        $0.layer.cornerRadius = EditSegmentViewController.buttonSize / 2
    }

    let onSwitch = UISwitch().then {
        $0.onTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20)
        $0.tintColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
    }

    let brightnessSlider = BrightnessSlider().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    let effectsButton = UIButton().then {
        $0.setImage(UIImage(systemName: "wand.and.stars.inverse"), for: .normal)
        $0.backgroundColor = .contentOverSystemBackground
        $0.layer.cornerRadius = EditSegmentViewController.buttonSize / 2
    }

    let infoButton = UIButton().then {
        let image = UIImage(systemName: "info.circle")
        $0.setImage(image, for: .normal)
        $0.backgroundColor = .contentOverSystemBackground
        $0.layer.cornerRadius = EditSegmentViewController.buttonSize / 2
    }

    let colorPicker = ChromaColorPicker().then {
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    let colorPickerBrightness = ChromaBrightnessSlider().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
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

    lazy var palettesCollectionView = UICollectionView(frame: .zero,
                                                       collectionViewLayout: createCommonCompositionalLayout()).then {
        $0.register(PaletteCell.self, forCellWithReuseIdentifier: PaletteCell.identifier)
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

    lazy var effectsCollectionView = UICollectionView(frame: .zero,
                                                      collectionViewLayout: createCommonCompositionalLayout()).then {
        $0.register(EffectCell.self, forCellWithReuseIdentifier: EffectCell.identifier)
        $0.register(CollectionViewHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        $0.alwaysBounceHorizontal = true
        $0.alwaysBounceVertical = false
        $0.dataSource = nil
        $0.isScrollEnabled = true
        $0.backgroundColor = .clear
        $0.allowsSelection = true
    }

    lazy var effectsStackView = UIStackView().then {
        $0.addArrangedSubview(effectsCollectionView)
        $0.axis = .vertical
        $0.spacing = 8
    }

    // MARK: - Properties

    static let buttonSize: CGFloat = 32
    private let backgroundBrightnessHeight: CGFloat = 42

    init(viewModel: EditSegmentViewModel) {
        self.viewModel = viewModel
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
        bindViewController()
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

        let moreBarButton = UIBarButtonItem(customView: moreButton).then {
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
            $0.addSubview(colorPicker)
            $0.addSubview(palettesStackView)
            $0.addSubview(effectsStackView)
            $0.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
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

        colorPicker.do {
            $0.topAnchor.constraint(equalTo: backgroundNavigationView.bottomAnchor, constant: 8 + colorPicker.handleSize.height).isActive = true
            $0.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor).isActive = true
            $0.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        }
 
        palettesStackView.do {
            $0.topAnchor.constraint(equalTo: colorPicker.bottomAnchor, constant: 8).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }

        effectsStackView.do {
            $0.topAnchor.constraint(equalTo: palettesStackView.bottomAnchor, constant: 8).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
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

extension EditSegmentViewController {
    private func bindViewController() {
        let colorsChanged = colorPicker.rx.handleDidChange
            .asDriver()
            .map {
                (first: self.colorHandlerPrimary.color.intArray,
                 second: self.colorHandlerSecondary.color.intArray,
                 third: self.colorHandlerTertiary.color.intArray)
            }

        let input = EditSegmentViewModel.Input(loadTrigger: Driver.just(()),
                                               exitTrigger: exitButton.rx.tap.asDriver(),
                                               settingsTrigger: moreButton.rx.tap.asDriver(),
                                               on: onSwitch.rx.value.changed.asDriver(),
                                               brightness: brightnessSlider.rx.value.changed.asDriver(),
                                               colors: colorsChanged,
                                               selectedPalette: palettesCollectionView.rx.itemSelected.asDriver(),
                                               selectedEffect: palettesCollectionView.rx.itemSelected.asDriver()
        )

        let output = viewModel.transform(input: input, disposeBag: disposeBag)

        let paletteDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, PaletteItemViewModel>>.init {  _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaletteCell.identifier, for: indexPath)
            if let cell = cell as? PaletteCell {
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

        let effectsDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, EffectItemViewModel>>.init {  _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EffectCell.identifier, for: indexPath)
            if let cell = cell as? EffectCell {
                cell.bind(item)
            }
            return cell
        } configureSupplementaryView: { data, collectionView, kind, indexPath in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            if let cell = cell as? CollectionViewHeaderCell {
                cell.bind(text: data.sectionModels[indexPath.row].model)
            }
            return cell
        }

        output.$palettes
            .asDriver()
            .map { [SectionModel<String, PaletteItemViewModel>(model: "Palettes", items: $0)] }
            .drive(palettesCollectionView.rx.items(dataSource: paletteDataSource))
            .disposed(by: disposeBag)

        output.$effects
            .asDriver()
            .map { [SectionModel<String, EffectItemViewModel>(model: "Effects", items: $0)] }
            .drive(effectsCollectionView.rx.items(dataSource: effectsDataSource))
            .disposed(by: disposeBag)

        output.$name
            .asDriver()
            .drive(rx.title)
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
            .drive(onNext: { [weak self] selected in
                self?.palettesCollectionView.selectItem(at: selected, animated: true, scrollPosition: .centeredHorizontally)
            })
            .disposed(by: disposeBag)

        output.$selectedEffect
            .asDriverOnErrorJustComplete()
            .drive(onNext: { [weak self] selected in
                self?.effectsCollectionView.selectItem(at: selected, animated: true, scrollPosition: .centeredHorizontally)
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
                // Set background color
                let primary = state.first
//                let secondary = state.second
//                let tertiary = state.third

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

            UIView.animate(withDuration: 0.2) {
                vc.setNeedsStatusBarAppearanceUpdate()
                vc.navigationItem.standardAppearance?.titleTextAttributes = [.foregroundColor: textColor]
                vc.navigationItem.scrollEdgeAppearance?.largeTitleTextAttributes = [.foregroundColor: textColor]
                vc.navigationItem.compactAppearance?.titleTextAttributes = [.foregroundColor: textColor]
                vc.navigationController?.navigationBar.tintColor = textColor
                vc.moreButton.tintColor = textColor
                vc.exitButton.tintColor = textColor
            }
        }
    }
}

extension EditSegmentViewController {
    func createCommonCompositionalLayout() -> UICollectionViewCompositionalLayout {
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
