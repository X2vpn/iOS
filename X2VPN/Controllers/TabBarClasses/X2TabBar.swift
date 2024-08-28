//import UIKit
//
//class TabBarController: UITabBarController {
//
//    let topLine = UIView()
//    let selectedIndexLine = UIView()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupLines()
//        updateLines(for: selectedIndex)
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        updateLinesFrames()
//    }
//
//    private func setupLines() {
//        topLine.backgroundColor = UIColor(named: "141A1C.10-FFFFFF.10")
//        tabBar.addSubview(topLine)
//
//        selectedIndexLine.backgroundColor = UIColor(named: "3AD972")
//        selectedIndexLine.clipsToBounds = true
//        selectedIndexLine.layer.cornerRadius = 1
//        tabBar.addSubview(selectedIndexLine)
//
//        updateSelectedIndexLinePosition(for: selectedIndex)
//    }
//
//    private func updateSelectedIndexLinePosition(for index: Int) {
//        let tabBarWidth = tabBar.bounds.width
//        let numberOfTabs = CGFloat(viewControllers?.count ?? 1)
//        let selectedItemWidth = tabBarWidth / numberOfTabs
//        selectedIndexLine.frame = CGRect(x: selectedItemWidth * CGFloat(index), y: 0, width: selectedItemWidth, height: 2)
//    }
//
//    private func updateLinesFrames() {
//        topLine.frame = CGRect(x: 0, y: 0.5, width: tabBar.bounds.width, height: 1)
//
//        let selectedItemWidth = (tabBar.bounds.width / CGFloat(viewControllers?.count ?? 1))
//        selectedIndexLine.frame = CGRect(x: selectedItemWidth * CGFloat(selectedIndex), y: 0, width: selectedItemWidth, height: 2)
//    }
//
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        if let index = tabBar.items?.firstIndex(of: item) {
////            print("Tab selected: \(index)")
//            updateLines(for: index)
//        }
//    }
//
//    private func updateLines(for selectedIndex: Int) {
//        let tabBarWidth = tabBar.bounds.width
//        let numberOfTabs = CGFloat(viewControllers?.count ?? 1)
//        let selectedItemWidth = tabBarWidth / numberOfTabs
//        selectedIndexLine.frame = CGRect(x: selectedItemWidth * CGFloat(selectedIndex), y: 0, width: selectedItemWidth, height: 2)
//    }
//}



import UIKit

class X2TabBar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()


    }

}
