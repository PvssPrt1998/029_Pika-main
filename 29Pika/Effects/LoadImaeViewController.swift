//
//  GenerateViewController.swift
//  29Pika
//
//  Created by Владимир Кацап on 24.12.2024.
//

import UIKit

class LoadImaeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let effect: Effect
    let model: MainModel
    
    private let doubleImageId = [59, 60]
    private lazy var isTwo = returnCountImages()
    private lazy var generationID = ""
    
    enum ImageType {
        case main
        case one
        case two
    }
    private var selectedImageType: ImageType?
    
    
    private lazy var oneImageView = createImageView(image: .image1)
    private lazy var twoImageView = createImageView(image: .image2)
    private lazy var mainImageView = createImageView(image: .main)
    
    private let generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(" Generate", for: .normal)
        button.layer.cornerRadius = 10
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .appFont(.Title2Emphasized)
        button.setImage(.magic.withRenderingMode(.alwaysOriginal).resize(targetSize: CGSize(width: 32, height: 32)), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .secondary
        button.isUserInteractionEnabled = false
        button.alpha = 0.6
        return button
    }()
    
    init(effect: Effect, model: MainModel) {
        self.effect = effect
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgMain
        setupUI()
    }
    
    
    private func setupNav() {
        self.title = effect.effect
    }
    
    private func setupUI() {
        view.addSubview(generateButton)
        generateButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(64)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        generateButton.addTarget(self, action: #selector(goGenerate), for: .touchUpInside)
        
        
        if isTwo {
            view.addSubview(oneImageView)
            oneImageView.snp.makeConstraints { make in
                make.height.equalTo(300)
                make.left.equalToSuperview().inset(15)
                make.centerY.equalToSuperview()
                make.right.equalTo(view.snp.centerX).offset(-5)
            }
            let onegesture = UITapGestureRecognizer(target: self, action: #selector(setOneImage))
            oneImageView.addGestureRecognizer(onegesture)
            
            view.addSubview(twoImageView)
            twoImageView.snp.makeConstraints { make in
                make.height.equalTo(300)
                make.right.equalToSuperview().inset(15)
                make.centerY.equalToSuperview()
                make.left.equalTo(view.snp.centerX).offset(5)
            }
            let twogesture = UITapGestureRecognizer(target: self, action: #selector(setTwoImage))
            twoImageView.addGestureRecognizer(twogesture)
        } else {
            view.addSubview(mainImageView)
            mainImageView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
                make.bottom.equalTo(generateButton.snp.top).inset(-15)
            }
            let maingesture = UITapGestureRecognizer(target: self, action: #selector(setMainImage))
            mainImageView.addGestureRecognizer(maingesture)
        }
        
    }
    
    
    private func returnCountImages() -> Bool {
        if doubleImageId.contains(where: {$0 == effect.id}) {
            return true
        } else {
            return false
        }
    }
    
    private func createImageView(image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        imageView.layer.borderWidth = 1
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    @objc private func setMainImage() {
        selectedImageType = .main
        openGallery()
    }
    
    @objc private func setOneImage() {
        selectedImageType = .one
        openGallery()
    }
    
    @objc private func setTwoImage() {
        selectedImageType = .two
        openGallery()
    }
    
    private func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            switch selectedImageType {
            case .main:
                mainImageView.image = selectedImage
            case .one:
                oneImageView.image = selectedImage
            case .two:
                twoImageView.image = selectedImage
            case .none:
                break
            }
        }
        checkButton()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func checkButton() {
        if isTwo {
            if oneImageView.image != .image1 && twoImageView.image != .image2 {
                onButton()
            }
        } else {
            if mainImageView.image != .main {
                onButton()
            }
        }
    }
    
    private func onButton() {
        generateButton.isUserInteractionEnabled = true
        generateButton.alpha = 1
    }
    
    @objc private func goGenerate() {
        var image: UIImage = UIImage()
        
        if isTwo {
            let oneImage: UIImage = oneImageView.image ?? UIImage()
            let twoImage: UIImage = twoImageView.image ?? UIImage()
            image = combineImagesWithBlur(oneImage, twoImage) ?? UIImage()
        } else {
            let imageMain: UIImage = mainImageView.image ?? UIImage()
            image = resizeImageIfNeeded(image: imageMain, maxWidth: 1260, maxHeight: 760)
        }
        
        self.openGenerate(image: image)
    }
    
    private func openGenerate(image: UIImage) {
        let vc = GenerateViewController(model: model, imageBlur: image, effect: effect)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @objc private func close() {
        self.dismiss(animated: true)
    }
    
    func resizeImageIfNeeded(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height
    
        let widthRatio = maxWidth / originalWidth
        let heightRatio = maxHeight / originalHeight
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: originalWidth * scaleFactor, height: originalHeight * scaleFactor)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    func combineImagesWithBlur(_ leftImage: UIImage, _ rightImage: UIImage) -> UIImage? {
        // Определяем максимальную высоту
        let maxHeight = max(leftImage.size.height, rightImage.size.height)
        
        // Масштабируем обе картинки, чтобы их высота совпадала с maxHeight
        let leftScale = maxHeight / leftImage.size.height
        let rightScale = maxHeight / rightImage.size.height
        
        let scaledLeftWidth = leftImage.size.width * leftScale
        let scaledRightWidth = rightImage.size.width * rightScale
        
        // Общая ширина
        let totalWidth = scaledLeftWidth + scaledRightWidth
        
        // Создаем контекст с нужными размерами
        UIGraphicsBeginImageContextWithOptions(CGSize(width: totalWidth, height: maxHeight), false, 0.0)
        
        // Масштабируем и рисуем левое изображение
        let leftRect = CGRect(x: 0, y: 0, width: scaledLeftWidth, height: maxHeight)
        leftImage.draw(in: leftRect)
        
        // Масштабируем и рисуем правое изображение
        let rightRect = CGRect(x: scaledLeftWidth, y: 0, width: scaledRightWidth, height: maxHeight)
        rightImage.draw(in: rightRect)
        
        // Создаем градиент на стыке изображений
        let gradientWidth: CGFloat = 20.0 // Ширина размытия
        let gradientStartX = scaledLeftWidth - gradientWidth / 2
        let gradientEndX = scaledLeftWidth + gradientWidth / 2
        
        if let context = UIGraphicsGetCurrentContext() {
            let colors = [
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(0.5).cgColor,
                UIColor.clear.cgColor
            ]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 0.5, 1.0])!
            
            let gradientRect = CGRect(x: gradientStartX, y: 0, width: gradientWidth, height: maxHeight)
            context.saveGState()
            context.clip(to: gradientRect)
            
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: gradientStartX, y: 0),
                end: CGPoint(x: gradientEndX, y: 0),
                options: []
            )
            context.restoreGState()
        }
        
        // Получаем результирующее изображение
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return combinedImage
    }
    
}
