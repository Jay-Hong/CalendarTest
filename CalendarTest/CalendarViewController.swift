
import UIKit

class CalendarViewController: UIViewController, UICollectionViewDataSource {
    
//    var daysInMonths = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
//    var delegate: CalendarDelegate?
    
    // 전달인자
    var date = Date()
    
    var year = Int()
    var month = Int()
    var weekday = Int()
    var day = Int()
    var firstDayPosition = Int()
    var numberOfCells = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setPosition(date)
        
    }
    
    func setPosition(_ date: Date) {
        year = calendar.component(.year, from: date)
        month = calendar.component(.month, from: date)
        weekday = calendar.component(.weekday , from: date)
        day = calendar.component(.day, from: date)
        print("\(year) \(month)")
        
        if month == 2 {
            daysInMonths[2] = (year%4 == 0 && year%100 != 0 || year%400 == 0) ? 29 : 28
        }
        
        let dayCounter = day % 7
        firstDayPosition = weekday - dayCounter
        firstDayPosition = firstDayPosition == 7 ? 0 : firstDayPosition
        firstDayPosition += firstDayPosition < 0 ? 7 : 0
        
        numberOfCells = firstDayPosition + daysInMonths[month]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell

        cell.dayLabel.text = "\(indexPath.row + 1 - firstDayPosition)"
        
        if Int(cell.dayLabel.text!)! < 1 {
            cell.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(year)년 \(month)월 \(indexPath.row + 1 - firstDayPosition)Cell is selected")
//        delegate?.calendarYearMonth(value: "\(year)년 \(month)월")
    }
    
}



extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        let height = collectionView.frame.height / 6
        return CGSize(width: width, height: height)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
    
}






