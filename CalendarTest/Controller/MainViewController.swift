import UIKit

class MainViewController: UIViewController, UIPageViewControllerDataSource{
    
    @IBOutlet weak var mainYearMonthButton: UIButton!
    @IBOutlet weak var pageCalendarView: UIView!
    @IBOutlet weak var memoLabel: UILabel!
    
    var pageVC = UIPageViewController()
    
    var selectedYear = Int()
    var selectedMonth = Int()
    var selectedDay = Int()
    var strYearMonth = String()
    var itemArray = [Item]()
    
    var memoTemp = ""
    var unitOfWorkTemp = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeFirstMainScreen()
//        print(dataFilePath)
        
    }
    
    func makeFirstMainScreen() {
        pageVC = self.storyboard?.instantiateViewController(withIdentifier: "pageViewController") as! UIPageViewController
        pageVC.view.frame = pageCalendarView.bounds
        addChildViewController(pageVC)
        pageCalendarView.addSubview(pageVC.view)
        pageVC.didMove(toParentViewController: self)
        pageVC.dataSource = self
        
        // 첫 pageViewController 화면 출력하기
        let firstViewController = createCalendarViewController(today)
        pageVC.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        
        mainYearMonthButton.setTitle("\(toYear)년 \(toMonth)월", for: .normal)
        selectYearMonthDay(year: toYear, month: toMonth, day: toDay)
        strYearMonth = "\(toYear)\(makeTwoDigitString(toMonth))"
//        print("선택된날짜 : \(toYear)년 \(toMonth)월 \(toDay)일")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toYearMonthPopUpViewControllerSegue" {
            let popup = segue.destination as! YearMonthPopUpViewController
            popup.delegate = self
        } else if segue.identifier == "toUnitOfWorkPopUpViewControllerSegue" {
            let popup = segue.destination as! UnitOfWorkPopUpViewController
            popup.delegate = self
            popup.strNumber = unitOfWorkTemp
        } else if segue.identifier == "toMemoPopUpViewControllerSegue" {
            let popup = segue.destination as! MemoPopUpViewController
            popup.delegate = self
            popup.memo = memoTemp
        }
    }
    
    func createCalendarViewController(_ date: Date) -> CalendarViewController {
        let calendarVC = self.storyboard?.instantiateViewController(withIdentifier: "CanlendarViewController") as! CalendarViewController
        calendarVC.date = date
        calendarVC.delegate = self
        return calendarVC
    }
    
    func createDate (_ year: Int, _ month: Int, _ day: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = 12
        dateComponents.minute = 30
        
        let userCalendar = Calendar.current
        return userCalendar.date(from: dateComponents) ?? Date()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let calendarVC = viewController as! CalendarViewController
        let currentDate = calendarVC.date
        var year = calendar.component(.year, from: currentDate)
        var month = calendar.component(.month, from: currentDate)
//        var day = calendar.component(.day, from: currentDate)
        calendarVC.calendarCollectionView.cellForItem(at: calendarVC.preIndexPath)?.backgroundColor = UIColor.clear
        calendarVC.calendarCollectionView.cellForItem(at: calendarVC.firstDayIndexPath)?.backgroundColor = UIColor.lightGray
        var day = (year == toYear && month == toMonth) ? toDay : 1
        
        mainYearMonthButton.setTitle("\(year)년 \(month)월", for: .normal)
        selectYearMonthDay(year: year, month: month, day: day)
        strYearMonth = "\(year)\(makeTwoDigitString(month))"
//        print("선택된날짜 : \(year)년 \(month)월 \(day)일")
        
        switch month {
        case 12:
            month = 1
            year += 1
        default:
            month += 1
        }
        day = (year == toYear && month == toMonth) ? toDay : 1
        let newDate = createDate(year, month, day)
        return createCalendarViewController(newDate)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let calendarVC = viewController as! CalendarViewController
        let currentDate = calendarVC.date
        var year = calendar.component(.year, from: currentDate)
        var month = calendar.component(.month, from: currentDate)
//        var day = calendar.component(.day, from: currentDate)
        calendarVC.calendarCollectionView.cellForItem(at: calendarVC.preIndexPath)?.backgroundColor = UIColor.clear
        calendarVC.calendarCollectionView.cellForItem(at: calendarVC.firstDayIndexPath)?.backgroundColor = UIColor.lightGray
        var day = (year == toYear && month == toMonth) ? toDay : 1
        
        mainYearMonthButton.setTitle("\(year)년 \(month)월", for: .normal)
        selectYearMonthDay(year: year, month: month, day: day)
        strYearMonth = "\(year)\(makeTwoDigitString(month))"
        
//        print("선택된날짜 : \(year)년 \(month)월 \(day)일")
        
        switch month {
        case 1:
            month = 12
            year -= 1
        default:
            month -= 1
        }
        day = (year == toYear && month == toMonth) ? toDay : 1
        let newDate = createDate(year, month, day)
        return createCalendarViewController(newDate)
    }
    
    
    
    
    //MARK:  - PList 입출력
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {let data = try encoder.encode(itemArray)
            try data.write(to: (dataFilePath?.appendingPathComponent("\(strYearMonth).plist"))!)
        } catch {print("Error encoding item array, \(error)")
        }
    }
    
    func loadItems() {
        itemArray.removeAll()
        if let data = try? Data(contentsOf: (dataFilePath?.appendingPathComponent("\(strYearMonth).plist"))!) {
            let decoder = PropertyListDecoder()
            do {itemArray = try decoder.decode([Item].self, from: data)
            } catch {print("Error decoding item array, \(error)")
            }
        }
    }
    
    func makeItemArray() {
        for _ in 1...daysInMonths[selectedMonth] {itemArray.append(Item())}
    }
    
    // change status bar text color to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func inputUnitOfWorkButtonAction(_ sender: Any) {
        loadItems()
        if !itemArray.isEmpty {
            let temp = itemArray[selectedDay-1].numUnitOfWork
            print(temp)
            unitOfWorkTemp = String(itemArray[selectedDay-1].numUnitOfWork)
            print(unitOfWorkTemp)
        }
    }
    
    @IBAction func inputMemoButtonAction(_ sender: Any) {
        loadItems()
        memoTemp = itemArray[selectedDay-1].memo
        print(memoTemp)
    }
    
}



extension MainViewController: PopupDelegate {
    
    func saveMemo(memo: String) {
        
        let newItem = Item()
//        loadItems()
        if itemArray.isEmpty {
            makeItemArray() }
        
        newItem.memo = memo
        newItem.strUnitOfWork = itemArray[selectedDay-1].strUnitOfWork
        newItem.numUnitOfWork = itemArray[selectedDay-1].numUnitOfWork
        
        itemArray.remove(at: selectedDay-1)
        itemArray.insert(newItem, at: selectedDay-1)
        
        saveItems()
        
        if selectedDay < daysInMonths[selectedMonth] {
            selectedDay += 1
        }
        moveYearMonth(year: selectedYear, month: selectedMonth, day: selectedDay)
    }
    
    
    func saveUnitOfWork(unitOfWork: String) {
        let newItem = Item()
//        loadItems()
        if itemArray.isEmpty {
            makeItemArray()
        }
        unitOfWorkTemp = unitOfWork
        
        if unitOfWorkTemp.contains(".") {
            while (unitOfWorkTemp.hasSuffix("0")) {
                unitOfWorkTemp.removeLast() }
            if unitOfWorkTemp.hasSuffix(".") {
                unitOfWorkTemp.removeLast() }
        }
        
        switch unitOfWorkTemp {
        case "":
            newItem.strUnitOfWork = ""
            newItem.numUnitOfWork = 0
        case "0":
            newItem.strUnitOfWork = "휴무"
            newItem.numUnitOfWork = 0
        default:
            newItem.strUnitOfWork = unitOfWorkTemp
            newItem.numUnitOfWork = Float(unitOfWorkTemp)!
        }
        
        newItem.memo = itemArray[selectedDay-1].memo

        itemArray.remove(at: selectedDay-1)
        itemArray.insert(newItem, at: selectedDay-1)
        
        saveItems()
        
        if selectedDay < daysInMonths[selectedMonth] {
            selectedDay += 1
        }
        moveYearMonth(year: selectedYear, month: selectedMonth, day: selectedDay)
        
//        memoLabel.text = "\(unitOfWork) 공수 입력 됨"
    }
    
    func moveYearMonth(year: Int, month: Int, day: Int) {
        let date = createDate(year, month, day)
        let selectedVC = createCalendarViewController(date)
        pageVC.setViewControllers([selectedVC], direction: .forward, animated: false, completion: nil)
    }
    
    func moveYearMonth(year: Int, month: Int) {
        let day = (year == toYear && month == toMonth) ? toDay : 1
        let date = createDate(year, month, day)
        let selectedVC = createCalendarViewController(date)
        pageVC.setViewControllers([selectedVC], direction: .forward, animated: false, completion: nil)
        
        mainYearMonthButton.setTitle("\(year)년 \(month)월", for: .normal)
        selectYearMonthDay(year: year, month: month, day: day)
        strYearMonth = "\(year)\(makeTwoDigitString(month))"
//        print("선택된날짜 : \(year)년 \(month)월 \(day)일")
//        memoLabel.text = "\(year)년 \(month)월 선택 됨"
    }
}

extension MainViewController: CalendarDelegate {
    func selectYearMonthDay(year: Int, month: Int, day: Int) {
        selectedYear = year
        selectedMonth = month
        selectedDay = day
        print("선택된날짜 : \(year)년 \(month)월 \(day)일")
    }
}



