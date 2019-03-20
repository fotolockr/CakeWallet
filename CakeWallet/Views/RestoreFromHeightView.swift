import UIKit
import FlexLayout
import SwiftSoup

private let dates: [Date: UInt64] = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM"
    
    return [
        formatter.date(from: "2014-05")!: 18844,
        formatter.date(from: "2014-06")!: 65406,
        formatter.date(from: "2014-07")!: 108882,
        formatter.date(from: "2014-08")!: 153594,
        formatter.date(from: "2014-09")!: 198072,
        formatter.date(from: "2014-10")!: 241088,
        formatter.date(from: "2014-11")!: 285305,
        formatter.date(from: "2014-12")!: 328069,
        formatter.date(from: "2015-01")!: 372369,
        formatter.date(from: "2015-02")!: 416505,
        formatter.date(from: "2015-03")!: 456631,
        formatter.date(from: "2015-04")!: 501084,
        formatter.date(from: "2015-05")!: 543973,
        formatter.date(from: "2015-06")!: 588326,
        formatter.date(from: "2015-07")!: 631187,
        formatter.date(from: "2015-08")!: 675484,
        formatter.date(from: "2015-09")!: 719725,
        formatter.date(from: "2015-10")!: 762463,
        formatter.date(from: "2015-11")!: 806528,
        formatter.date(from: "2015-12")!: 849041,
        formatter.date(from: "2016-01")!: 892866,
        formatter.date(from: "2016-02")!: 936736,
        formatter.date(from: "2016-03")!: 977691,
        formatter.date(from: "2016-04")!: 1015848,
        formatter.date(from: "2016-05")!: 1037417,
        formatter.date(from: "2016-06")!: 1059651,
        formatter.date(from: "2016-07")!: 1081269,
        formatter.date(from: "2016-08")!: 1103630,
        formatter.date(from: "2016-09")!: 1125983,
        formatter.date(from: "2016-10")!: 1147617,
        formatter.date(from: "2016-11")!: 1169779,
        formatter.date(from: "2016-12")!: 1191402,
        formatter.date(from: "2017-01")!: 1213861,
        formatter.date(from: "2017-02")!: 1236197,
        formatter.date(from: "2017-03")!: 1256358,
        formatter.date(from: "2017-04")!: 1278622,
        formatter.date(from: "2017-05")!: 1300239,
        formatter.date(from: "2017-06")!: 1322564,
        formatter.date(from: "2017-07")!: 1344225,
        formatter.date(from: "2017-08")!: 1366664,
        formatter.date(from: "2017-09")!: 1389113,
        formatter.date(from: "2017-10")!: 1410738,
        formatter.date(from: "2017-11")!: 1433039,
        formatter.date(from: "2017-12")!: 1454639,
        formatter.date(from: "2018-01")!: 1477201,
        formatter.date(from: "2018-02")!: 1499599,
        formatter.date(from: "2018-03")!: 1519796,
        formatter.date(from: "2018-04")!: 1542067,
        formatter.date(from: "2018-05")!: 1562861,
        formatter.date(from: "2018-06")!: 1582861
    ]
}()

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func previousMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }
}


func getHeight(of date: Date, calendar: Calendar = Calendar.current) -> UInt64 {
    var minDateComponents = DateComponents()
    minDateComponents.year = 2014
    minDateComponents.month = 5
    minDateComponents.day = 1
    
    guard
        let minDate = calendar.date(from: minDateComponents),
        minDate < date else { return 0 }
    var startDate = date.startOfMonth()
    let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
    var startHeight: UInt64 = 0
    var endHeight: UInt64 = 0
    
    if let _endHeight = dates[endDate] {
        endHeight = _endHeight
    } else {
        let datesArray = Array(dates.keys).sorted(by: { $1 > $0 })
        let lastMonth = datesArray[datesArray.count - 1]
        endHeight = dates[lastMonth]!
        
        let preLastMonth = datesArray[datesArray.count - 2]
        startHeight = dates[preLastMonth]!
        startDate = lastMonth
    }
    
    if startHeight == 0 {
        startHeight = dates[startDate]!
    }
    
    let diff = endHeight - startHeight
    let days = calendar.range(of: .day, in: .month, for: date)!
    let heightPerDay = diff / UInt64(days.count)
    let countOfDays  = calendar.dateComponents([.day], from: startDate, to: date).day!
    let height = startHeight + UInt64(countOfDays) * heightPerDay
    
    return height
}

func getHeight(from date: Date, handler: @escaping (UInt64) -> Void) {
    DispatchQueue.global(qos: .background).async {
        let height = getHeight(of: date)
        handler(height)
    }
}

final class RestoreFromHeightView: BaseFlexView {
    let withTransparentBackground: Bool
    let wrapper: UIView
    let restoreHeightTextField: TextField
    let dateTextField: TextField
    let datePicker: UIDatePicker
    var restoreHeight: UInt64 {
        var height: UInt64 = 0
        if
            let heightStr = restoreHeightTextField.textField.text,
            let _height = UInt64(heightStr) {
            height = _height
        }
        return height
    }
    
    required init(withTransparentBackground: Bool = false) {
        self.withTransparentBackground = withTransparentBackground
        wrapper = UIView()
        restoreHeightTextField = TextField(placeholder: NSLocalizedString("restore_height", comment: ""), fontSize: 16, isTransparent: withTransparentBackground)
        dateTextField = TextField(placeholder: NSLocalizedString("restore_from_date", comment: ""), fontSize: 16, isTransparent: withTransparentBackground)
        datePicker = UIDatePicker()
        super.init()
    }
    
    required init() {
        self.withTransparentBackground = false
        wrapper = UIView()
        restoreHeightTextField = TextField(placeholder: NSLocalizedString("restore_height", comment: ""), fontSize: 16, isTransparent: withTransparentBackground)
        dateTextField = TextField(placeholder: NSLocalizedString("restore_from_date", comment: ""), fontSize: 16, isTransparent: withTransparentBackground)
        datePicker = UIDatePicker()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        backgroundColor = .clear
        restoreHeightTextField.textField.keyboardType = .numberPad
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current
        dateTextField.textField.inputView = datePicker
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(onDateChange(_:)), for: .valueChanged)
        addSubview(restoreHeightTextField)
        addSubview(dateTextField)
    }
    
    @objc
    private func onDateChange(_ datePicker: UIDatePicker) {
        let date = datePicker.date
        
        getHeight(from: date) { [weak self] height in
            DispatchQueue.main.async {
                self?.restoreHeightTextField.textField.text = "\(height)"
            }
        }
    }
    
    @objc
    private func handleDatePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = Locale.current.regionCode?.lowercased() == "us" ? "MMMM d, yyyy" : "d MMMM, yyyy" //fixme hardcoded regionCode value
        dateTextField.textField.text = dateFormatter.string(from: datePicker.date)
    }
    
    override func configureConstraints() {
        let adaptiveMargin = adaptiveLayout.getSize(forLarge: 34, forBig: 32, defaultSize: 30)
        
        rootFlexContainer.flex
            .backgroundColor(.clear)
            .define { flex in
                flex.addItem(restoreHeightTextField).marginBottom(adaptiveMargin).width(100%)
                flex.addItem(dateTextField).width(100%)
        }
    }
}
