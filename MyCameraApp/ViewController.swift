//
//  ViewController.swift
//  MyCameraApp
//
//  Created by Yoichi Watanabe on 2018/05/15.
//  Copyright © 2018年 Yoichi Watanabe. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var ShareButton: UIBarButtonItem!
    
    @IBAction func didTouchShareButton(_ sender: Any) {
        print("シェアボタンをタッチしました")
        
        // 撮影した画像の取得
        guard let image = imageView.image else {
            print("撮影した写真が設定されていません。")
            return
        }
        
        // シェア用に画像を画面表示サイズに変換
        let resizedImage = image.resizedImage(size: imageView.frame.size)

        // Twitterハッシュタグ
        let shareText = "#MyCameraApp"
        // UIActivity に渡す項目
        let activityItems: [Any] = [shareText, resizedImage]
        
        // UIActivityViewControllerのインスタンスを作成
        let activityController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // iPadでの表示を考慮
        activityController.popoverPresentationController?
            .sourceView = imageView
        
        // UIActivity をモーダル表示
        self.present(activityController, animated: true)
    }
    
    @IBOutlet weak var CameraButton: UIBarButtonItem!
    
    @IBAction func didTouchCameraButton(_ sender: Any) {
        print("カメラボタンをタッチしました")
        
        // カメラが使えるか判定
        guard UIImagePickerController
            .isSourceTypeAvailable(.camera) else {
            print("カメラへのアクセスができません")
            return
        }
        
        // UIImagePickerController のインスタンスを作成
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        // UIImagePickerControllerSourceType.cameraを設定
        pickerController.sourceType = .camera
        
        // モーダル表示
        self.present(pickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 撮影画像の取得
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // 画像の向きを修正
            let fixedImage = image.correctlyOrientedImage()
            
            // 画像フィルタ処理を行う
            let filteredImage = doFilter(image: fixedImage, filterName: "CIPhotoEffectMono")
            
            // 加工した画像を表示・保存
            imageView.image = filteredImage
            UIImageWriteToSavedPhotosAlbum(filteredImage, nil, nil, nil)
        }
        
        // モーダルを閉じる
        picker.dismiss(animated: true)
    }
    
    @IBAction func didTouchMakeNotificationButton(_ sender: Any) {
        print("通知登録ボタンをタッチしました")
    }
    
    @IBAction func didTouchClearNotificationButton(_ sender: Any) {
        print("通知解除ボタンをタッチしました")
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        // 処理なし
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        // 処理なし
    }
    
    func doFilter(image: UIImage, filterName: String) -> UIImage {
        // CIImageを作成
        let ciImage = CIImage(image: image)
        
        // CIFilterクラスのインスタンスを生成し、CIImageを渡す
        let filter = CIFilter(name: filterName)!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        // CIContextクラスを用いて画像を加工
        let ciContext = CIContext(options: nil)
        let filteredImage = filter.outputImage!
        let imageRef = ciContext.createCGImage(filteredImage,
                                               from: filteredImage.extent)
        
        // CIImageからUIImageへ変換
        let outputImage = UIImage(cgImage: imageRef!,
                                  scale: image.scale,
                                  orientation: image.imageOrientation)

        return outputImage
    }
}

extension UIImage {
    // 画像サイズ変換処理
    func resizedImage(size _size: CGSize) -> UIImage {
        // アスペクト比を考慮し、変更後のサイズを計算する
        let wRatio = _size.width / size.width
        let hRatio = _size.height / size.height
        let ratio = wRatio < hRatio ? wRatio : hRatio
        
        let resized = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )
        
        // サイズ変更
        UIGraphicsBeginImageContextWithOptions(resized, false, self.scale)
        draw(in: CGRect(origin: .zero, size: resized))
        let resizedImage =
            UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}

extension UIImage {
    // 画像オリエンテーション修正処理
    func correctlyOrientedImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

