import UIKit

class PokemonViewController: UIViewController {
    
    var url:    String!
    var name:   String!
    
    @IBOutlet var pokemonImage:     UIImageView!
    @IBOutlet var nameLabel:        UILabel!
    @IBOutlet var numberLabel:      UILabel!
    @IBOutlet var type1Label:       UILabel!
    @IBOutlet var type2Label:       UILabel!
    @IBOutlet var catchButton:      UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    
    // MARK: - additional properties
    var isCaught = false
    let defaults = UserDefaults.standard
    var pokemonStatesList: [String: Bool] = [:]
    var currentDescURL: String = "https://pokeapi.co/api/v2/pokemon-species/1" // to check description method
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPokemon()
        getPreferences()
        showPokemonDescription()
    }
    
    //MARK: - pokemon loading
    func loadPokemon() {
        guard let pokemonURL = URL(string: url) else { return }
        URLSession.shared.dataTask(with: pokemonURL) { (data, _, error) in
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)
                    
                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                    // Create Image and Update ImageView
                    guard let imageURL = URL(string: result.sprites.front_default) else { return }
                    if let data = try? Data(contentsOf: imageURL) {
                        self.pokemonImage.image = UIImage(data: data)
                    }
                    self.currentDescURL = result.species.url
                    print(self.currentDescURL)
                }
            } catch let error { print(error) }
        }.resume()
    }
    
    // MARK: - Get the URL of a specific Pokémon
    func showPokemonDescription() {
        guard let pokemonDescriptionURL = URL(string: currentDescURL) else { return }
        URLSession.shared.dataTask(with: pokemonDescriptionURL) { (data, _, error) in
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(PokemonDescription.self, from: data)
                DispatchQueue.main.async {
                    // Check and get first pokemon description in English
                    for index in 0..<result.flavor_text_entries.count {
                        if result.flavor_text_entries[index].language.name == "en" {
                            self.descriptionLabel.text = result.flavor_text_entries[index].flavor_text
                        }
                    }
                }
            } catch let error { print(error) }
        }.resume()
    }
    
    // MARK: - button behavior by tapping
    @IBAction func toggleCatch() {
        isCaught = !isCaught
        customButtonSetting()
        savePreferences()
    }
    
    //button interface setting
    func customButtonSetting() {
        if isCaught {
            catchButton.setTitle("Release!", for: .normal)
            catchButton.setTitleColor(.white, for: .normal)
            catchButton.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        } else {
            catchButton.setTitle("Catch!", for: .normal)
            catchButton.setTitleColor(.white, for: .normal)
            catchButton.backgroundColor = #colorLiteral(red: 1, green: 0.2705882353, blue: 0.2274509804, alpha: 1)
        }
    }
    
    //save to UserDafaults
    func savePreferences() {
        pokemonStatesList[name!] = isCaught
        defaults.set(pokemonStatesList, forKey: "pokemonStatesList")
    }
    
    //get from UserDefaults
    func getPreferences() {
        pokemonStatesList = defaults.dictionary(forKey: "pokemonStatesList") as! [String : Bool]
        isCaught = pokemonStatesList[name!] ?? false
        customButtonSetting()
    }
}
