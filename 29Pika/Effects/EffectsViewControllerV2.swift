import UIKit
import SystemConfiguration
import GSPlayer
import Combine

class EffectsViewControllerV2: UIViewController {
    
    let model: MainModel
    private lazy var cancellable = [AnyCancellable]()
    private lazy var arrCancellable: AnyCancellable? = nil
    private let facoritePublisher = PassthroughSubject<Any,Never>()
    private let genTappedPublisher = PassthroughSubject<Effect,Never>()
    
    private lazy var sortedArr: [SortedEffects] = [
//        SortedEffects(header: "Popular", items: [
//            Effect(id: 1, ai: "pv", effect: "Levitate it", preview: "https://vewapnew.online/storage/preview/9JX57sakrQniJBdcFfyBWDXmDfIQj3UfmlDJkpax.mp4?t=1738906171", previewSmall: "LevitateIt"),
//            Effect(id: 4, ai: "pv", effect: "Inflate it", preview: "https://vewapnew.online/storage/preview/iDNDGK5y9zMMatybYoK9tCZnywS8MU8IWWJFaV8Z.mp4?t=1738906171", previewSmall: "InflateIt"),
//            Effect(id: 5, ai: "pv", effect: "Melt it", preview: "https://vewapnew.online/storage/preview/ssPRdA5xjg8EajVxgRgC7bZxTq65jqsYs4bMcTON.mp4?t=1738906171", previewSmall: "MeltIt"),
//            Effect(id: 10, ai: "pv", effect: "Ta-da it", preview: "https://vewapnew.online/storage/preview/6oDcfuMjn9T2wwWniSvB3cEvPTNXXxmXLFd3yybj.mp4?t=1738906171", previewSmall: "TaDaIt"),
//            Effect(id: 13, ai: "pv", effect: "Dissolve it", preview: "https://vewapnew.online/storage/preview/zQWrJEFKvsfHFsClgR5yzW3yHCVXLlmQWM6rGdz7.mp4?t=1738906171", previewSmall: "DissolveIt"),
//            Effect(id: 18, ai: "pv", effect: "Muscle Surge", preview: "https://vewapnew.online/storage/preview/sOBMFE5jSlLpTxcgTbvOy7w21VkM5iKiDeAQ2Qcq.mp4?t=1738906171", previewSmall: "MuscleSurge"),
//            Effect(id: 38, ai: "pv", effect: "Wicked Shots", preview: "https://vewapnew.online/storage/preview/4P9PB795AzPQoVljlZV2uLfLYcQUvE4phkKJfY92.mp4?t=1738906171", previewSmall: "WickedShots"),
//            Effect(id: 46, ai: "pv", effect: "Lego Blast", preview: "https://vewapnew.online/storage/preview/ICzCw9wvh9PtSVSBzno1lQyNiyvAgKMtiS5LAePW.mp4?t=1738906171", previewSmall: "LegoBlast"),
//            Effect(id: 53, ai: "pv", effect: "Out of Frame", preview: "https://vewapnew.online/storage/preview/vgpAzZ04s4NLuqOWwdUdiZsRLpwGAAsMuIpikqUY.mp4?t=1738906171", previewSmall: "OutOfFrame"),
//            Effect(id: 54, ai: "pv", effect: "Peel it", preview: "https://vewapnew.online/storage/preview/oEZtP4cU5TV3OLMfqonk2zcHsviwv1FpD9bHKbIq.mp4?t=1738906171", previewSmall: "PeelIt"),
//            Effect(id: 56, ai: "pv", effect: "Tear it", preview: "https://vewapnew.online/storage/preview/EWQXghnpVLCGdOJXPfK2miVaLCDbFrcpJLrV7srv.mp4?t=1738906171", previewSmall: "TearIt")
//        ]),
//        SortedEffects(header: "Hug and Kiss", items: [
//            Effect(id: 59, ai: "pv", effect: "Hug", preview: "https://vewapnew.online/storage/preview/OnM8aZri3yFsoWzEeNgzVq93hxlqZ5JVaLGRQL5K.mp4?t=1738906171", previewSmall: "Hug"),
//            Effect(id: 60, ai: "pv", effect: "Kiss", preview: "https://vewapnew.online/storage/preview/OJym7Q5JqaY6yCWjlnXkP1rVZneSKjWLGQPBvuXF.mp4?t=1738906171", previewSmall: "Kiss")
//        ]),
//        SortedEffects(header: "Transformation", items: [
//            Effect(id: 14, ai: "pv", effect: "We Are Venom!", preview: "https://vewapnew.online/storage/preview/cunxLyVIeC8YWxXyPUcFyNBw3tXeiOhp9sDkYBoP.mp4?t=1738906171", previewSmall: "WeAreVenom"),
//            Effect(id: 16, ai: "pv", effect: "Hulk", preview: "https://vewapnew.online/storage/preview/Zz7OEaSxEUmZXvkyk7lUaAm7uggkzV1qsQXNgqHR.mp4?t=1738906171", previewSmall: "Hulk"),
//            Effect(id: 19, ai: "pv", effect: "Crazy Cat Woman", preview: "https://vewapnew.online/storage/preview/N6HWDRZS9VCHWO2SgRxoU1PohVefoqC07Az8WOVn.mp4?t=1738906171", previewSmall: "CrazyCatWoman"),
//            Effect(id: 25, ai: "pv", effect: "Hot Harley Quinn", preview: "https://vewapnew.online/storage/preview/OqAvMjrusu6YpfoI4S1PEIUpiGxWFkxUd0lKgCvs.mp4?t=1738906171", previewSmall: "HotHarleyQuinn"),
//            Effect(id: 27, ai: "pv", effect: "Joker's Rebirth", preview: "https://vewapnew.online/storage/preview/lLGZVlvL6XDZZ0FTxAqd4scTdp1e2TKB5fENAPx1.mp4?t=1738906171", previewSmall: "JokersRebirth"),
//            Effect(id: 30, ai: "pv", effect: "Batman", preview: "https://vewapnew.online/storage/preview/Jg33qu2ditkQJXBboZclppGVSVYFhVMPHoJyFRiZ.mp4?t=1738906171", previewSmall: "Batman"),
//            Effect(id: 32, ai: "pv", effect: "COLORFUL Venom!", preview: "https://vewapnew.online/storage/preview/5kpelkXz9wD4nbpyZVATrh7H3sek1VQ9frMBK9aq.mp4?t=1738906171", previewSmall: "ColorfulVenom"),
//            Effect(id: 36, ai: "pv", effect: "Get a Venom buddy", preview: "https://vewapnew.online/storage/preview/nG6PLWIOx9h9HbHK7iN0ZH37i2uMvh8ED4b6CUoF.mp4?t=1738906171", previewSmall: "GetAVenomBuddy"),
//            Effect(id: 37, ai: "pv", effect: "Iron Man", preview: "https://vewapnew.online/storage/preview/AF8gABpzk6Dd1GLNBCi8xpAxZL4q6QX1ZMFYcST8.mp4?t=1738906171", previewSmall: "IronMan"),
//            Effect(id: 39, ai: "pv", effect: "Who is Venom?", preview: "https://vewapnew.online/storage/preview/1e1YlD9xKZSQltoeiUa8XL2RpwxhTXMyyw86HxAs.mp4?t=1738906171", previewSmall: "WhoIsVenom"),
//            Effect(id: 58, ai: "pv", effect: "Wonder Woman", preview: "https://vewapnew.online/storage/preview/iBuljgRDxcLxNNLvmwn5nhyDLk7xmbRjBdAuzC8c.mp4?t=1738906171", previewSmall: "WonderWoman")
//        ]),
//        SortedEffects(header: "Funny", items: [
//            Effect(id: 2, ai: "pv", effect: "Decapitate it", preview: "https://vewapnew.online/storage/preview/QolvHeHOCxB3naJbijWEDUJmNPrifsUlVqNvGLxv.mp4?t=1738906171", previewSmall: "DecapitateIt"),
//            Effect(id: 3, ai: "pv", effect: "Eye-pop it", preview: "https://vewapnew.online/storage/preview/vWy7H3nQovCQPfVMsN00SaZzDJjZDNqGUJgyiqTA.mp4?t=1738906171", previewSmall: "EyePopIt"),
//            Effect(id: 24, ai: "pv", effect: "Hair Growth Magic", preview: "https://vewapnew.online/storage/preview/LS98dH8wJ8wZA0eoxIXzDPZrOZl0g08YA6jEroyK.mp4?t=1738906171", previewSmall: "HairGrowthMagic"),
//            Effect(id: 52, ai: "pv", effect: "Wizard Hat", preview: "https://vewapnew.online/storage/preview/rWY5OnsMzGyU3GV4HClILxbRh3ucdnuveDP6VRU5.mp4?t=1738906171", previewSmall: "WizardHat"),
//            Effect(id: 55, ai: "pv", effect: "Poke it", preview: "https://vewapnew.online/storage/preview/Rk5i55bQqimTh0YaFeeLAVTpI0nhA3J64U3QjrgE.mp4?t=1738906171", previewSmall: "PokeIt"),
//            Effect(id: 57, ai: "pv", effect: "Sheep Curls", preview: "https://vewapnew.online/storage/preview/AdYtaS4f73lyV9uajK3HubUV5wdoDDzy4gWQ0abD.mp4?t=1738906171", previewSmall: "SheepCurls")
//        ])
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
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            let itemSize = self.returnItemSizeItem(indexSection: sectionIndex)
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(itemSize.widthDimension.dimension),  heightDimension: .absolute(itemSize.heightDimension.dimension))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            //group.interItemSpacing = .fixed(CGFloat(8))
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(28))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            return section
        }
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.dataSource = self
        collection.delegate = self
        collection.showsVerticalScrollIndicator = false
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "main")
        collection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collection.backgroundColor = .clear
        return collection
    }()
    
    private func returnItemSizeItem(indexSection: Int) -> NSCollectionLayoutSize {
        switch indexSection {
        case 0:
            return NSCollectionLayoutSize(widthDimension: .absolute(175), heightDimension: .absolute(248))
        default:
            return NSCollectionLayoutSize(widthDimension: .absolute(175), heightDimension: .absolute(248))
        }
    }
    
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
        someMethod()
        collectionView.reloadData()
        subscribe()
//        DispatchQueue.main.async {
//            self.model.load()
//        }
    }
    
    private func subscribe() {
        model.arrChangedPublisher
            .sink { _ in
                self.sortedArr = self.model.arr
            }
            .store(in: &cancellable)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkInternetAvailable()
    }
    
    private func someMethod() {
        Task {
            await loadData()
        }
    }
    
    private func loadData() async {
//        while model.arr.count < 1 {
//            await Task.sleep(500_000_000)
//        }
        searchBar.isUserInteractionEnabled = true
        sortedArr = model.arr
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
//        view.addSubview(searchBar)
//        searchBar.delegate = self
//        searchBar.snp.makeConstraints { make in
//            make.left.right.equalToSuperview().inset(16)
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
//        }
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
           // make.top.equalTo(searchBar.snp.bottom).inset(-16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
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
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        
        return section
    }
    
    @objc private func pikaTapped() {
        self.selectedType = .pika
       // let arr = model.returnArr(type: .pika)
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
            let vc = PreviewV2ViewController(model: model, effect: item)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func categoryButtonPressed(sender: MyButton) {
        guard model.connectionAvailable else { return }
        guard isInternetAvailable() else { return }
        if let item = sender.category {
            print(item)
            let vc = CategoryPreviewViewController(model: model, category: item)
            self.navigationController?.pushViewController(vc, animated: true)
        }
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

extension EffectsViewControllerV2: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print(sortedArr.count)
        return sortedArr.count // Горизонтальная, статическое вью, вертикальные ячейки
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(sortedArr[section].items.count)
        return sortedArr[section].items.count //1
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
    
    private func noConnectionAlert() {
        let alert = UIAlertController(title: "Error", message: "No internet connection", preferredStyle: .alert)
        
        let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { [weak self] _  in
            self?.checkInternetAvailable()
        }
        alert.addAction(tryAgainAction)
        
        self.present(alert, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "main", for: indexPath)
//        cell.subviews.forEach { $0.removeFromSuperview() }
//        cell.clipsToBounds = true
//        cell.layer.cornerRadius = 16
//        
//        let item = sortedArr[0].items[indexPath.row]
//        let videoPlayer = VideoPlayerView()
//        videoPlayer.isUserInteractionEnabled = true
//        //if let url = URL(string: item.previewSmall ?? "") {
//        if let url = Bundle.main.url(forResource: item.previewSmall ?? "", withExtension: "mp4") {
//            videoPlayer.play(for: url)
//            videoPlayer.volume = 0.0
//        }
//        videoPlayer.clipsToBounds = true
//        videoPlayer.layer.cornerRadius = 16
//        videoPlayer.contentMode = .scaleAspectFill
//        cell.addSubview(videoPlayer)
//        videoPlayer.snp.makeConstraints { make in
//            make.left.right.top.equalToSuperview()//.inset(10)
//            make.height.equalTo(204)
//        }
//        
//        let nameLabel = UILabel()
//        nameLabel.text = item.effect
//        nameLabel.textColor = .white
//        nameLabel.font = .appFont(.FootnoteEmphasized)
//        cell.addSubview(nameLabel)
//        nameLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview()//.inset(12)
//        }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "main", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .clear
        cell.clipsToBounds = true
        
        let item = sortedArr[indexPath.section].items[indexPath.row]
        let nameLabel = UILabel()
        nameLabel.text = item.effect
        nameLabel.textColor = .white
        nameLabel.font = .appFont(.FootnoteRegular)
        
        
//            let tryButton = UIButton(type: .system)
//            tryButton.tag = item.id
//            tryButton.setBackgroundImage(.tryItButton, for: .normal)
//            cell.addSubview(tryButton)
//            tryButton.snp.makeConstraints { make in
//                make.right.equalToSuperview().inset(15)
//                make.height.equalTo(24)
//                make.width.equalTo(63)
//                make.top.equalToSuperview().inset(15)
//            }
//            tryButton.addTarget(self, action: #selector(tryTapped(sender:)), for: .touchUpInside)
        
        let bgView = UIView()
        bgView.backgroundColor = .clear
        bgView.layer.cornerRadius = 8
        bgView.clipsToBounds = true
        cell.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()//.inset(15)
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
        
        cell.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        let player = VideoPlayerView()
        player.layer.cornerRadius = 8
        player.clipsToBounds = true
        player.playerLayer.videoGravity = .resizeAspectFill
        player.addGestureRecognizer(tap)
        cell.addSubview(player)
        player.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).inset(-8)
            make.height.equalTo(220)
        }
        

        if let localUrl = item.localUrl, let url = URL(string: localUrl) {
            print("LOCAL URL ")
            player.play(for: url)
            player.isMuted = true
        } else {
            print("Remote URL ")
            if let urlStr = item.previewSmall, let url = URL(string: urlStr) {
                player.play(for: url)
                player.isMuted = true
            }
        }
//        
//        if let urlStr = item.previewSmall, let url = URL(string: urlStr) {
//            player.play(for: url)
//            player.isMuted = true
//        }
//        
//        if let url = Bundle.main.url(forResource: item.previewSmall ?? "", withExtension: "mp4") {
//            player.play(for: url)
//            player.isMuted = true
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        if indexPath.section == 1 && model.favoriteArrID.count > 0 {
            //likeTapped(id: model.favoriteArrID[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "HeaderView",
                for: indexPath
            )
            
            headerView.subviews.forEach { $0.removeFromSuperview() }
            
            let label = UILabel()
            label.textColor = .white
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            headerView.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview()
            }
            
            let tryButton = MyButton()
            tryButton.setTitle("See all", for: .normal)
            tryButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
            tryButton.setTitleColor(.secondary, for: .normal)
            headerView.addSubview(tryButton)
            tryButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview()
            }
            tryButton.category = sortedArr[indexPath.section]
            tryButton.addTarget(self, action: #selector(categoryButtonPressed(sender:)), for: .touchUpInside)
            
            label.text = sortedArr[indexPath.section].header
//
//            if indexPath.section == 0 {
//                
//            }
//            if indexPath.section == 1 {
//                label.text = "Hug and Kiss"
//            }
//            if indexPath.section == 2 {
//                label.text = "Transformation"
//            }
//            if indexPath.section == 3 {
//                label.text = "Funny"
//            }
            //Funny
            //Popular
            
            return headerView
        }
        return UICollectionReusableView()
    }
}


extension EffectsViewControllerV2: UISearchBarDelegate {
    
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
           if searchText.isEmpty {
               sortedArr = model.arr
           } else {
               var cats: Array<SortedEffects> = []

               model.arr.forEach { category in
                   var effects: Array<Effect> = []
                   category.items.forEach { effect in
                       if effect.effect.lowercased().contains(searchText.lowercased()) {
                           effects.append(effect)
                       }
                   }
                   if !effects.isEmpty {
                       cats.append(SortedEffects(header: category.header, items: effects))
                   }
               }
               sortedArr = cats
                   
//                   .filter { effect in
//                   effect.effect.lowercased().contains(searchText.lowercased())
//               }
           }
        collectionView.reloadData()
    }
}

class MyButton: UIButton {
    var category: SortedEffects?
}
