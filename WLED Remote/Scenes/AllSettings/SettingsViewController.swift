//
//  SettingsViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/17/21.
//

import UIKit

struct SettingsOption {
    let title: String
    let image: UIImage?
    let handler: (() -> Void)
}

class SettingsViewController: UITableViewController {

    // MARK: View Model
    var viewModel: SettingsViewModel!

    var models: [SettingsOption] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .mainSystemBackground

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        configure()
        tableView.reloadData()
        bindViewController()
    }

    private func configure() {
        models.append(SettingsOption(title: "Light Setup", image: nil, handler: {
            // hola
        }))
    }

    func bindViewController() {

    }
}

// MARK: - Data Source
extension SettingsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        cell.imageView?.image = model.image
        return cell
    }
}
