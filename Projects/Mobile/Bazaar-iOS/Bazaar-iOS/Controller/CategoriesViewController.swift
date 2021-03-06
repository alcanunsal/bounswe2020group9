//
//  CategoriesViewController.swift
//  Bazaar-iOS
//
//  Created by Uysal, Sadi on 12.11.2020.
//

import UIKit

class CategoriesViewController: UIViewController {
 
    //set necessary variables
    
    @IBOutlet weak var subCategoriesTableView: UITableView!
    @IBOutlet weak var searchHistoryTableView: UITableView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var allProductsInstance = AllProducts_temp.shared
     var selectedCategoryName: String?

     var selectedCategoryButton: UIButton? {
         didSet{
             selectedCategoryName = selectedCategoryButton?.titleLabel?.text
             categorySelected()
         }
     }
         
     let CLOTHING = "Clothing"
     let HOME = "Home"
     let SELFCARE = "Selfcare"
     let ELECTRONICS = "Electronics"
     let LIVING = "Living"
     var subCategoryDict: [String: [String]] = ["Clothing":["Top", "Bottom", "Outerwear", "Shoes", "Bags", "Accesories", "Activewear"],
                                                "Home":["Home Textile", "Kitchen", "Bedroom", "Bathroom", "Furniture", "Lighting", "Other"],
                                                "Selfcare":["Perfumes", "Makeup", "Skincare", "Hair", "Body Care", "Other"],
                                                "Electronics":["Mobile Devices", "Tablet", "Computer", "Photography", "Home Appliances", "TV", "Gaming", "Other"],
                                                "Living":["Books", "Art Supplies", "Musical Devices", "Sports", "Other"]]
     var categories = ["Clothing", "Home", "Selfcare", "Electronics", "Living"]
     var products: [Product] = []
     let categoriesReuseIdentifier = "CategoriesCollectionViewCell"
     var networkFailedAlert:UIAlertController = UIAlertController(title: "Error while retrieving products", message: "We encountered a problem while retrieving the products, please check your internet connection.", preferredStyle: .alert)
     var searchHistory:[String] = (UserDefaults.standard.value(forKey: K.searchHistoryKey) as? [String] ?? [])
     var searchResults:[String] = []
     var historyEndIndex:Int = 0
     var categoriesEndIndex: Int = 0
    var searchTextField: UITextField?
     
    // to do for viewWillappear, set seachBar features
     override func viewWillAppear(_ animated: Bool) {
         searchHistoryTableView.reloadData()
         subCategoriesTableView.reloadData()
        navigationController?.setNavigationBarHidden(true, animated: true)
         if #available(iOS 13.0, *) {
             searchTextField = searchBar.searchTextField
         } else {
             self.searchBar.barStyle = .default
             if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
                 searchTextField = searchField
             }
         }
         searchTextField?.alpha = 1.0
         searchResults = searchHistory
         historyEndIndex = searchHistory.count
         categoriesEndIndex = searchHistory.count
     }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
     override func viewDidLoad() {
         super.viewDidLoad()
         searchBar.delegate = self
         subCategoriesTableView.dataSource = self
         subCategoriesTableView.delegate = self
         searchHistoryTableView.dataSource = self
         searchHistoryTableView.delegate = self
         self.categoryCollectionView.dataSource = self
         self.categoryCollectionView.delegate = self
         allProductsInstance.delegate = self
         searchHistoryTableView.isHidden = true
         // subCategoriesTableView.isHidden = false
         self.view.sendSubviewToBack(searchHistoryTableView)
         self.view.sendSubviewToBack(searchHistoryTableView)
         categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier:  "CategoryCollectionViewCell")
         //generateProducts()
         createIndicatorView()
         let okButton = UIAlertAction(title: "Retry", style: .cancel, handler: { action in
             // fetch products
             self.allProductsInstance.fetchAllProducts()
         })
         networkFailedAlert.addAction(okButton)
         selectedCategoryName = CLOTHING
        subCategoriesTableView.register(UINib(nibName: "SubCategoryCell", bundle: nil), forCellReuseIdentifier: "SubCategoryCell")
        subCategoriesTableView.layer.cornerRadius=20
         if !(allProductsInstance.dataFetched) {
             print("here")
             self.searchBar.resignFirstResponder()
             self.searchBar.isUserInteractionEnabled = false
             startIndicator()
             self.allProductsInstance.fetchAllProducts()
         }
         searchResults = searchHistory
         historyEndIndex = searchHistory.count
         
     }
     
     //reload selected category
     func categorySelected () {
        // DO SOMETHING
         self.subCategoriesTableView.reloadData()
     }
     
     //prepare to segue
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         self.searchBar.showsCancelButton = false
         
         searchHistoryTableView.isHidden = true
         searchBar.resignFirstResponder()
         dismiss(animated: true, completion: nil)
         self.view.sendSubviewToBack(searchHistoryTableView)
         self.view.sendSubviewToBack(searchHistoryTableView)
         searchResults = searchHistory
        if segue.identifier=="categoriesToSearchResultsSegue" {
             let searchResultsVC = segue.destination as! SearchResultsViewController
             searchResultsVC.searchWord = searchBar.searchTextField.text
             let indexpath = searchHistoryTableView.indexPathForSelectedRow
             if indexpath != nil {
                 if indexpath!.row < historyEndIndex {
                     searchResultsVC.isSearchWord = true
                     searchResultsVC.isBrand = false
                     searchResultsVC.isCategory = false
                 } else if indexpath!.row < categoriesEndIndex {
                     searchResultsVC.isSearchWord = false
                     searchResultsVC.isBrand = false
                     searchResultsVC.isCategory = true
                 } else {
                     searchResultsVC.isSearchWord = false
                     searchResultsVC.isBrand = true
                     searchResultsVC.isCategory = false
                 }
             } else {
                 searchResultsVC.isSearchWord = true
                 searchResultsVC.isBrand = false
                 searchResultsVC.isCategory = false
             }
             
             searchBar.text = ""
        } else if segue.identifier=="categoriesToResultsSegue" {
            
            let searchResultsVC = segue.destination as! SearchResultsViewController
            let indexpath = subCategoriesTableView.indexPathForSelectedRow
            if indexpath != nil {
                let subCategories=subCategoryDict[selectedCategoryName!]!
                searchResultsVC.searchWord = subCategories[indexpath!.row]
                searchResultsVC.isSearchWord = false
                searchResultsVC.isBrand = false
                searchResultsVC.isCategory = true
            }
        }
     }
     // segue configuration
     override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
         if identifier == "categoriesToSearchResultsSegue" {
             return !(searchBar.searchTextField.text == "")
         } else if identifier == "categoriesToResultsSegue" {
            return self.subCategoriesTableView.indexPathForSelectedRow != nil
       }
         return false
     }


 }


//return count
 extension CategoriesViewController:UITableViewDelegate,UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
         if tableView == subCategoriesTableView {
            return subCategoryDict[selectedCategoryName!]!.count
        
         }
         if tableView == searchHistoryTableView {
             return searchResults.count
         }
         return 10
     }
    
     // set up cells according to index
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
         if tableView == subCategoriesTableView {
            let cell = subCategoriesTableView.dequeueReusableCell(withIdentifier: "SubCategoryCell", for: indexPath) as! SubCategoryCell
            let subCategories=subCategoryDict[selectedCategoryName!]!
            cell.layer.cornerRadius=5
            cell.nameLabel?.text = subCategories[indexPath.row]
            cell.subCategoryImage?.image = UIImage(named: subCategories[indexPath.row].lowercased().replacingOccurrences(of: " ", with: ""))
             return cell
         } else {
            let cell = searchHistoryTableView.dequeueReusableCell(withIdentifier: "searchHistoryCell", for: indexPath) as! SearchHistoryTableViewCell
            cell.resultLabel.text = searchResults[indexPath.row]
            if indexPath.row < historyEndIndex {
                cell.showClock()
                cell.hideType()
            } else if indexPath.row < categoriesEndIndex {
                cell.hideClock()
                cell.showType()
                cell.typeLabel.text = "Category"
            } else {
                cell.hideClock()
                cell.showType()
                cell.typeLabel.text = "Brand"
            }
            return cell
         }

     
     }
     // selected row operations when selected
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if tableView == searchHistoryTableView {
             searchBar.searchTextField.text = searchResults[indexPath.row]
             searchBar.text = searchResults[indexPath.row]
             performSegue(withIdentifier: "categoriesToSearchResultsSegue", sender: nil)
         } else {
            let subCategories=subCategoryDict[selectedCategoryName!]!
            searchBar.searchTextField.text = subCategories[indexPath.row]
            //searchBar.text = searchResults[indexPath.row]
            performSegue(withIdentifier: "categoriesToResultsSegue", sender: nil)
            searchBar.searchTextField.text = ""
            
         }
         
     }
     // editable??
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         if tableView == searchHistoryTableView {
             if indexPath.row < historyEndIndex {
                 return true
             }
         }
         return false
     }
    
    //editing style
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if (editingStyle == .delete) {
             searchResults.remove(at: indexPath.row)
             searchHistory.remove(at: indexPath.row)
             UserDefaults.standard.set(searchHistory, forKey: K.searchHistoryKey)
             searchHistoryTableView.reloadData()
         }
     }
 }

// return category count
 //MARK: - Extension UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
 extension CategoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.categories.count
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath)
             if let cell = cell as? CategoryCollectionViewCell {
                 cell.delegate = self
                 let categoryName = self.categories[indexPath.row]
                 cell.setCategory(categoryName: categoryName)
                 if self.categories[indexPath.row].caseInsensitiveCompare(selectedCategoryName ?? "") == .orderedSame {
                     cell.setAsCurrentCategory(isCurrentCategory: true)
                 }else {
                     cell.setAsCurrentCategory(isCurrentCategory: false)
                 }
             }
             return cell
         }
     
     // design choices
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         let text = self.categories[indexPath.row]
         let width = self.estimatedFrame(text: text, font: .systemFont(ofSize: 17.0)).width
         return CGSize(width: width+30.0, height: 35.0)
     }
     
     func estimatedFrame(text: String, font: UIFont) -> CGRect {
         let size = CGSize(width: 200, height: 1000) // temporary size
         let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
         return NSString(string: text).boundingRect(with: size,
                                                    options: options,
                                                    attributes: [NSAttributedString.Key.font: font],
                                                    context: nil)
     }
     
 }
// selected category cell operations
 //MARK: - Extension CellDelegate
 extension CategoriesViewController:CellDelegate {
     func didCellSelected(cell: UICollectionViewCell) {
         if let categoryCell = cell as? CategoryCollectionViewCell {
             self.selectedCategoryName=categoryCell.categoryName
             categoryCollectionView.reloadData()
             subCategoriesTableView.reloadData()
         }
     }
 }

// all products fetching delegates -functions
 extension CategoriesViewController: AllProductsFetchDelegate_temp {
     
     func allProductsAreFetched_temp() {
         stopIndicator()
         self.subCategoriesTableView.reloadData()
         self.searchBar.isUserInteractionEnabled = true
         //DispatchQueue.main.async {
           //  self.subCategoriesTableView.reloadData()
            // self.searchBar.isUserInteractionEnabled = true
         //}
     }
     
     func productsCannotBeFetched_temp() {
         startIndicator()
         presentAlert_temp()
         
     }
     
     func presentAlert_temp() {
         if allProductsInstance.apiFetchError {
             self.networkFailedAlert.message = "We couldn't connect to the network, please check your internet connection."
         }
         if allProductsInstance.jsonParseError {
             self.networkFailedAlert.message = "There is an internal problem in the system."
         }
         if !self.networkFailedAlert.isBeingPresented {
             self.present(networkFailedAlert, animated:true, completion: nil)
         }
     }
 }

 // MARK: - SearchBar
 extension CategoriesViewController: UISearchBarDelegate, UISearchControllerDelegate {
     
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
         searchResults = searchText.isEmpty ? searchHistory : searchHistory.filter{(query:String) -> (Bool) in
             return query.range(of:searchText, options: .caseInsensitive, range:nil, locale: nil) != nil
         }
         historyEndIndex = searchResults.count
         searchResults.append(contentsOf: categories.filter{(query:String) -> (Bool) in
             return query.range(of:searchText, options: .caseInsensitive, range:nil, locale: nil) != nil})
         categoriesEndIndex = searchResults.count
         let brands = Array(Set(allProductsInstance.allProducts.map{$0.brand}))
         searchResults.append(contentsOf: brands.filter{(query:String) -> (Bool) in
         return query.range(of:searchText, options: .caseInsensitive, range:nil, locale: nil) != nil})
         searchHistoryTableView.reloadData()
     }
     
     
     func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
         searchResults = searchHistory
         self.searchBar.showsCancelButton = true
         self.searchHistoryTableView.isHidden = false
         self.view.bringSubviewToFront(searchHistoryTableView)
         self.view.bringSubviewToFront(searchHistoryTableView)
         self.searchHistoryTableView.setValue(1, forKeyPath: "alpha")
     }
     
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         if searchBar.searchTextField.text != "" {
             let brands = allProductsInstance.allProducts.map{$0.brand}
             if !searchHistory.contains(searchBar.searchTextField.text!) &&  !categories.contains(searchBar.searchTextField.text!) && !brands.contains(searchBar.searchTextField.text!){
                 searchHistory.append(searchBar.text!)
             }
             UserDefaults.standard.set(searchHistory, forKey: K.searchHistoryKey)
             //searchHistoryTableView.reloadData()
         }
         searchHistoryTableView.setValue(0, forKeyPath: "alpha")
         if (shouldPerformSegue(withIdentifier: "categoriesToSearchResultsSegue", sender: nil)) {
             performSegue(withIdentifier: "categoriesToSearchResultsSegue", sender: nil)
         }
     }
     
     func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         self.searchBar.showsCancelButton = false
         searchBar.text = ""
         searchHistoryTableView.isHidden = true
         searchBar.resignFirstResponder()
         dismiss(animated: true, completion: nil)
         self.view.sendSubviewToBack(searchHistoryTableView)
         self.view.sendSubviewToBack(searchHistoryTableView)
     }
     
     
 }


//indicators
 // MARK: - IndicatorView
 extension CategoriesViewController {
     func startIndicator() {
         self.view.bringSubviewToFront(loadingView)
         loadingView.isHidden = false
         activityIndicator.isHidden = false
         activityIndicator.startAnimating()
         subCategoriesTableView.isHidden = true
     }

     func createIndicatorView() {
         loadingView.isHidden = false
         activityIndicator.isHidden = false
         activityIndicator.startAnimating()
         subCategoriesTableView.isHidden = true
     }
     
     func stopIndicator() {
         DispatchQueue.main.async {
             self.loadingView.isHidden = true
             self.activityIndicator.isHidden = true
             self.activityIndicator.stopAnimating()
             self.view.sendSubviewToBack(self.loadingView)
             self.subCategoriesTableView.isHidden = false
             self.subCategoriesTableView.isUserInteractionEnabled = true
             self.subCategoriesTableView.reloadData()
         }
     }
 }
//protocol for fetching
 protocol AllProductsFetchDelegate_temp {
     func allProductsAreFetched_temp()
     func productsCannotBeFetched_temp()
     func presentAlert_temp()
 }

// all products class for fetching all products
 class AllProducts_temp {
     static let shared = AllProducts_temp()
     var allProducts: [ProductData]
     private let saveKey = "AllProducts"
     
     var delegate: AllProductsFetchDelegate_temp?
     let dispatchGroup = DispatchGroup()
     var dataFetched = false {
         didSet{
             if self.dataFetched{
                 delegate?.allProductsAreFetched_temp()
             } else {
                 delegate?.productsCannotBeFetched_temp()
             }
         }
     }
     var apiFetchError = false
     var jsonParseError = false
     
     init(){
         self.allProducts = []
     }
     
     func fetchAllProducts() {
         dispatchGroup.enter()
         APIManager().getAllProducts(completionHandler: { products in
             if products != nil {
                 self.dataFetched = true
                 self.allProducts = products!
                 self.delegate?.allProductsAreFetched_temp()
             } else {
                 self.dataFetched = false
                 self.allProducts = []
                 self.delegate?.productsCannotBeFetched_temp()
             }
         })
         dispatchGroup.leave()
         dispatchGroup.wait()
     }
         
 }
