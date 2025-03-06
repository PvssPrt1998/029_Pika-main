import UIKit
import WebKit
import ApphudSDK

class TokensPaywallViewController: UIViewController {
    
    let model: MainModel
    private lazy var selectedProductIndex = 0
    
    init(model: MainModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let miniActivityIndicator: UIActivityIndicatorView = {
        let activity  = UIActivityIndicatorView(style: .medium)
        activity.color = .white.withAlphaComponent(0.8)
        return activity
    }()
    
    private let bigActivityIndicator: UIActivityIndicatorView = {
        let activity  = UIActivityIndicatorView(style: .large)
        activity.color = .white
        activity.backgroundColor = .black.withAlphaComponent(0.4)
        activity.layer.cornerRadius = 16
        return activity
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.backgroundColor = .secondary
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(.Title2Emphasized)
        button.isEnabled = false
        return button
    }()
    
    private let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "12")
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .vertical
        
        return collection
    }()
    
    private let miniIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .white
        return view
    }()
    
    private let closePaywallButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(.closePaywall, for: .normal)
        button.alpha = 0
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [createMiniView(text: "Top up your balance and keep creating!")])
        view.axis = .vertical
        view.distribution = .fillEqually
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Top up your balance and keep creating!"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    private let pvImageView: UIImageView = {
        let image = UIImageView(image: .pv)
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgPaywall
        collection.delegate = self
        collection.dataSource = self
        setupUI()
        loadProducts()
    }
    
    private func loadProducts() {
        model.purchaseManager.loadPaywalls1 {
            self.productsDownoaded()
            self.collection.reloadData()
            print("Downloaded")
        }
    }
    
    private func productsDownoaded() {
        UIView.animate(withDuration: 0.3) {
            self.collection.snp.remakeConstraints { make in
                make.left.right.equalToSuperview().inset(15)
                make.bottom.equalTo(self.nextButton.snp.top).inset(-15)
                make.height.equalTo(2 * 69 + 2 * 8) //self.model.purchaseManager.productsApphud1.count
            }
            self.collection.reloadData()
            self.miniIndicator.stopAnimating()
            self.nextButton.isEnabled = true
            self.view.layoutIfNeeded()
        }
    }
    
    func tokensForSelected() -> Int {
        switch selectedProductIndex {
        case 0: 10
        case 1: 25
        case 2: 50
        case 3: 100
        case 4: 200
        default: 10
        }
    }
    

    private func setupUI() {
        
        
        let policyButton = createMiniButtons(title: "Privacy Policy", font: .appFont(.Caption2Regular), color: .white.withAlphaComponent(0.3))
        policyButton.addTarget(self, action: #selector(openPolicy), for: .touchUpInside)
        view.addSubview(policyButton)
        policyButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        let restoreButton = createMiniButtons(title: "Restore Purchases", font: .appFont(.Caption1Regular), color: .white.withAlphaComponent(0.6))
        restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
        view.addSubview(restoreButton)
        restoreButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(25)
        }
        
        let termsButton = createMiniButtons(title: "Terms of Use", font: .appFont(.Caption2Regular), color: .white.withAlphaComponent(0.3))
        termsButton.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        view.addSubview(termsButton)
        termsButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        nextButton.addTarget(self, action: #selector(subscribe), for: .touchUpInside)
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(48)
            make.bottom.equalTo(restoreButton.snp.top).inset(-15)
        }
        
        collection.delegate = self
        collection.dataSource = self
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(nextButton.snp.top).inset(-15)
            //make.height.equalTo(300)
            make.height.equalTo(2 * 69 + 2 * 8) //self.model.purchaseManager.productsApphud1.count
        }
        
//        view.addSubview(miniIndicator)
//        miniIndicator.snp.makeConstraints { make in
//            make.center.equalTo(collection)
//        }
//        miniIndicator.startAnimating()
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(collection.snp.top).inset(-16)
            make.height.equalTo(22)
        }
        
        let topLabel = UILabel()
        topLabel.text = "Out of tokens?"
        topLabel.textColor = .white
        topLabel.numberOfLines = 1
        topLabel.textAlignment = .center
        topLabel.font = .appFont(.LargeTitleEmphasized)
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(descriptionLabel.snp.top).inset(-15)
            make.height.equalTo(42)
        }
        
        view.addSubview(pvImageView)
        pvImageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            //make.height.equalTo(340)
            make.bottom.equalTo(topLabel.snp.top).inset(-5)
        }
        
        view.addSubview(closePaywallButton)
        closePaywallButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closePaywallButton.snp.makeConstraints { make in
            make.height.width.equalTo(23)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.right.equalToSuperview().inset(15)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3) {
                self.closePaywallButton.alpha = 1
            }
        }
        
        view.addSubview(bigActivityIndicator)
        bigActivityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(64)
        }
    }
    
    private func createMiniButtons(title: String, font: UIFont, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = font
        button.setTitleColor(color, for: .normal)
        return button
    }
    
    private func createMiniView(text: String) -> UIView {
        let view = UIView()
        let label = UILabel()
        label.text = text
        label.textColor = .white.withAlphaComponent(0.8)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        return view
    }
    
    @objc private func restore() {
        bigActivityIndicator.startAnimating()
        model.purchaseManager.restorePurchase { isRestore in
            if isRestore {
                self.model.purchasePublisher.send(1)
                self.showAlert(title: "Success", message: "Your purchases have been restored.")
            } else {
                self.showAlert(title: "Attention", message: "No purchases found. Write to us if this is not the case")
            }
            self.bigActivityIndicator.stopAnimating()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    @objc private func openPolicy() {
        let webVC = WebViewController()
        webVC.urlString = "https://docs.google.com/document/d/1Bzr1G22pUKtzDY6VxoiaMAHtEqgTSpYbuXhtMZ4I-Cw/edit?usp=sharing"
        present(webVC, animated: true, completion: nil)
    }
    
    @objc private func openTerms() {
        let webVC = WebViewController()
        webVC.urlString = "https://docs.google.com/document/d/13JXlS7pZorpyb5H5V6nCiATAVDWDyenf0wSs3KRGQf4/edit?usp=sharing"
        present(webVC, animated: true, completion: nil)
    }
    
    @objc private func close() {
        self.dismiss(animated: true)
    }
    
    private func getSubscriptionDuration(for product: ApphudProduct) -> String {
        switch product.skProduct?.subscriptionPeriod?.unit{
        case .month:
            return "Monthly"
        case .year:
            return "Yearly"
        case .week:
            return "Weekly"
        case .day:
            return "Weekly"
        default:
            return "Unknown"
        }
    }
    
    private func getTokensAmount(for product: ApphudProduct) -> String {
        print("Token")
        print(getSubscriptionPrice(for: product))
        if doubleInAround(9.99, value1: getSubscriptionPrice(for: product)) {
            print("Token")
            print(getSubscriptionPrice(for: product))
            return "100"
        }
        if doubleInAround(5.99, value1: getSubscriptionPrice(for: product)) {
            return "100"
        }
        if doubleInAround(19.99, value1: getSubscriptionPrice(for: product)) {
            return "250"
        }
        if doubleInAround(34.99, value1: getSubscriptionPrice(for: product)) {
            return "500"
        }
        if doubleInAround(99.99, value1: getSubscriptionPrice(for: product)) {
            return "2000"
        }
        if doubleInAround(59.99, value1: getSubscriptionPrice(for: product)) {
            return "1000"
        }
        return "Error"
    }
    
    private func getSubscriptionSymbol(for product: ApphudProduct) -> String {
        return product.skProduct?.priceLocale.currencySymbol ?? "$"
    }
    
    private func getSubscriptionPrice(for product: ApphudProduct) -> Double {
        if let price = product.skProduct?.price {
            return Double(truncating: price)
        } else {
            return 0
        }
    }
    
    func doubleInAround(_ value: Double, value1: Double) -> Bool {
        if value < value1 + 0.01 && value > value1 - 0.01 {
            return true
        } else { return false }
    }
    
    @objc private func subscribe() {
        bigActivityIndicator.startAnimating()
        model.purchaseManager.startPurchase(produst: model.purchaseManager.productsApphud1[selectedProductIndex]) { isSuccess in
            if isSuccess {
                self.model.purchasePublisher.send(1)
                self.model.netWorking.buyTokens(apphudId: userID, tokens: self.tokensForSelected()) { availableTokens in
                    self.model.tokens += availableTokens
                    self.dismiss(animated: true)
                } errorHandler: {
                    
                }
                
            }
            
            DispatchQueue.main.async {
                self.showBuyAlert(isSuccess: isSuccess)
            }
        }
    }
    
    private func showBuyAlert(isSuccess: Bool) {
        bigActivityIndicator.stopAnimating()
        let alert = UIAlertController(title: isSuccess ? "Thank you for subscribing!" : "Something went wrong", message: isSuccess ? "Paid features are now available to you" : "Please try again.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            //self.dismiss(animated: true)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}

extension TokensPaywallViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.purchaseManager.productsApphud1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("CELL")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "12", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .bgLight
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = selectedProductIndex == indexPath.row ? 2 : 0
        cell.layer.borderColor = selectedProductIndex == indexPath.row ? UIColor.secondary.cgColor : UIColor.clear.cgColor
        
        let item = model.purchaseManager.productsApphud1[indexPath.row]
        let value = getTokensAmount(for: item)
        let nameLabel = UILabel()
        nameLabel.text = value
        nameLabel.textColor = .white
        nameLabel.font = .appFont(.Title3Emphasized)
        cell.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(cell.snp.centerY)
            make.left.equalToSuperview().inset(15)
        }
        
        let tokensLabel = UILabel()
        tokensLabel.text = "Tokens"
        tokensLabel.textColor = .white.withAlphaComponent(0.6)
        tokensLabel.font = .appFont(.BodyRegular)
        cell.addSubview(tokensLabel)
        tokensLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.left.equalTo(nameLabel.snp.right).inset(-8)
        }
        
        let chevronImage = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImage.tintColor = .white.withAlphaComponent(0.6)
        chevronImage.contentMode = .scaleToFill
        cell.addSubview(chevronImage)
        chevronImage.snp.makeConstraints { make in
            make.width.equalTo(8)
            make.height.equalTo(14)
            make.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        
        let price: Double = getSubscriptionPrice(for: item)
        
        let countLabel = UILabel()
        countLabel.textColor = .white
        countLabel.text = getSubscriptionSymbol(for: item) + "\(Double(String(format: "%.2f", price)) ?? 0.0)"
        cell.addSubview(countLabel)
        countLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        countLabel.font = .appFont(.BodyRegular)
        countLabel.snp.makeConstraints { make in
            make.right.equalTo(chevronImage.snp.left).inset(-16)
            make.centerY.equalToSuperview()
        }
//
//        if nameLabel.text == "Yearly" {
//            
//            let weekLabel = UILabel()
//            weekLabel.text = "/per week 🔥"
//            weekLabel.textColor = .white
//            weekLabel.font = .appFont(.FootnoteRegular)
//            cell.addSubview(weekLabel)
//            weekLabel.snp.makeConstraints { make in
//                make.bottom.equalToSuperview().inset(9)
//                make.right.equalToSuperview().inset(15)
//            }
//            
// 
//            let salelabel = UILabel()
//            salelabel.textColor = .white
//            salelabel.font = .appFont(.FootnoteRegular)
//            salelabel.text = fireEmojiBeforePrice(nameLabel: nameLabel.text ?? "") + getSubscriptionSymbol(for: item) + "\(Double(String(format: "%.2f", price / 52)) ?? 0.0)"
//            cell.addSubview(salelabel)
//            salelabel.snp.makeConstraints { make in
//                make.right.equalTo(weekLabel.snp.left)
//                make.bottom.equalToSuperview().inset(9)
//            }
//            
//            let saleLabel = UILabel()
//            saleLabel.backgroundColor = UIColor.secondary
//            saleLabel.layer.cornerRadius = 5
//            saleLabel.clipsToBounds = true
//            saleLabel.text = "SAVE 84%"
//            saleLabel.textColor = .black
//            saleLabel.textAlignment = .center
//            saleLabel.font = .appFont(.Caption1Regular)
//            cell.addSubview(saleLabel)
//            saleLabel.snp.makeConstraints { make in
//                make.centerX.equalTo(weekLabel.snp.centerX)
//                make.height.equalTo(24)
//                make.width.equalTo(75)
//                make.bottom.equalTo(weekLabel.snp.top).inset(-4)
//            }
//            
//            countLabel.snp.makeConstraints { make in
//                make.left.equalToSuperview().inset(15)
//                make.top.equalTo(cell.snp.centerY).offset(2)
//            }
//            countLabel.textColor = .white.withAlphaComponent(0.6)
//            countLabel.font = .appFont(.Caption1Regular)
//        } else {
//            countLabel.textColor = UIColor.white.withAlphaComponent(0.6)
//            countLabel.font = .appFont(.SubheadlineRegular)
//            countLabel.snp.makeConstraints { make in
//                make.right.equalToSuperview().inset(15)
//                make.centerY.equalToSuperview()
//                
//            }
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedProductIndex = indexPath.row
        collectionView.reloadData()
    }
}


