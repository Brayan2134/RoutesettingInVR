import UIKit

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView = UITableView()
    var selectedShape: ((ShapeType) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupTableView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Add Item"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        case 1, 2:
            cell.textLabel?.text = "Text"
            cell.isUserInteractionEnabled = false
        case 3:
            cell.textLabel?.text = "---------------------"
            cell.isUserInteractionEnabled = false
        case 4:
            cell.textLabel?.text = "Sphere"
        case 5:
            cell.textLabel?.text = "Box"
        case 6:
            cell.textLabel?.text = "Cylinder"
        default:
            cell.textLabel?.text = ""
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 4:
            selectedShape?(.sphere)
        case 5:
            selectedShape?(.box)
        case 6:
            selectedShape?(.cylinder)
        default:
            break
        }
        
        dismiss(animated: true, completion: nil)
    }
}
