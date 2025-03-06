import UIKit
import SnapKit
import Combine

class TabBarViewController: UITabBarController {
    
    private var model: MainModel
    private var cancellabel = [AnyCancellable]()
    
    lazy var proButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(.proButton, for: .normal)
        return button
    }()
    
    init(model: MainModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserDefaults.standard.setValue(true, forKey: "onb")
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.showNavigationBar()
        setupNav()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        proButton.addTarget(self, action: #selector(openPaywall), for: .touchUpInside)
        setupUI()
        subscribe()
    }
    
    private func subscribe() {
        model.purchasePublisher
            .sink { _ in
                self.updateProButtonForNavBarState()
            }
            .store(in: &cancellabel)
    }
    
    private func setupNav() {
        guard let navigationController = self.navigationController else { return }

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .bgSecond
        appearance.shadowColor = nil

        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold) //22
        ]

        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.tintColor = .white

        updateProButtonForNavBarState()
    }

    
    private func updateProButtonForNavBarState() {
        let proBarButton = UIBarButtonItem(customView: proButton)
        proBarButton.isHidden = model.purchaseManager.hasUnlockedPro
        if model.purchaseManager.hasUnlockedPro {
            navigationItem.rightBarButtonItem  = .none
        } else {
            navigationItem.rightBarButtonItem  = proBarButton
            proButton.setBackgroundImage(.proButton, for: .normal)
            proButton.snp.makeConstraints { make in
                make.height.equalTo(24)
                make.width.equalTo(63)
            }
        }
    }
    
    private func setupUI() {
        tabBar.unselectedItemTintColor = .white.withAlphaComponent(0.4)
        tabBar.tintColor = .secondary
        tabBar.backgroundColor = .bgSecond
        tabBar.isTranslucent = false
        tabBar.barTintColor = UIColor.bgSecond
        //tabBar.barTintColor = UIColor.bgSecond
        
        let separatorView = UIView()
        separatorView.backgroundColor = .white.withAlphaComponent(0.24)
        tabBar.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(0.33)
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        var createVCNo: UIViewController = EffectsViewController(model: model)
        if model.isSecondType {
            createVCNo = EffectsViewControllerV2(model: model)
        }
        let settingsVCNo = SettingsViewController(model: model)
        let myVideosVCNo = HistoryViewController(model: model)
        
        let createVc = createVC(VC: createVCNo, image: .tab1.resize(targetSize: CGSize(width: 26, height: 26)), title: "Effects")
        let videosVc = createVC(VC: myVideosVCNo, image: .tab2.resize(targetSize: CGSize(width: 26, height: 26)), title: "My Videos")
        let settingsVc = createVC(VC: settingsVCNo, image: .tab3.resize(targetSize: CGSize(width: 26, height: 26)), title: "Settings")

        
        viewControllers = [createVc, videosVc, settingsVc]
    }
   
    private func createVC(VC: UIViewController, image: UIImage, title: String) -> UIViewController {
        let tapItem = UITabBarItem(title: title, image: image, tag: 0)
        VC.tabBarItem = tapItem
        return VC
    }
    
    @objc func openPaywall() {
        let paywallViewController = PaywallViewController(model: model)
        paywallViewController.modalPresentationStyle = .fullScreen
        paywallViewController.modalTransitionStyle = .coverVertical
        if #available(iOS 13.0, *) {
            paywallViewController.isModalInPresentation = true
        }
        self.present(paywallViewController, animated: true)
    }
}
