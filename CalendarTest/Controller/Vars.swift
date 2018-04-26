
import Foundation

// 아래 변수들은 빌드가 완성되는 순간의 값일까 앱이 실행될때마다 갱신 되는 것 일까
var daysInMonths = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]   //  0월은 존재X daysInMonths[0]은 값은 사용
let today = Date()
let calendar = Calendar.current
let toDay = calendar.component(.day , from: today)
let toWeekday = calendar.component(.weekday , from: today)    // 한 주의시작을 월요일로 하려면 이 값에 -1 해준다
let toMonth = calendar.component(.month , from: today)
let toYear = calendar.component(.year, from: today)
//var strYearMonth = ""
