
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let pokeViewModel: PokeViewModel = PokeViewModel()
    
    var filterData: [Result] = []
    var urlToDetail: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await setUpData()
        }
        setUpView()
    }
    
    func setUpData() async {
        await pokeViewModel.getDataFromAPI()
        filterData = pokeViewModel.pokemons
        tableView.reloadData()
    }
    
    func setUpView() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        navigationItem.backButtonTitle = ""
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!

        let pokemon = filterData[indexPath.row]
        cell.textLabel?.text = pokemon.name.capitalized
        cell.imageView?.image = HelperImage.setImage(id: HelperString.getIdFromUrl(url: pokemon.url))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        urlToDetail = filterData[indexPath.row].url
        performSegue(withIdentifier: "detail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let pokeDetailView = segue.destination as! PokeDetailViewController
            pokeDetailView.url = urlToDetail!
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        filterData = searchText.isEmpty
        ? pokeViewModel.pokemons
        : pokeViewModel.pokemons.filter({ (pokemon: Result) -> Bool in
            return pokemon.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
