import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    // Firestoreのリスナー
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
            // listenerを登録して投稿データの更新を監視する
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
            listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.postArray = querySnapshot!.documents.map { document in
                    let postData = PostData(document: document)
                    print("DEBUG_PRINT: \(postData)")
                    return postData
                }
                // TableViewの表示を更新する
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        listener?.remove()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleLikeButton(_:)), for: .touchUpInside)
        // 課題コメントボタンのアクション
        cell.commentButton.addTarget(self, action: #selector(handleCommentButton(_:)), for: .touchUpInside)
        
        
        
        return cell
    }
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleLikeButton(_ sender: UIButton) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let point = sender.convert(CGPoint.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    //課題ボタンが押されたらコメント入力画面を出す
    @objc func handleCommentButton(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        let postData = postArray[indexPath.row]
        
        let alert = UIAlertController(title: "コメントを入力", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "コメントを入力してください"
        }
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "投稿", style: .default, handler: { _ in
            guard let comment = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !comment.isEmpty else {
                print("空のコメントは投稿されません")
                return
            }
            
            // 名前とコメントをセットにした文字列を作る
            let currentUserName = Auth.auth().currentUser?.displayName ?? "名無し"
            let displayComment = "\(currentUserName): \(comment)"
            
            // Firestore に保存
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData([
                "komento": FieldValue.arrayUnion([displayComment])
            ]) { error in
                if let error = error {
                    print("コメントの保存に失敗: \(error)")
                } else {
                    print("コメントの保存に成功")
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
