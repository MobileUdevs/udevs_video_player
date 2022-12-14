//
//  ProgramViewController.swift
//  Runner
//
//  Created by Nuriddin Jumayev on 21/04/22.
//

import UIKit
import SnapKit



class ProgramViewController: UIViewController {
    
    var programInfo = [ProgramModel]()
    var locale : String = "ru"
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.tableFooterView = UIView(frame: .zero)
        table.backgroundColor = UIColor(named: "mainBackground")
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        table.register(ProgramCell.self,forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        table.separatorColor = .gray
        table.contentInsetAdjustmentBehavior = .never
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        table.contentInset = inset
        return table
    }()
    
    lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = .clear
        return bdView
    }()
    
    lazy var mainVerticalView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubviews(tableView, cancelView)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 21
        stackView.distribution = .fill
        stackView.backgroundColor = UIColor(named: "channel_background")
        return stackView
    }()
    
    lazy var divider : UIView = {
         let div = UIView()
        div.backgroundColor = .gray.withAlphaComponent(0.6)
         return div
     }()
     var cancelLabel : UILabel = {
         let label = UILabel()
         label.text = "Отменить"
         label.textColor = .white
         label.isUserInteractionEnabled = true
         label.font = UIFont.systemFont(ofSize: 15,weight: .medium)
        return label
     }()

    lazy var cancelView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton()
        cancelBtn.backgroundColor = .clear
        cancelBtn.setImage(UIImage(named: "cancelIcon"), for: .normal)
        cancelBtn.imageView?.contentMode = .scaleAspectFit

        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return cancelBtn
    }()
    
    lazy var tabBarYesterday: UIButton = {
        let tabBarButton = UIButton()
        tabBarButton.setTitle("Yesterday", for: .normal)
        return tabBarButton
    }()
    lazy var tabBarToday: UIButton = {
        let tabBarButton = UIButton()
        tabBarButton.setTitle("Today", for: .normal)
        return tabBarButton
    }()
    lazy var tabBarTomorrow: UIButton = {
        let tabBarButton = UIButton()
        tabBarButton.setTitle("Tomorrow", for: .normal)
        return tabBarButton
    }()
    
    lazy var horizontalTabs: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubviews(tabBarYesterday, tabBarToday,tabBarTomorrow)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .red
        
        return stackView
    }()
    lazy var vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubviews(horizontalTabs, tableView)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 21
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        
        return stackView
    }()
    
    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubviews(divider, horizontalStackView)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 21
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        
        return stackView
    }()
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubviews(cancelBtn, cancelLabel)
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 29
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var menuView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "mainBackground")
        return view
    }()
    var menuHeight =  UIScreen.main.bounds.height * 0.80
    var isPresenting = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.userInterfaceIdiom == .phone {
            if(UIDevice.current.orientation.isLandscape){
                menuHeight =  300
            } else {
                menuHeight =  500
            }
            print("Orientation isLandscape\(UIDevice.current.orientation.isLandscape) \(menuHeight)")
        }else {
            if programInfo.isEmpty {
                menuHeight =  UIScreen.main.bounds.height * 0.75
            }else {
                menuHeight = 210
            }
        }
        }
    
    override func viewDidLoad() {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            if programInfo.isEmpty {
           menuHeight =  UIScreen.main.bounds.height * 0.75
            }else {
                if(UIDevice.current.orientation.isLandscape){
                    menuHeight =  300
                } else {
                    menuHeight =  500
                }
            }
        }else {
            if programInfo.isEmpty {
                menuHeight =  UIScreen.main.bounds.height * 0.75
            }else {
                menuHeight = 210
            }
        }
        print("PROGRAM INFO \(programInfo)")
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(backdropView)
        view.addSubview(menuView)
//        menuView.addSubview(mainVerticalView)
        menuView.addSubview(tableView)
//        menuView.addSubview(cancelView)
//        tableView.tableFooterView = cancelView
//        cancelView.addSubview(verticalStackView)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(ProgramViewController.tapFunction))
//        cancelLabel.addGestureRecognizer(tap)
//        cancelLabel.isUserInteractionEnabled = true
        menuView.backgroundColor = .white
        tableView.sectionFooterHeight = 0
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderHeight = 0
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        backdropView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        mainVerticalView.snp.makeConstraints { make in
//            make.size.equalTo(menuView)
//
//        }
        if UIDevice.current.userInterfaceIdiom == .phone {
        tableView.snp.makeConstraints { make in
            make.left.equalTo(menuView)
            make.right.equalTo(menuView)
            make.top.equalTo(menuView).offset(0)
            make.height.equalTo(menuView)
        }
        }else {
            tableView.snp.makeConstraints { make in
                make.left.equalTo(menuView).offset(0)
                make.right.equalTo(menuView)
                make.top.equalTo(menuView).offset(0)
                make.height.equalTo(menuView).multipliedBy(0.7)
            }
        }

        menuView.snp.makeConstraints { make in
            make.height.equalTo(menuHeight)
            make.bottom.equalToSuperview().inset(0)
            make.right.left.equalToSuperview()
        }
       
//        divider.snp.makeConstraints { make in
//            make.right.left.equalTo(mainVerticalView)
//            make.height.equalTo(1)
//            make.topMargin.equalTo(0)
//
//        }
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            cancelView.snp.makeConstraints { make in
//                make.left.right.equalTo(mainVerticalView)
//                make.bottom.equalTo(mainVerticalView).offset(-20)
//                make.height.equalTo(mainVerticalView).multipliedBy(0.3)
//                make.topMargin.equalTo(0)
//            }
//        }else {
//            cancelView.snp.makeConstraints { make in
//                make.left.right.equalTo(mainVerticalView)
//                make.bottom.equalTo(mainVerticalView).offset(-20)
//                make.height.equalTo(mainVerticalView).multipliedBy(0.3)
//                make.topMargin.equalTo(0)
//            }
//        }
        
//        verticalStackView.snp.makeConstraints { make in
//            make.right.equalToSuperview()
//            make.top.equalTo(cancelView).offset(0)
//            make.left.equalTo(cancelView).offset(50)
//        }
//        horizontalStackView.snp.makeConstraints { make in
//            make.left.equalTo(verticalStackView).offset(0)
//            make.right.equalToSuperview()
//        }
        cancelBtn.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
    }
    @objc func handleTap() {
        dismiss(animated: true, completion: nil)
    }
    @objc func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("Tapped")
        self.dismiss(animated: true, completion: nil)
    }
}
extension ProgramViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programInfo[section].programsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProgramCell
        cell.selectionStyle = .none
        if !(programInfo[indexPath.section].day.isEmpty) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let data = formatter.date(from: programInfo[indexPath.section].programsList[indexPath.row].startTime) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "HH:mm"
                displayFormatter.string(from: data)
                print("TIIIIIIMEEEE\(data)")
                cell.timeLB.text = "\(displayFormatter.string(from: data))"
                cell.timeLB.textColor = .white
                cell.timeLB.font = UIFont.boldSystemFont(ofSize: 16)
            }
            cell.channelNamesLB.textColor = .white
            cell.circleView.backgroundColor = .green
//            if(programInfo[indexPath.section].programsList[indexPath.row].isAvailable) {
//                cell.channelNamesLB.textColor = .white
//                cell.circleView.backgroundColor = .green
//            }else {
//                cell.channelNamesLB.textColor = .gray
//                cell.circleView.backgroundColor = .gray
//            }
            cell.channelNamesLB.text = programInfo[indexPath.section].programsList[indexPath.row].programTitle
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return programInfo.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if !(programInfo.isEmpty)  {
        if section == 0 && !(programInfo[0].day.isEmpty){
        let headerView = UIView.init(frame: CGRect.init(x: 16, y: 0, width: tableView.frame.width, height: 80))
            headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
            if(locale == "ru"){
                label.text = "Вчера"
            } else if(locale == "uz"){
                label.text = "Kecha"
            } else {
                label.text = programInfo[0].day
            }
        label.textColor = .white
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "cancelIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        button.addGestureRecognizer(tap)
        
        headerView.addSubview(label)
        headerView.addSubview(button)
        
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(56)
            make.centerY.equalToSuperview()
        }
        
        button.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(50)
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
        }
        return headerView
        }else if section == 1  && !programInfo[0].day.isEmpty {
            let headerView = UIView.init(frame: CGRect.init(x: 16, y: 0, width: tableView.frame.width, height: 80))
            headerView.backgroundColor =  .clear

            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 17)
            if(locale == "ru"){
                label.text = "Сегодня"
            } else if(locale == "uz"){
                label.text = "Bugun"
            } else {
                label.text =  programInfo[1].day
            }
            label.textColor = .white
            headerView.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(56)
                make.centerY.equalToSuperview()
            }
            return headerView
        }else if section == 2 && !programInfo[0].day.isEmpty {
            let headerView = UIView.init(frame: CGRect.init(x: 16, y: 0, width: tableView.frame.width, height: 80))
            headerView.backgroundColor =  .clear

            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 17)
            if(locale == "ru"){
                label.text = "Завтра"
            } else if(locale == "uz"){
                label.text = "Ertaga"
            } else {
                label.text = programInfo[2].day
            }
            label.textColor = .white
            headerView.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(56)
                make.centerY.equalToSuperview()
            }
            return headerView
         }
        }
        return UIView()
    }
    
}

//MARK: Transition animation
extension ProgramViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning  {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            menuView.frame.origin.y +=  menuHeight
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.menuView.frame.origin.y -=  self.menuHeight
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.menuView.frame.origin.y +=  self.menuHeight
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
