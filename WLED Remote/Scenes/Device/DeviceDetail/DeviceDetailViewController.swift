//
//  DeviceDetailViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/12/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DeviceDetailViewController: UIViewController {

    // MARK: - Rx

    private var disposeBag = DisposeBag()

    // MARK: - View Model

    let viewModel: DeviceDetailViewModel

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
        $0.layer.cornerRadius = DeviceDetailViewController.buttonSize / 2
    }

    let onSwitch = UISwitch().then {
        $0.onTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20)
        $0.tintColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
    }

    let brightnessSlider = BrightnessSlider().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    let segmentsLabel = UILabel().then {
        $0.text = "Segments"
        $0.font = UIFont.boldSystemFont(ofSize: 12)
    }

    let commonCompositionalLayout: UICollectionViewCompositionalLayout = {
        let fraction = 1.0 / 2.0
        let insets = 8.0
        let itemHeight = 100.0

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: insets, leading: insets, bottom: insets, trailing: insets)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(itemHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: insets, bottom: 0, trailing: insets)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(28))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)

        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(itemHeight))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize,
                                                                 elementKind: UICollectionView.elementKindSectionFooter,
                                                                 alignment: .bottom)

        footer.contentInsets = .init(top: insets, leading: insets, bottom: insets, trailing: insets)

        section.boundarySupplementaryItems = [header, footer]
        let configutationLayout = UICollectionViewCompositionalLayout(section: section)

        return configutationLayout
    }()

    lazy var segmentsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: commonCompositionalLayout).then {
        $0.register(SegmentCell.self, forCellWithReuseIdentifier: SegmentCell.identifier)
        $0.register(CollectionViewHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        $0.register(AddSegmentFooterCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        $0.alwaysBounceHorizontal = false
        $0.alwaysBounceVertical = true
        $0.dataSource = nil
        $0.delegate = self
        $0.isScrollEnabled = true
        $0.backgroundColor = .clear
        $0.allowsSelection = true
    }

    lazy var scenesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: commonCompositionalLayout).then {
        $0.register(CollectionViewHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        $0.alwaysBounceHorizontal = true
        $0.alwaysBounceVertical = false
        $0.dataSource = nil
        $0.delegate = self
        $0.isScrollEnabled = true
        $0.backgroundColor = .clear
        $0.allowsSelection = true
    }

    lazy var scenesStackView = UIStackView().then {
        $0.addArrangedSubview(scenesCollectionView)
        $0.axis = .vertical
        $0.spacing = 8
    }

    // MARK: - Properties

    static let buttonSize: CGFloat = 32
    private let backgroundBrightnessHeight: CGFloat = 42
    private let addSegmentFooterTapGesture = UITapGestureRecognizer()
    private let addSceneFooterTapGesture = UITapGestureRecognizer()
    private let deleteSegmentSubject = PublishSubject<IndexPath>()
    private let deleteSceneSubject = PublishSubject<IndexPath>()

    //MARK: - Constructors

    init(viewModel: DeviceDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle

extension DeviceDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViewsAndConstraints()
        bindViewModel()
    }
}

// MARK: - Setup

extension DeviceDetailViewController {
    private func setupNavigationBar() {
        let switchBarButton = UIBarButtonItem(customView: onSwitch)
        let moreBarButton = UIBarButtonItem(customView: moreButton).then {
            $0.customView?.translatesAutoresizingMaskIntoConstraints = false
            $0.customView?.heightAnchor.constraint(equalToConstant: onSwitch.frame.height).isActive = true
            $0.customView?.widthAnchor.constraint(equalToConstant: onSwitch.frame.height).isActive = true
        }

        navigationItem.rightBarButtonItems = [switchBarButton, moreBarButton]

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

        backgroundNavigationView.addSubview(brightnessSlider)

        view.do {
            $0.addSubview(backgroundNavigationView)
            $0.addSubview(segmentsCollectionView)
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

        segmentsCollectionView.do {
            $0.topAnchor.constraint(equalTo: backgroundNavigationView.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
    }
}

// MARK: - Rx Binding

extension DeviceDetailViewController {
    private func bindViewModel() {
        let input = DeviceDetailViewModel.Input(loadTrigger: Driver.just(()),
                                                moreTrigger: moreButton.rx.tap.asDriver(),
                                                on: onSwitch.rx.value.changed.asDriver(),
                                                brightness: brightnessSlider.rx.value.changed.asDriver(),
                                                addSegmentTrigger: addSegmentFooterTapGesture.rx.event.asDriver().mapToVoid(),
                                                selectedSegment: segmentsCollectionView.rx.itemSelected.asDriver(),
                                                deleteSegment: deleteSegmentSubject.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input: input, disposeBag: disposeBag)

        let segmentsDataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, SegmentItemViewModel>> {  _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SegmentCell.identifier, for: indexPath)
            if let cell = cell as? SegmentCell {
                cell.bind(item)
            }
            return cell
        } configureSupplementaryView: { data, collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
                if let cell = cell as? CollectionViewHeaderCell {
                    cell.bind(text: data.sectionModels[indexPath.row].model)
                }
                return cell
            case UICollectionView.elementKindSectionFooter:
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
                cell.removeGestureRecognizer(self.addSegmentFooterTapGesture)
                cell.addGestureRecognizer(self.addSegmentFooterTapGesture)
                    return cell
            default:
                return UICollectionReusableView()
            }
        }

        output.$deviceName
            .asDriver()
            .drive(rx.title)
            .disposed(by: disposeBag)

        output.$on
            .asDriverOnErrorJustComplete()
            .drive(onSwitch.rx.value)
            .disposed(by: disposeBag)

        output.$brightness
            .asDriverOnErrorJustComplete()
            .drive(brightnessSlider.rx.value)
            .disposed(by: disposeBag)

        output.$segments
            .asDriver()
            .compactMap { [AnimatableSectionModel<String, SegmentItemViewModel>(model: "Segments", items: $0)] }
            .drive(segmentsCollectionView.rx.items(dataSource: segmentsDataSource))
            .disposed(by: disposeBag)

        Driver.combineLatest(output.$segments.asDriver(), output.$on.asDriver())
            .map { State(on: $0.1, segments: $0.0.map({ $0.segment })) }
            .distinctUntilChanged()
            .drive(animationBinding)
            .disposed(by: disposeBag)
    }

    var animationBinding: Binder<State> {
        Binder(self) { vc, state in
            let backgroundGradient = ColorGradientAnimation.nextBackgroundGradient(from: state.segments, on: state.on ?? false)
            let deviceNameTextColor = ColorGradientAnimation.textColorForBackgroundGradient(from: state.segments, on: state.on ?? false)

            // Set colors to background navigation

            if let gradientLayer = vc.backgroundNavigationView.layer as? CAGradientLayer {
                gradientLayer.gradientChangeAnimation(backgroundGradient.map { $0.cgColor }, animate: true)
            }

            // Animate colors on changed

            UIView.animate(withDuration: 0.2) {
                vc.navigationItem.standardAppearance?.titleTextAttributes = [.foregroundColor: deviceNameTextColor]
                vc.navigationItem.scrollEdgeAppearance?.largeTitleTextAttributes = [.foregroundColor: deviceNameTextColor]
                vc.navigationItem.compactAppearance?.titleTextAttributes = [.foregroundColor: deviceNameTextColor]
                vc.navigationController?.navigationBar.tintColor = deviceNameTextColor
                vc.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
}

extension DeviceDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if collectionView == segmentsCollectionView && collectionView.numberOfItems(inSection: 0) > 1 {
            let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
                let delete = UIAction(title: "Delete",
                                      image: UIImage(systemName: "trash"),
                                      identifier: nil,
                                      discoverabilityTitle: nil,
                                      attributes: .destructive,
                                      state: .off) { [weak self] _ in
                    guard let `self` = self else { return }
                    let subject = collectionView == self.segmentsCollectionView ? self.deleteSegmentSubject : self.deleteSceneSubject
                    subject.onNext(indexPath)
                }
                return UIMenu(title: "Options",
                              image: nil,
                              identifier: nil,
                              options: .destructive,
                              children: [delete])
            }
            return context
        } else if collectionView == segmentsCollectionView {
            return UIContextMenuConfiguration()
        }
        return nil
    }
}
