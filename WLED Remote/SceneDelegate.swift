//
//  SceneDelegate.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/8/21.
//

import UIKit
import RxSwift
import WLEDClient
import Network

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var assembler: Assembler = DefaultAssembler()
    var disposeBag = DisposeBag()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        bindViewModel()
    }

    private func bindViewModel() {
        guard let window = window else { return }

        let viewModel: AppViewModel = assembler.resolve(window: window)
        let input = AppViewModel.Input(loadTrigger: .just(()))
        _ = viewModel.transform(input, disposeBag: disposeBag)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

