//
//  ViewController.swift
//  ExamHospitalNow
//
//  Created by HilmyF on 09/08/24.
//

import UIKit

class ViewController: UIViewController {

    let hospitalCell = "HospitalCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    var hospitals: [Hospital] = []
    var filteredHospital: [Hospital] = []
    var selectedProvince = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }

    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        self.title = selectedProvince.isEmpty ? "All Hospital" : "Hospital in \(selectedProvince)"
        self.navigationController?.navigationBar.backgroundColor = UIColor(hex: "#A7E6FF")
    }
    
    func fetchData() {
        NetworkManager.shared.fetchHospitals { result in
            switch result {
            case .success(let hospitals):
                self.hospitals = hospitals
                self.filteredHospital = hospitals
                self.tableView.reloadData()
                
            case .failure(let error):
                print("Failed to fetch hospitals: \(error)")
            }
        }
    }
    
    @IBAction func filterTapped(_ sender: Any) {
        var arrayProvince = getProvincesArray(from: hospitals).sorted()
        arrayProvince.insert("All", at: 0)
        
        let filterViewController = FilterProvinceTableViewController.create()
        filterViewController.listProvinsi = arrayProvince
        filterViewController.selectedProvince = self.selectedProvince
        filterViewController.completion = { data in
            self.selectedProvince = data
            self.title = data.isEmpty || data == "All" ? "All Hospital" : "Hospital in \(data)"
            
            self.filterHospitalByProvince()
        }
        self.navigationController?.pushViewController(filterViewController, animated: true)
    }
    
    func filterHospitalByProvince() {
        filteredHospital = hospitals
        if selectedProvince != "All" {
            filteredHospital = filteredHospital.filter { $0.province == selectedProvince }
        }
        
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredHospital.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        240
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: hospitalCell, for: indexPath) as! HospitalTableViewCell
        
        cell.fetchUI(data: filteredHospital[indexPath.row], delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension ViewController: CellDelegate {
    func viewLocation(hospital: Hospital) {
        let mapViewController = MapViewController.create()
        mapViewController.hospital = hospital
        
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
}

protocol CellDelegate {
    func viewLocation(hospital: Hospital)
}

class HospitalTableViewCell: UITableViewCell {
    @IBOutlet weak var imageHospital: UIImageView!
    @IBOutlet weak var labelHospitalName: UILabel!
    @IBOutlet weak var labelHospitalDesc: UILabel!
    @IBOutlet weak var btnViewLocation: UIButton!
    @IBOutlet weak var viewParent: UIView!
    
    var delegate: CellDelegate?
    var hospitalData: Hospital!
    
    func fetchUI(data: Hospital, delegate: CellDelegate) {
        self.hospitalData = data
        self.delegate = delegate
        
        labelHospitalName.text = data.name
        var hospitalDesc = data.region
        
        if let phone = data.phone {
            hospitalDesc += " · " + phone
        }
        
        labelHospitalDesc.text = hospitalDesc
        
        imageHospital.image = UIImage(named: "hospital")
    }
    
    @IBAction func viewLocationTapped(_ sender: Any) {
        if let delegate {
            delegate.viewLocation(hospital: self.hospitalData)
        }
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
