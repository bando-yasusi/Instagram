import UIKit
import ZLImageEditor

class ImageSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handleLibraryButton(_ sender: Any) {
        // ライブラリ（カメラロール）を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func handleCameraButton(_ sender: Any) {
        // カメラを指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
        // 画像加工処理
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage
            // ZLImageEditorライブラリで画像を加工する
            print("DEBUG_PRINT: image = \(image)")
            // ZLImageEditorで使用する画像加工ツールをセットする
            ZLImageEditorConfiguration.default()
                .editImageTools([.draw, .clip, .textSticker, .mosaic, .filter, .adjust])
                .adjustTools([.brightness, .contrast, .saturation])
            // ZLImageEditorの画像加工画面に遷移する
            ZLEditImageViewController.showEditImageVC(parentVC: self, image: image) { image, _ in
                // ZLImageEditorで加工された画像を投稿画面に渡して画面遷移する
                let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
                postViewController.image = image
                self.present(postViewController, animated: true, completion: nil)
            }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
}

