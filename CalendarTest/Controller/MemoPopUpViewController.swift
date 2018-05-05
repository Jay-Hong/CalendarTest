
import UIKit

class MemoPopUpViewController: UIViewController {

    @IBOutlet weak var memoBackView: UIView!
    @IBOutlet weak var memoTextView: UITextView!
    
    var delegate: PopupDelegate?
    var memo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextView.text = memo
        

    }
    @IBAction func backgroundButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveMemoButtonAction(_ sender: Any) {
        delegate?.saveMemo(memo: memoTextView.text)
        dismiss(animated: true, completion: nil)
    }
}

