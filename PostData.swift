import UIKit
import FirebaseAuth
import FirebaseFirestore

class PostData: NSObject {
    var id = ""
    var name = ""
    var caption = ""
    var date = ""
    var likes: [String] = []
    var isLiked: Bool = false
    //課題コメント追加
    var komento: [String] = []
    //課題コメント入力者名追加
    var nameLabel: [String] = []
    

    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID

        let postDic = document.data()

        if let name = postDic["name"] as? String {
            self.name = name
        }

        if let caption = postDic["caption"] as? String {
            self.caption = caption
        }

        if let timestamp = postDic["date"] as? Timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            self.date = formatter.string(from: timestamp.dateValue())
        }

        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }

        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }
        //課題Firestoreからkomentoを配列で取得
        if let komentoArray = postDic["komento"] as? [String] {
                    self.komento = komentoArray
                }
        //課題FirestoreからnameLabelを配列で取得
        if let nameLabelArray = postDic["nameLabel"] as? [String] {
                    self.nameLabel = nameLabelArray
                }
    }

    // 課題　新規投稿用
        init(name: String, caption: String) {
            self.name = name
            self.caption = caption
            self.komento = []      // 空配列で初期化
            self.nameLabel = []    // 空配列で初期化
        }

    // 課題コメント追加メソッド
        func addComment(comment: String, by userName: String) {
            komento.append(comment)
            nameLabel.append(userName)
        }
    override var description: String {
        return "PostData: name=\(name); caption=\(caption); date=\(date); likes=\(likes.count); id=\(id);"
    }
}

