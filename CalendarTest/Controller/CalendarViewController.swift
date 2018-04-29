
import UIKit

class CalendarViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var calendarCollectionView: UICollectionView!
    var delegate: CalendarDelegate?
    
    var date = Date()   // 전달인자
    var year = Int()
    var month = Int()
    var weekday = Int()
    var day = Int()
    var firstDayPosition = Int()
    var numberOfCells = Int()
    var firstDayIndexPath = IndexPath()
    var preIndexPath = IndexPath()
    var strYearMonth = String()
    
    var monthlyItemArray = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setPosition(date)
//        print(dataFilePath)
        
    }

    func setPosition(_ date: Date) {
        year = calendar.component(.year, from: date)
        month = calendar.component(.month, from: date)
        weekday = calendar.component(.weekday , from: date)
        day = calendar.component(.day, from: date)
        strYearMonth = "\(year)\(makeTwoDigitString(month))"
        loadItems(strYearMonth)
        print("\(year) \(month)")
        
        if month == 2 {
            daysInMonths[2] = (year%4 == 0 && year%100 != 0 || year%400 == 0) ? 29 : 28
        }
        let weekdayCounter = day % 7
        firstDayPosition = weekday - weekdayCounter
        firstDayPosition = firstDayPosition == 7 ? 0 : firstDayPosition
        firstDayPosition += firstDayPosition < 0 ? 7 : 0
        
        numberOfCells = firstDayPosition + daysInMonths[month]
    }
    
    func loadItems(_ strYearMonth: String) {
//        monthlyItemArray.removeAll()
        if let data = try? Data(contentsOf: (dataFilePath?.appendingPathComponent("\(strYearMonth).plist"))!) {
            let decoder = PropertyListDecoder()
            do {monthlyItemArray = try decoder.decode([Item].self, from: data)
            } catch {print("Error decoding item array, \(error)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell

        let dayCounter = indexPath.row + 1 - firstDayPosition
        
        cell.dayLabel.text = "\(dayCounter)"
        
        if dayCounter < 1 {
            cell.isHidden = true
        }
        
        if dayCounter == 1 {
            firstDayIndexPath = indexPath
        }
        
        if (year == toYear && month == toMonth && dayCounter == toDay) {
            firstDayIndexPath = indexPath
        }
        
        if dayCounter == day {
            cell.backgroundColor = UIColor.lightGray
            preIndexPath = indexPath
        }
        
        cell.unitOfWorkLabel.layer.cornerRadius = 9
        cell.unitOfWorkLabel.layer.masksToBounds = true
        
        // 화면에 데이터 뿌려주기
        if indexPath.row >= firstDayPosition {

            let itemArrayIndex = indexPath.row - firstDayPosition

            if monthlyItemArray.isEmpty {  // itemArray 가 비어 있을 경우
                cell.unitOfWorkLabel.isHidden = true
                cell.memoLabel.isHidden = true
            } else {    // itemArray에 값이 있고
                if monthlyItemArray[itemArrayIndex].strUnitOfWork == "" ||
                    monthlyItemArray[itemArrayIndex].strUnitOfWork == "0" {  // 공수가 비었을경우
                    cell.unitOfWorkLabel.isHidden = true
                } else {    // 공수에 값이 있을경우
                    cell.unitOfWorkLabel.isHidden = false
                    cell.unitOfWorkLabel.text = monthlyItemArray[itemArrayIndex].strUnitOfWork
                }
                if monthlyItemArray[itemArrayIndex].memo == "" {   // 메모가 비었을 경우
                    cell.memoLabel.isHidden = true
                } else {    //  메모값이 있을경우
                    cell.memoLabel.isHidden = false
                    cell.memoLabel.text = monthlyItemArray[itemArrayIndex].memo
                }
            }

//            cell.unitOfWorkLabel.text = monthlyItemArray.isEmpty ? "" : monthlyItemArray[indexPath.row - firstDayPosition].strUnitOfWork

//            cell.memoLabel.text = monthlyItemArray.isEmpty ? "" : monthlyItemArray[indexPath.row - firstDayPosition].memo

//            monthlyGongsu += itemArray.isEmpty ? 0 : itemArray[indexPath.row - firstDayPosition].numUnitOfWork

            if (indexPath.row + 1) == (daysInMonths[month] + firstDayPosition) {
//              monthlyGongsuLabel.text = String(monthlyGongsu)
            }
            
            // 주말 날짜색 설정
            switch indexPath.row {
            case 0,7,14,21,28,35,42:
                if Int(cell.dayLabel.text!)! > 0 {
                    cell.dayLabel.textColor = UIColor.red
                }
            case 6,13,20,27,34,41:
                if Int(cell.dayLabel.text!)! > 0 {
                    cell.dayLabel.textColor = UIColor.blue
                }
            default:
                break
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayCounter = indexPath.row + 1 - firstDayPosition
//        print("\(year)년 \(month)월 \(dayCounter)일 이 선택 됨")
//        day = dayCounter
        delegate?.selectYearMonthDay(year: year, month: month, day: dayCounter)
        collectionView.cellForItem(at: preIndexPath)?.backgroundColor = UIColor.clear
        collectionView.cellForItem(at: firstDayIndexPath)?.backgroundColor = UIColor.clear
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.lightGray
        preIndexPath = indexPath
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






