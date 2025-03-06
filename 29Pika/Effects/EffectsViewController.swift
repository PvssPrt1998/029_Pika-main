import UIKit
import SystemConfiguration
import GSPlayer
import Combine

class EffectsViewController: UIViewController {
    
    let model: MainModel
    private lazy var cancellable = [AnyCancellable]()
    private let facoritePublisher = PassthroughSubject<Any,Never>()
    private let genTappedPublisher = PassthroughSubject<Effect,Never>()
    
    private lazy var sortedArr: [Effect] = [
//        Effect(id: 1, ai: "pv", effect: "Levitate it", preview: "https://vewapnew.online/storage/preview/9JX57sakrQniJBdcFfyBWDXmDfIQj3UfmlDJkpax.mp4?t=1738906171", previewSmall: "LevitateIt"),
//        Effect(id: 4, ai: "pv", effect: "Inflate it", preview: "https://vewapnew.online/storage/preview/iDNDGK5y9zMMatybYoK9tCZnywS8MU8IWWJFaV8Z.mp4?t=1738906171", previewSmall: "InflateIt"),
//        Effect(id: 5, ai: "pv", effect: "Melt it", preview: "https://vewapnew.online/storage/preview/ssPRdA5xjg8EajVxgRgC7bZxTq65jqsYs4bMcTON.mp4?t=1738906171", previewSmall: "MeltIt"),
//        Effect(id: 10, ai: "pv", effect: "Ta-da it", preview: "https://vewapnew.online/storage/preview/6oDcfuMjn9T2wwWniSvB3cEvPTNXXxmXLFd3yybj.mp4?t=1738906171", previewSmall: "TaDaIt"),
//        Effect(id: 13, ai: "pv", effect: "Dissolve it", preview: "https://vewapnew.online/storage/preview/zQWrJEFKvsfHFsClgR5yzW3yHCVXLlmQWM6rGdz7.mp4?t=1738906171", previewSmall: "DissolveIt"),
//        Effect(id: 54, ai: "pv", effect: "Peel it", preview: "https://vewapnew.online/storage/preview/oEZtP4cU5TV3OLMfqonk2zcHsviwv1FpD9bHKbIq.mp4?t=1738906171", previewSmall: "PeelIt"),
//        Effect(id: 56, ai: "pv", effect: "Tear it", preview: "https://vewapnew.online/storage/preview/EWQXghnpVLCGdOJXPfK2miVaLCDbFrcpJLrV7srv.mp4?t=1738906171", previewSmall: "TearIt"),
//        Effect(id: 2, ai: "pv", effect: "Decapitate it", preview: "https://vewapnew.online/storage/preview/QolvHeHOCxB3naJbijWEDUJmNPrifsUlVqNvGLxv.mp4?t=1738906171", previewSmall: "DecapitateIt"),
//        Effect(id: 3, ai: "pv", effect: "Eye-pop it", preview: "https://vewapnew.online/storage/preview/vWy7H3nQovCQPfVMsN00SaZzDJjZDNqGUJgyiqTA.mp4?t=1738906171", previewSmall: "EyePopIt"),
//        Effect(id: 55, ai: "pv", effect: "Poke it", preview: "https://vewapnew.online/storage/preview/Rk5i55bQqimTh0YaFeeLAVTpI0nhA3J64U3QjrgE.mp4?t=1738906171", previewSmall: "PokeIt"),
//        Effect(id: 6, ai: "pika", effect: "Explode it", preview: "https://vewapnew.online/storage/preview/lQNR8fvmKDD3p36lb6dDsj4RNXiPVPKCwC4u5B9e.mp4?t=1737103978", previewSmall: "ExplodeIt"),
//        Effect(id: 57, ai: "pv", effect: "Sheep Curls", preview: "https://vewapnew.online/storage/preview/AdYtaS4f73lyV9uajK3HubUV5wdoDDzy4gWQ0abD.mp4?t=1738906171", previewSmall: "SheepCurls"),
//        Effect(id: 24, ai: "pv", effect: "Hair Growth Magic", preview: "https://vewapnew.online/storage/preview/LS98dH8wJ8wZA0eoxIXzDPZrOZl0g08YA6jEroyK.mp4?t=1738906171", previewSmall: "HairGrowthMagic"),
//        Effect(id: 52, ai: "pv", effect: "Wizard Hat", preview: "https://vewapnew.online/storage/preview/rWY5OnsMzGyU3GV4HClILxbRh3ucdnuveDP6VRU5.mp4?t=1738906171", previewSmall: "WizardHat")
    ]
    
    private lazy var selectedType: typeArr = .pika
    private let buttonPika = UIButton(type: .system)
    private let pixVerseButton = UIButton(type: .system)
    
    init(model: MainModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNav()
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: "view", withReuseIdentifier: "view")
        return collectionView
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Effect name"
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .bgMain
        searchBar.searchTextField.textColor = .white
        searchBar.isUserInteractionEnabled = false
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgMain
        setupUI()
        subscribeFavrite()
        someMethod()
        subscribe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkInternetAvailable()
    }
    
    private func subscribeFavrite() {
        facoritePublisher.sink { _ in
            self.collectionView.reloadSections(IndexSet(integer: 1))
        }
        .store(in: &cancellable)
        
        genTappedPublisher
            .sink { effect in
                self.goGenerate(index: effect)
            }
            .store(in: &cancellable)
    }
    
    private func someMethod() {
        Task {
            await loadData()
        }
    }
    
    private func loadData() async {
        while model.arr.count < 1 {
            await Task.sleep(500_000_000)
        }
        searchBar.isUserInteractionEnabled = true
        model.arr.forEach { category in
            sortedArr.append(contentsOf: category.items)
        }
        collectionView.reloadData()
    }
    
    private func goGenerate(index: Effect) {
        let vc = LoadImaeViewController(effect: index, model: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func setupNav() {
        let longTitleLabel = UILabel()
        longTitleLabel.text = "Pika AI"
        longTitleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        longTitleLabel.textColor = .white
        longTitleLabel.sizeToFit()
        
        let leftItem = UIBarButtonItem(customView: longTitleLabel)
        self.tabBarController?.navigationItem.leftBarButtonItem = leftItem
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch sectionIndex {
            case 0:
                return self.createVerticalSection()//self.createStaticViewSection(index: 0)
            case 1:
                return self.createHorizontalSection()
            case 2:
                return self.createStaticViewSection(index: 1)
            default:
                return self.createStaticViewSection(index: 0)//self.createVerticalSection()
            }
        }
    }
    
    func createHorizontalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(96), heightDimension: .absolute(96))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(96), heightDimension: .absolute(96))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        
        return section
    }
    
    // Вторая секция: Статическое вью
    func createStaticViewSection(index: Int) -> NSCollectionLayoutSection {
        let viewSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: index == 0 ? .absolute(30) : .absolute(100))
        let view = NSCollectionLayoutItem(layoutSize: viewSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: index == 0 ? .absolute(30) : .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [view])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    // Третья секция: Вертикальные ячейки
    func createVerticalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(250))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(250))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)//NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item], count)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        
        return section
    }
    
    @objc private func pikaTapped() {
        self.selectedType = .pika
        //let arr = model.returnArr(type: .pika)
        //self.sortedArr = arr
        buttonPika.setTitleColor(.white, for: .normal)
        pixVerseButton.setTitleColor(UIColor(red: 173/255, green: 204/255, blue: 255/255, alpha: 0.3), for: .normal)
        collectionView.reloadSections(IndexSet(integer: 3))
        searchBar.endEditing(true)
        searchBar.text = ""
    }
    
    @objc private func pxTapped() {
        self.selectedType = .px
        //let arr = model.returnArr(type: .px)
        //self.sortedArr = arr
        pixVerseButton.setTitleColor(.white, for: .normal)
        buttonPika.setTitleColor(UIColor(red: 173/255, green: 204/255, blue: 255/255, alpha: 0.3), for: .normal)
        collectionView.reloadSections(IndexSet(integer: 3))
        searchBar.endEditing(true)
        searchBar.text = ""
    }
    
    @objc private func tryTapped(sender: MyTapGesture) {
        guard model.connectionAvailable else { return }
        guard isInternetAvailable() else { return }
        if let item = sender.effect {
            print(item)
            //openPreview(item: item)
            //let vc = LoadImaeViewController(effect: index, model: model)
            let vc = PreviewV2ViewController(model: model, effect: item)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func likeTapped(id: Int) {
    }
    
    private func openPreview(item: Effect) {
        let vc = PreviewViewController(model: model, item: item, publisherFavirite: facoritePublisher, genTappedPublisher: genTappedPublisher)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        if #available(iOS 13.0, *) {
            vc.isModalInPresentation = true
        }
        self.present(vc, animated: true)
    }
    
}

extension EffectsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // Горизонтальная, статическое вью, вертикальные ячейки
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return sortedArr.count //1
        case 1:
            return 0//model.favoriteArrID.count > 0 ?  model.favoriteArrID.count : 1
        case 2:
            return 0//1
        case 3:
            return 0//1 //sortedArr.count
        default:
            return 0//1
        }
    }
    
    func checkInternetAvailable() {
        let availalbe = isInternetAvailable()
        print("Available \(availalbe)")
        if availalbe {
            print("IS AVAILABLE")
            model.connectionAvailable = availalbe
        } else {
            print("no connection alert")
            noConnectionAlert()
        }
    }
    
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    private func subscribe() {
        model.arrChangedPublisher
            .sink { _ in
                var array: [Effect] = []
                self.model.arr.forEach { category in
                    array.append(contentsOf: category.items)
                }
                self.sortedArr = array
            }
            .store(in: &cancellable)
    }
    
    private func noConnectionAlert() {
        let alert = UIAlertController(title: "Error", message: "No internet connection", preferredStyle: .alert)
        
        let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { [weak self] _  in
            self?.checkInternetAvailable()
        }
        alert.addAction(tryAgainAction)
        
        self.present(alert, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .clear
        cell.clipsToBounds = true
        
        switch indexPath.section {
        case 3: //remove //ex0
            let label = UILabel()
            label.text = "Your Favorite Effects"
            label.textColor = .white
            label.font = .appFont(.Title2Regular)
            cell.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(15)
                make.centerY.equalToSuperview()
            }
        case 0: //ex3
            let item = sortedArr[indexPath.row]
            let nameLabel = UILabel()
            nameLabel.text = item.effect
            nameLabel.textColor = .white
            nameLabel.font = .appFont(.Title2Regular)
            cell.addSubview(nameLabel)
            nameLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(4)
                make.top.equalToSuperview()//.inset(15)
            }
            
            let bgView = UIView()
            bgView.backgroundColor = .bgLight
            bgView.layer.cornerRadius = 8
            bgView.clipsToBounds = true
            cell.addSubview(bgView)
            bgView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(4)
                make.bottom.equalToSuperview()
                make.top.equalTo(nameLabel.snp.bottom).inset(-8)
            }
            
            let load = UIActivityIndicatorView(style: .large)
            load.color = .white
            bgView.addSubview(load)
            load.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            load.startAnimating()
            
            let tap = MyTapGesture(target: self, action: #selector(self.tryTapped(sender:)))
            tap.effect = item
            
            let player = VideoPlayerView()
            player.layer.cornerRadius = 8
            player.clipsToBounds = true
            player.playerLayer.videoGravity = .resizeAspectFill
            player.addGestureRecognizer(tap)
            cell.addSubview(player)
            player.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(4)
                make.bottom.equalToSuperview()
                make.top.equalTo(nameLabel.snp.bottom).inset(-8)
            }
            
            if let urlStr = item.previewSmall, let url = URL(string: urlStr) {
                player.play(for: url)
                player.isMuted = true
            }
            
//            if let url = Bundle.main.url(forResource: item.previewSmall ?? "", withExtension: "mp4") {
//                player.play(for: url)
//                player.isMuted = true
//            }
            
        
            
//        case 1: //remove
//            
//           
//            
//            cell.backgroundColor = .bgLight
//            cell.layer.cornerRadius = 10
//            
//            if model.favoriteArrID.count > 0 {
//                let load = UIActivityIndicatorView(style: .large)
//                load.color = .white
//                cell.addSubview(load)
//                load.snp.makeConstraints { make in
//                    make.center.equalToSuperview()
//                }
//                load.startAnimating()
//                
//                
//                
//                
//                let player = VideoPlayerView()
//                player.backgroundColor = .bgLight
//                player.layer.cornerRadius = 16
//                player.clipsToBounds = true
//                player.playerLayer.videoGravity = .resizeAspectFill
//                cell.addSubview(player)
//                player.snp.makeConstraints { make in
//                    make.edges.equalToSuperview()
//                }
//                
//                let smallShaow = UIImageView(image: .smallShadow)
//                cell.addSubview(smallShaow)
//                smallShaow.snp.makeConstraints { make in
//                    make.left.right.equalToSuperview().inset(-5)
//                    make.bottom.equalToSuperview()
//                    make.height.equalTo(50)
//                }
//                
//                let label = UILabel()
//                label.font = .systemFont(ofSize: 17, weight: .regular)
//                label.textColor = .white
//                label.textAlignment = .center
//                label.numberOfLines = 2
//                cell.addSubview(label)
//                label.snp.makeConstraints { make in
//                    make.centerX.equalToSuperview()
//                    make.bottom.equalToSuperview().inset(5)
//                    make.left.right.equalToSuperview().inset(3)
//                }
//                
//                if let itemIRL = model.arr.first(where: {$0.id == model.favoriteArrID[indexPath.row]}) {
//                    if let url: URL = URL(string: itemIRL.previewSmall ?? "") {
//                        player.play(for: url)
//                        player.isMuted = true
//                    }
//                    label.text = itemIRL.effect
//                }
//            } else {
//                let label = UILabel()
//                label.text = "Add effect to favorites!"
//                label.textAlignment = .center
//                label.numberOfLines = 0
//                label.textColor = .white
//                label.font = .systemFont(ofSize: 17, weight: .regular)
//                cell.addSubview(label)
//                label.snp.makeConstraints { make in
//                    make.left.right.equalToSuperview().inset(10)
//                    make.centerY.equalToSuperview()
//                }
//            }
            
           
            
        case 2://remove
            searchBar.delegate = self
            cell.addSubview(searchBar)
            searchBar.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(36)
                make.top.equalToSuperview()
            }
            
            buttonPika.backgroundColor = .bgLight
            buttonPika.setTitle("Pika", for: .normal)
            buttonPika.titleLabel?.font = .appFont(.BodyRegular)
            buttonPika.layer.cornerRadius = 8
            buttonPika.setTitleColor( selectedType == .pika ? .white : UIColor(red: 173/255, green: 204/255, blue: 255/255, alpha: 0.3), for: .normal)
            cell.addSubview(buttonPika)
            buttonPika.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(15)
                make.height.equalTo(38)
                make.top.equalTo(searchBar.snp.bottom).inset(-15)
                make.right.equalTo(cell.snp.centerX).offset(-5)
            }
            buttonPika.addTarget(self, action: #selector(pikaTapped), for: .touchUpInside)
            
            pixVerseButton.backgroundColor = .bgLight
            pixVerseButton.setTitle("PixVerse", for: .normal)
            pixVerseButton.titleLabel?.font = .appFont(.BodyRegular)
            pixVerseButton.layer.cornerRadius = 8
            pixVerseButton.setTitleColor( selectedType == .px ? .white : UIColor(red: 173/255, green: 204/255, blue: 255/255, alpha: 0.3), for: .normal)
            cell.addSubview(pixVerseButton)
            pixVerseButton.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(15)
                make.height.equalTo(38)
                make.top.equalTo(searchBar.snp.bottom).inset(-15)
                make.left.equalTo(cell.snp.centerX).offset(5)
            }
            pixVerseButton.addTarget(self, action: #selector(pxTapped), for: .touchUpInside)
            
        default:
            print("index out")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        if indexPath.section == 1 && model.favoriteArrID.count > 0 {
            //likeTapped(id: model.favoriteArrID[indexPath.row])
        }
    }
}


extension EffectsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) {
            searchBar.showsCancelButton = true
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) {
            searchBar.showsCancelButton = false
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        UIView.animate(withDuration: 0.3) {
            searchBar.showsCancelButton = false
        }
        print(1)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//           if searchText.isEmpty {
//               sortedArr = model.returnArr(type: selectedType)
//           } else {
//               sortedArr = model.returnArr(type: selectedType).filter { effect in
//                   effect.effect.lowercased().contains(searchText.lowercased())
//               }
//           }
//        collectionView.reloadSections(IndexSet(integer: 3))
    }
}

class MyTapGesture: UITapGestureRecognizer {
    var effect: Effect?
}
