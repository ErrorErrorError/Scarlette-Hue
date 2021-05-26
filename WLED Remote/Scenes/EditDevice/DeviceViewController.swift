//
//  DeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/12/21.
//

import UIKit
import RxSwift
import RxCocoa

class DeviceViewController: UIViewController {
    static let buttonSize: CGFloat = 32

    // MARK: Rx

    private let disposeBag = DisposeBag()

    // MARK: View Model

    var viewModel: DeviceViewModel!

    // MARK: Views

    let switchButton = UISwitch(frame: .zero)

    let scrollView: UIScrollView = {
        let scroll = UIScrollView(frame: .zero)
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()

    lazy var brightnessBar: BrightnessSlider = {
        let bar = BrightnessSlider(frame: .zero)
        bar.layer.cornerRadius = 28 / 2
        bar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bar.clipsToBounds = true
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

    var oldNavColor: UIColor! = nil

    var oldShadowLine: UIImage! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewsAndConstraints()
        bindViewController()
    }

    private func bindViewController() {
        assert(viewModel != nil)

        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let colorChanged = Driver.merge(colorWellPrimary.rx.controlEvent(.valueChanged).asDriver()
                                            .debounce(.milliseconds(250)),
                                        colorWellSecondary.rx.controlEvent(.valueChanged).asDriver()
                                            .debounce(.milliseconds(250)),
                                        colorWellTertiary.rx.controlEvent(.valueChanged).asDriver()
                                            .debounce(.milliseconds(250)))
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
                                          updateOn: switchButton.rx.value.asDriver()
        )

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
            }

            if vc.switchButton.isOn {
                // Set background color
            } else {
            }
        })
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

//private extension UIButton {
//    func animateWhenPressed(disposeBag: DisposeBag) {
//        let pressDownTransform = rx.controlEvent([.touchDown, .touchDragEnter])
//            .map({ CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95) })
//
//        let pressUpTransform = rx.controlEvent([.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
//            .map({ CGAffineTransform.identity })
//
//        Observable.merge(pressDownTransform, pressUpTransform)
//            .distinctUntilChanged()
//            .subscribe(onNext: animate(_:))
//            .disposed(by: disposeBag)
//    }
//
//    private func animate(_ transform: CGAffineTransform) {
//        UIView.animate(withDuration: 0.4,
//                       delay: 0,
//                       usingSpringWithDamping: 0.5,
//                       initialSpringVelocity: 3,
//                       options: [.curveEaseInOut],
//                       animations: { self.transform = transform },
//                       completion: nil)
//    }
//}
