//
//  FilterProvinceTableViewController.swift
//  ExamHospitalNow
//
//  Created by HilmyF on 09/08/24.
//

import UIKit

class FilterProvinceTableViewController: UITableViewController {

    let provinceCell = "ProvinceCell"
    
    var completion: ((_ selected: String) -> Void)?
    var listProvinsi: [String] = []
    var selectedProvince = ""
    
    class func create() -> FilterProvinceTableViewController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: String(describing: self)) as! FilterProvinceTableViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        self.title = "All Province"
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listProvinsi.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: provinceCell, for: indexPath)

        let currentData = listProvinsi[indexPath.row]
        
        var cellContent = cell.defaultContentConfiguration()
        cellContent.text = currentData
        
        cell.contentConfiguration = cellContent
        cell.accessoryType = selectedProvince == currentData ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let 
        self.completion?(listProvinsi[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}
