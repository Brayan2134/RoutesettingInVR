import UIKit

class OptionsViewController: UIViewController {

    var selectedShape: ((ShapeType) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        // Indicator Line
        let indicatorLine = UIView()
        indicatorLine.backgroundColor = .lightGray
        indicatorLine.layer.cornerRadius = 2.5
        indicatorLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicatorLine)
        
        // Header Label
        let headerLabel = UILabel()
        headerLabel.text = "Add new element"
        headerLabel.textColor = .black
        headerLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        
        // Spacer
        let spacer = UIView()
        spacer.backgroundColor = .gray
        spacer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacer)
        
        // Quick Options subheading
        let quickOptionsLabel = UILabel()
        quickOptionsLabel.text = "Quick Options"
        quickOptionsLabel.textColor = .black
        quickOptionsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        quickOptionsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quickOptionsLabel)

        // Snap to Wall button
        let snapButton = UIButton(type: .system)
        snapButton.setTitle("Snap objects to wall", for: .normal)
        snapButton.backgroundColor = UIColor(red: 24/255, green: 24/255, blue: 24/255, alpha: 1.0)
        snapButton.setTitleColor(.white, for: .normal)
        snapButton.layer.cornerRadius = 8
        snapButton.translatesAutoresizingMaskIntoConstraints = false
        snapButton.addTarget(self, action: #selector(snapToWallButtonTapped), for: .touchUpInside)
        view.addSubview(snapButton)
    
        // Basic Shapes subheading
        let subheadingLabel = UILabel()
        subheadingLabel.text = "Basic Shapes"
        subheadingLabel.textColor = .black
        subheadingLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        subheadingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subheadingLabel)
        
        // Carousel View
        let carouselStackView = UIStackView()
        carouselStackView.axis = .horizontal
        carouselStackView.alignment = .center
        carouselStackView.distribution = .equalSpacing
        carouselStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let shapes: [(String, ShapeType)] = [("Sphere", .sphere), ("Box", .box), ("Cylinder", .cylinder)]
        for (shapeName, shapeType) in shapes {
            let shapeView = UIView()
            shapeView.backgroundColor = .blue
            shapeView.layer.cornerRadius = 8
            shapeView.translatesAutoresizingMaskIntoConstraints = false
            
            let shapeLabel = UILabel()
            shapeLabel.text = shapeName
            shapeLabel.textColor = .white
            shapeLabel.textAlignment = .center
            shapeLabel.translatesAutoresizingMaskIntoConstraints = false
            
            shapeView.addSubview(shapeLabel)
            carouselStackView.addArrangedSubview(shapeView)
            
            NSLayoutConstraint.activate([
                shapeView.widthAnchor.constraint(equalToConstant: 100),
                shapeView.heightAnchor.constraint(equalToConstant: 100),
                shapeLabel.centerXAnchor.constraint(equalTo: shapeView.centerXAnchor),
                shapeLabel.centerYAnchor.constraint(equalTo: shapeView.centerYAnchor)
            ])
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(shapeTapped(_:)))
            shapeView.addGestureRecognizer(tapGesture)
            shapeView.isUserInteractionEnabled = true
            shapeView.tag = shapes.firstIndex { $0.1 == shapeType } ?? 0
        }
        
        view.addSubview(carouselStackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            indicatorLine.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            indicatorLine.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorLine.widthAnchor.constraint(equalToConstant: 40),
            indicatorLine.heightAnchor.constraint(equalToConstant: 5),
            
            headerLabel.topAnchor.constraint(equalTo: indicatorLine.bottomAnchor, constant: 20),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            spacer.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            spacer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            spacer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            spacer.heightAnchor.constraint(equalToConstant: 1),
            
            quickOptionsLabel.topAnchor.constraint(equalTo: spacer.bottomAnchor, constant: 20),
            quickOptionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            snapButton.topAnchor.constraint(equalTo: quickOptionsLabel.bottomAnchor, constant: 10),
            snapButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            snapButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -30),
            snapButton.heightAnchor.constraint(equalToConstant: 40),
            
            subheadingLabel.topAnchor.constraint(equalTo: snapButton.bottomAnchor, constant: 20),
            subheadingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            carouselStackView.topAnchor.constraint(equalTo: subheadingLabel.bottomAnchor, constant: 20),
            carouselStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            carouselStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            carouselStackView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc private func shapeTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        let shapes: [ShapeType] = [.sphere, .box, .cylinder]
        let selected = shapes[index]
        
        switch selected {
        case .sphere:
            selectedShape?(.sphere)
        case .box:
            selectedShape?(.box)
        case .cylinder:
            selectedShape?(.cylinder)
        }
        
        // Close the UI
        dismiss(animated: true, completion: nil)
    }
    
    @objc func snapToWallButtonTapped() {
        print("USER PRESSED BUTTON: snapToWallButton")
        NotificationCenter.default.post(name: NSNotification.Name("SnapToWall"), object: nil)
    }
}
