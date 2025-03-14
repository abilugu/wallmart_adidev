//
//  ViewController.swift
//  wallmart
//
//  Created by Aravind Bilugu on 2/27/25.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var countries: [Country] = []
    var filteredCountries: [Country] = []
    var isSearching = false
    var urlSession: URLSession = URLSession.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
        fetchCountries()
    }
    
    func fetchCountries() {
        let urlString = "https://gist.githubusercontent.com/peymano-wmt/32dcb892b06648910ddd40406e37fdab/raw/db25946fd77c5873b0303b858e861ce724e0dcd0/countries.json"
        guard let url = URL(string: urlString) else { return }
        
        let task = urlSession.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                self.countries = try JSONDecoder().decode([Country].self, from: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
        } else {
            isSearching = true
            filteredCountries = countries.filter { country in
                country.name.lowercased().contains(searchText.lowercased()) ||
                country.region.lowercased().contains(searchText.lowercased()) ||
                country.code.lowercased().contains(searchText.lowercased()) ||
                country.capital.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredCountries.count : countries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as? CountryTableViewCell else {
            fatalError("Could not dequeue a CountryTableViewCell. Check identifier.")
        }
        
        let country: Country
        
        if isSearching {
               country = filteredCountries[indexPath.row]
           } else {
               country = countries[indexPath.row]
           }
        
        cell.nameRegionLabel.text = "\(country.name), \(country.region)"
        cell.capitalLabel.text = country.capital
        cell.codeLabel.text = country.code

        return cell
    }

}


