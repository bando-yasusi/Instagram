import UIKit
import FirebaseStorageUI
import FirebaseFirestore
import FirebaseAuth

class PostTableViewCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var komento: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var postData: PostData!
    // データをセット
    func setPostData(_ postData: PostData) {
        self.postData = postData
        //課題デリゲートセット
        komento.delegate = self
        komento.isEditable = true
        komento.isSelectable = true
        komento.isUserInteractionEnabled = true
        
        // 画像の表示
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)
        
        // キャプションの表示
        self.captionLabel.text = "\(postData.name) : \(postData.caption)"
        
        // 日時の表示
        self.dateLabel.text = postData.date
        
        // いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        
        // 課題ユーザー名を表示
        nameLabel.text = postData.name
        
        // 課題コメントリストを表示
        let commentLines = zip(postData.nameLabel, postData.komento).map { "\($0): \($1)" }
        komento.text = commentLines.joined(separator: "\n")
        
        // 編集が終わったときに呼ばれる
        func textViewDidEndEditing(_ textView: UITextView) {
            let newComment = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !newComment.isEmpty {
                updateComment(newComment: newComment)
            }
        }
        
        // Firestore にコメントを追加
        func updateComment(newComment: String) {
            let postId = postData.id
            let postRef = Firestore.firestore().collection("posts").document(postId)
            let currentUserName = Auth.auth().currentUser?.displayName ?? "名無し"
            postRef.updateData([
                "komento": FieldValue.arrayUnion([newComment]),
                "nameLabel": FieldValue.arrayUnion([currentUserName])
            ]) { error in
                if let error = error {
                    print("コメント追加に失敗: \(error)")
                } else {
                    print("コメント追加成功 🎉")
                }
            }
        }
    }
}
    
