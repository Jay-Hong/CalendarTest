import UIKit

class MainViewController: UIViewController, UIPageViewControllerDataSource{
    
    @IBOutlet weak var mainYearMonthButton: UIButton!
    @IBOutlet weak var pageCalendarView: UIView!
    @IBOutlet weak var memoLabel: UILabel!
    
//    var currentDate = Date()
//    var strYearMonth = String()
//    var monthlyUnitOfWork = Float()
//    var itemArray = [Item]()
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    @IBAction func touchYearMonthButtonAction(_ sender: Any) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeFirstMainScreen(today)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toYearMonthPopUpViewControllerSegue" {
            let popup = segue.destination as! YearMonthPopUpViewController
            popup.delegate = self
        }
    }
    
    func makeFirstMainScreen(_ date: Date) {
        // PageViewController pageCalendarView 크기에 맞춰 등록해 주기
        let pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "pageViewController") as! UIPageViewController
        pageViewController.view.frame = pageCalendarView.bounds
        addChildViewController(pageViewController)
        pageCalendarView.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        pageViewController.dataSource = self
        
        
        // 첫 pageViewController 화면 출력하기
        let firstViewController = createCalendarViewController(date)
        pageViewController.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        mainYearMonthButton.setTitle("\(year)년 \(month)월", for: .normal)
    }
    
    func createCalendarViewController(_ date: Date) -> CalendarViewController {
        let calendarVC = self.storyboard?.instantiateViewController(withIdentifier: "CanlendarViewController") as! CalendarViewController
        calendarVC.date = date
        return calendarVC
    }
    
    func createDate (_ year: Int, _ month: Int, _ day: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = 12
        dateComponents.minute = 30
        
        let userCalendar = Calendar.current // user calendar
        return userCalendar.date(from: dateComponents) ?? Date()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let calendarVC = viewController as! CalendarViewController
        let currentDate = calendarVC.date
        var year = calendar.component(.year, from: currentDate)
        var month = calendar.component(.month, from: currentDate)
        let day = 1
        
        mainYearMonthButton.setTitle("\(year)년 \(month)월", for: .normal)
        
        switch month {
        case 12:
            month = 1
            year += 1
        default:
            month += 1
        }
        
        let newDate = createDate(year, month, day)
        
        return createCalendarViewController(newDate)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let calendarVC = viewController as! CalendarViewController
        let currentDate = calendarVC.date
        var year = calendar.component(.year, from: currentDate)
        var month = calendar.component(.month, from: currentDate)
        let day = 1
        
        mainYearMonthButton.setTitle("\(year)년 \(month)월", for: .normal)
        
        switch month {
        case 1:
            month = 12
            year -= 1
        default:
            month -= 1
        }

        let newDate = createDate(year, month, day)
        
        return createCalendarViewController(newDate)
    }
    
    // change status bar text color to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension MainViewController: PopupDelegate {
    func moveYearMonth(year: Int, month: Int) {
        memoLabel.text = "\(year)년 \(month)월 선택 됨"
        let date = createDate(year, month, 1)
        makeFirstMainScreen(date)
    }
}



