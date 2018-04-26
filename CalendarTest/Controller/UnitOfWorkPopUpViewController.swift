
import UIKit

class UnitOfWorkPopUpViewController: UIViewController {

    @IBOutlet weak var displayNumberLabel: UILabel!
    
    var strNumber = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func numberDisplay() {
        displayNumberLabel.text = strNumber
    }
    
    func accumulator(digit: String) {
        strNumber += (strNumber.count < 5) ? digit : ""
    }
    
    @IBAction func numberButtonAction(_ sender: UIButton) {
        if strNumber.hasPrefix("0") {
            if !strNumber.hasPrefix("0.") {
                strNumber.removeFirst()
            }
        }
        accumulator(digit: sender.currentTitle!)
        numberDisplay()
    }
    
    @IBAction func dotButtonAction(_ sender: UIButton) {
        
        if strNumber.isEmpty{
            strNumber += "0."
        }
        if !strNumber.contains(".") {
            strNumber += "."
        }
        numberDisplay()
        
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        if !strNumber.isEmpty {
            strNumber.removeLast()
        }
        numberDisplay()
    }
    
    
    @IBAction func saveMemoButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backgroundButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
