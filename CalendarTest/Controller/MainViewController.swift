import UIKit
import GoogleMobileAds

class MainViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, GADBannerViewDelegate{
    
    @IBOutlet weak var mainYearMonthButton: UIButton!
    @IBOutlet weak var pageCalendarView: UIView!
    @IBOutlet weak var dashBoardCollectionView: UICollectionView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var pageVC = UIPageViewController()
    
    
    var selectedYear = Int()
    var selectedMonth = Int()
    var selectedDay = Int()
    
    var nextYear = Int()
    var nextMonth = Int()
    var nextDay = Int()
    
    var strYearMonth = String()
    var itemArray = [Item]()
    
    //  각자의 팝업컨트롤에 넘겨질 변수
    var memoTemp = ""
    var payTemp = ""
    var unitOfWorkTemp = ""
    
    //  메인화면 하단 출력용 변수
    var strMonthlyUnitOfWrk = ""
    var strDaylyPay = ""
    var strMonthlySalaly = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeCalendarMainScreen()
        
        setDashBoard()
        
        setAdMob()

//          print(dataFilePath)
    }
    
    func setAdMob() {
        bannerView.adSize = kGADAdSizeBanner
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    func makeCalendarMainScreen() {
        pageVC = self.storyboard?.instantiateViewController(withIdentifier: "pageViewController") as! UIPageViewController
        pageVC.view.frame = pageCalendarView.bounds
        addChild(pageVC)
        pageCalendarView.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        pageVC.dataSource = self
        pageVC.delegate = self
        
        // 첫 pageViewController 화면 출력하기
        let firstViewController = createCalendarViewController(today)
        pageVC.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        
        mainYearMonthButton.setTitle("\(toYear)년 \(toMonth)월", for: .normal)
        selectYearMonthDay(year: toYear, month: toMonth, day: toDay)
        strYearMonth = "\(toYear)\(makeTwoDigitString(toMonth))"
        
        // 해당 월 공수 , 급여 , 단가 출력
        loadItems()
        displayMonthlyUnitOfWork()
        displayDaylyPay()
        displayMonthlySalaly()
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
    
    func createCalendarViewController(_ date: Date) -> CalendarViewController {
        let calendarVC = self.storyboard?.instantiateViewController(withIdentifier: "CanlendarViewController") as! CalendarViewController
        calendarVC.date = date
        calendarVC.delegate = self
        return calendarVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let calendarVC = pendingViewControllers[0] as! CalendarViewController
        let currentDate = calendarVC.date
        nextYear = calendar.component(.year, from: currentDate)
        nextMonth = calendar.component(.month, from: currentDate)
        nextDay = (nextYear == toYear && nextMonth == toMonth) ? toDay : 1
        print("\(nextYear)월 \(nextMonth)년 달력 방향 터치")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let calendarVC = previousViewControllers[0] as! CalendarViewController
        let currentDate = calendarVC.date
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        print("이전꺼는 \(year)월 \(month)년 달력")
        
        if month != nextMonth && completed {
            mainYearMonthButton.setTitle("\(nextYear)년 \(nextMonth)월", for: .normal)
            selectYearMonthDay(year: nextYear, month: nextMonth, day: nextDay)
            strYearMonth = "\(selectedYear)\(makeTwoDigitString(selectedMonth))"
            loadItems()
            displayMonthlyUnitOfWork()
            displayDaylyPay()
            displayMonthlySalaly()
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let calendarVC = viewController as! CalendarViewController
        let currentDate = calendarVC.date
        var year = calendar.component(.year, from: currentDate)
        var month = calendar.component(.month, from: currentDate)
        calendarVC.calendarCollectionView.cellForItem(at: calendarVC.preIndexPath)?.backgroundColor = UIColor.clear
        calendarVC.calendarCollectionView.cellForItem(at: calendarVC.firstDayIndexPath)?.backgroundColor = #colorLiteral(red: 0.9359605911, green: 0.9359605911, blue: 0.9359605911, alpha: 1)
        
        switch month {
        case 12:
            month = 1
            year += 1
        default:
            month += 1
        }
        let day = (year == toYear && month == toMonth) ? toDay : 1
        let newDate = createDate(year, month, day)
        return createCalendarViewController(newDate)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let calendarVC = viewController as! CalendarViewController
        let currentDate = calendarVC.date
        var year = calendar.component(.year, from: currentDate)
        var month = calendar.component(.month, from: currentDate)
        calendarVC.calendarCollectionView.cellForItem(at: calendarVC.preIndexPath)?.backgroundColor = UIColor.clear
        calendarVC.calendarCollectionView.cellForItem(at: calendarVC.firstDayIndexPath)?.backgroundColor = #colorLiteral(red: 0.9359605911, green: 0.9359605911, blue: 0.9359605911, alpha: 1)
        
        switch month {
        case 1:
            month = 12
            year -= 1
        default:
            month -= 1
        }
        let day = (year == toYear && month == toMonth) ? toDay : 1
        let newDate = createDate(year, month, day)
        return createCalendarViewController(newDate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toYearMonthPopUpViewControllerSegue" {
            let popup = segue.destination as! YearMonthPopUpViewController
            popup.delegate = self
        } else if segue.identifier == "toUnitOfWorkPopUpViewControllerSegue" {
            let popup = segue.destination as! UnitOfWorkPopUpViewController
            popup.delegate = self
            popup.strNumber = unitOfWorkTemp
            popup.selectedMonth = selectedMonth
            popup.selectedDay = selectedDay
        } else if segue.identifier == "toMemoPopUpViewControllerSegue" {
            let popup = segue.destination as! MemoPopUpViewController
            popup.delegate = self
            popup.memo = memoTemp
            popup.selectedMonth = selectedMonth
            popup.selectedDay = selectedDay
        } else if segue.identifier == "toPayPopUpViewControllerSegue" {
            let popup = segue.destination as! PayPopUpViewController
            popup.delegate = self
            popup.strNumber = payTemp
            popup.selectedMonth = selectedMonth
        }
    }
    
    //MARK:  - DashBoard 출력
    // 호출전에 해당 년월.plist 값이 itemArray에 load 되어 있어야 함
    func displayMonthlyUnitOfWork() {
        var monthlyUnitOfWork = Float()
        for item in itemArray {
            monthlyUnitOfWork += item.numUnitOfWork
        }
        strMonthlyUnitOfWrk = String(monthlyUnitOfWork)
        if strMonthlyUnitOfWrk.contains(".") {
            while (strMonthlyUnitOfWrk.hasSuffix("0")) {
                strMonthlyUnitOfWrk.removeLast() }
            if strMonthlyUnitOfWrk.hasSuffix(".") {
                strMonthlyUnitOfWrk.removeLast() }
        }
        dashBoardCollectionView.reloadData()
    }
    
    // 호출전에 해당 년월.plist 값이 itemArray에 load 되어 있어야 함
    func displayMonthlySalaly() {
        var monthlySalaly = Float()
        for item in itemArray {
            monthlySalaly += item.numUnitOfWork * item.pay
        }
        strMonthlySalaly = String(monthlySalaly)
        if strMonthlySalaly.contains(".") {
            while (strMonthlySalaly.hasSuffix("0")) {
                strMonthlySalaly.removeLast() }
            if strMonthlySalaly.hasSuffix(".") {
                strMonthlySalaly.removeLast() }
        }
        dashBoardCollectionView.reloadData()
    }
    
    // 호출전에 해당 년월.plist 값이 itemArray에 load 되어 있어야 함
    func displayDaylyPay() {
        var daylyPay = Float()
        if !itemArray.isEmpty {
            daylyPay = itemArray[selectedDay-1].pay
        }
        strDaylyPay = String(daylyPay)
        if strDaylyPay.contains(".") {
            while (strDaylyPay.hasSuffix("0")) {
                strDaylyPay.removeLast() }
            if strDaylyPay.hasSuffix(".") {
                strDaylyPay.removeLast() }
        }
        dashBoardCollectionView.reloadData()
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
    
    // status bar text color 흰색으로 바꿔주기
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func inputUnitOfWorkButtonAction(_ sender: Any) {
        loadItems()
        // 선택된 날짜 공수 입력화면에 출력
            unitOfWorkTemp = !itemArray.isEmpty ? String(itemArray[selectedDay-1].numUnitOfWork) : "0"
    }
    
    @IBAction func inputMemoButtonAction(_ sender: Any) {
        loadItems()
        // 선택된 날짜의 메모 입력화면에 출력
        memoTemp = !itemArray.isEmpty ? itemArray[selectedDay-1].memo : ""
    }
    
    @IBAction func inputPayButtonAction(_ sender: Any) {
        loadItems()
        //  선택된 달(날짜)의 단가를 입력화면에 출력
        payTemp = !itemArray.isEmpty ? String(itemArray[selectedDay-1].pay) : "0"
    }
    
}

extension MainViewController: PopupDelegate {
    
    func saveMemo(memo: String) {
        let newItem = Item()
        //loadItems()
        if itemArray.isEmpty {makeItemArray() }
        
        newItem.memo = memo
        newItem.strUnitOfWork = itemArray[selectedDay-1].strUnitOfWork
        newItem.numUnitOfWork = itemArray[selectedDay-1].numUnitOfWork
        newItem.pay = itemArray[selectedDay-1].pay
        
        itemArray.remove(at: selectedDay-1)
        itemArray.insert(newItem, at: selectedDay-1)
        
        saveItems()
        
        if selectedDay < daysInMonths[selectedMonth] {
            selectedDay += 1
        }
        moveYearMonth(year: selectedYear, month: selectedMonth, day: selectedDay)
    }
    
    func savePay(pay: String) {
        //loadItems()
        if itemArray.isEmpty {makeItemArray()}
        payTemp = pay
        for item in itemArray {
            item.pay = Float(payTemp)!
        }
        saveItems()
        displayDaylyPay()
        displayMonthlySalaly()
    }
    
    func saveUnitOfWork(unitOfWork: String) {
        let newItem = Item()
      //loadItems()
        if itemArray.isEmpty {makeItemArray()}
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
        newItem.pay = itemArray[selectedDay-1].pay

        itemArray.remove(at: selectedDay-1)
        itemArray.insert(newItem, at: selectedDay-1)
        
        saveItems()
        
        if selectedDay < daysInMonths[selectedMonth] {
            selectedDay += 1
        }
        moveYearMonth(year: selectedYear, month: selectedMonth, day: selectedDay)
        
        displayMonthlyUnitOfWork()
        displayMonthlySalaly()

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
        loadItems()
        displayMonthlyUnitOfWork()
        displayDaylyPay()
        displayMonthlySalaly()
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

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func setDashBoard() {
        dashBoardCollectionView.register(UINib.init(nibName: "DashBoardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "dashIdentififer")
        
        let flowLayout = UPCarouselFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 40.0, height: dashBoardCollectionView.frame.size.height - 4)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sideItemScale = 0.95
        flowLayout.sideItemAlpha = 0.5
        flowLayout.spacingMode = .fixed(spacing: 10)
        dashBoardCollectionView.collectionViewLayout = flowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dashBoardCollectionView.dequeueReusableCell(withReuseIdentifier: "dashIdentififer", for: indexPath) as! DashBoardCollectionViewCell
        
        switch indexPath.row {
            
        case 0:
            cell.contentLabel.textAlignment = .center
            cell.contentLabel.text = strMonthlyUnitOfWrk
            cell.descriptionLabel.text = "\(selectedMonth)월 공수"
            cell.unitLabel.text = "공수"
            cell.backView.backgroundColor = #colorLiteral(red: 0, green: 0.7568627451, blue: 0.8431372549, alpha: 1)
            cell.imgBackView.backgroundColor = #colorLiteral(red: 0, green: 0.662745098, blue: 0.7411764706, alpha: 1)
            cell.iconImgView.image = #imageLiteral(resourceName: "ic_schedule")
            
        case 1:
            cell.contentLabel.text = strMonthlySalaly
            cell.descriptionLabel.text = "\(selectedMonth)월 예상 급여"
            cell.unitLabel.text = "만원"
            cell.backView.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0, blue: 0.3490196078, alpha: 1)
            cell.imgBackView.backgroundColor = #colorLiteral(red: 0.8705882353, green: 0, blue: 0.3098039216, alpha: 1)
            cell.iconImgView.image = #imageLiteral(resourceName: "ic_wallet")
            
        case 2:
            cell.contentLabel.text = strDaylyPay
            cell.descriptionLabel.text = "\(selectedMonth)월 단가"
            cell.unitLabel.text = "만원"
            cell.backView.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8039215686, blue: 0.2745098039, alpha: 1)
            cell.imgBackView.backgroundColor = #colorLiteral(red: 0.4039215686, green: 0.7019607843, blue: 0.2431372549, alpha: 1)
            cell.iconImgView.image = #imageLiteral(resourceName: "ic_money")
            
        default:
            break
        }
        return cell
    }
    
}

