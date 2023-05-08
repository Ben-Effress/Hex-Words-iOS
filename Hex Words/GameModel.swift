import Foundation
import SwiftyJSON
import SwiftUI

var jsonFileName: String = "JSONNames.txt"
var jsonNames: [String] = []

class GameModel: ObservableObject {
    @Published var letters: [String] = []
    @Published var middleLetter: String = ""
    @Published var hexagons: [Hexagon] = []
    @Published var words: Dictionary<String, HexWord> = [:]
    @Published var stringWords: [String] = []
    @Published var guess: String = ""
    @Published var guessArray: [String] = []
    @Published var JSONName: String = ""
    @Published var score: Int = 0
    @Published var maxScore: Int = 0
    @Published var toggle = false
    @Published var guessedWords: [String] = []
    @Published var pangramWords: [String] = []
    @Published var popUpText: String = ""
    @Published var popUpScore: Int = 0
    @Published var popUpGood: Bool = false
    @Published var showPopUp: Bool = false
    @Published var popUpY: CGFloat = 230.0
    @Published var popUpYOffset: CGFloat = 0
    @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var numDisappearers: Int = 0
    
    init() {
        initializeJSONNames()
        startNewGame()
    }
    
    
    func startNewGame() {
        chooseRandomRound()
        initializeRoundData()
    }
    
    func initializeJSONNames() {
        //initialize the list of jsonNames
        if let filePath = Bundle.main.url(forResource: "JSONNames", withExtension: "txt") {
            if let contents = try? String(contentsOf: filePath) {
                let lines = contents.split(separator:"\n")
                lines.forEach { jsonName in
                    jsonNames.append(String(jsonName))
                }
            }
        }
    }
    
    func chooseRandomRound() {
        JSONName = jsonNames.randomElement()!
    }
    
    func initializeRoundData() {
        score = 0
        maxScore = 0
        let end = JSONName.index(JSONName.startIndex, offsetBy: 7)
        let range = JSONName.startIndex..<end
        letters = Array(String(JSONName[range])).map {
            String($0)
        }
        middleLetter = letters[0]
        guess = ""
        guessArray = []
        guessedWords = []
        pangramWords = []
        stringWords = []
        words = [:]
        hexagons = []
        hexagons.append(Hexagon(center: true, letter: letters[0]))
        for i in 1...6 {
            hexagons.append(Hexagon(center: false, letter: letters[i]))
        }
        getRoundWords()
    }
    
    func getRoundWords() {
        var fileName = ""
        for i in letters {
            fileName += i
        }
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = try JSON(data: data)
                let jsonWords = jsonObj["word_list"]
                jsonWords.arrayValue.map {
                   words[$0["word"].stringValue] = parseWord(jsonWord: $0)
                }
                stringWords = Array(Set(words.keys))
                maxScore = words.reduce(0) {acc, word in
                    acc + word.value.value
                }
            } catch let error {
                print("parse error: \(error.localizedDescription)")
            }
        } else {
            print("Invalid filename/path.")
        }

    }
    
    func parseWord(jsonWord: JSON) -> HexWord {
        let word = jsonWord["word"].stringValue
        let isPangram = jsonWord["pangram"].bool
        if isPangram! {
            pangramWords.append(word)
        }
        return HexWord(word: word, isPangram: isPangram!)
    }
    
    func addLetter(letter: String) {
        showPopUp = false
        guess += letter
        guessArray.append(letter)
    }
    
    func getStringWords() -> [String] {
        return stringWords
    }
    
    func deleteLetter() {
        if guess.count > 0 {
            guess = String(guess.dropLast())
            guessArray = guessArray.dropLast()
        }
    }
    
    func checkGuess() {
        if guess.count > 3 {
            if guess.contains(middleLetter) {
                if stringWords.contains(guess) {
                    let guessedWord: HexWord = words[guess]!
                    if guessedWord.isGuessed {
                        //Already guessed
                        popUpText = "Already guessed"
                    } else {
                        if guessedWord.isPangram {
                            //WOOO PANGRAM
                            popUpText = "Pangram! LEGEND!"
                        } else {
                            //normal word non-pangram
                            popUpText = ["Word Wizard!", "Vocabulary Vandal!", "Spelling Sage", "Language Legend!"].randomElement()!
                        }
                        guessedWord.isGuessed = true
                        score += guessedWord.value
                        popUpScore = guessedWord.value
                        popUpGood = true
                        guessedWords.append(guess)
                    }
                } else {
                    //not in the word list
                    popUpText = "Sorry not in the word list. Try Again"
                }
            } else {
                //no middle letter
                popUpText = "Gotta use the middle letter"
            }
        } else {
            //too short
            popUpText = "Gotta use more letters"
        }
        
        withAnimation(.easeIn(duration: 0.2)) {
            self.showPopUp = true
        }
        
        self.popUpY = 230
        timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
        self.popUpYOffset = 0
        numDisappearers += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.numDisappearers -= 1
            if self.numDisappearers == 0 {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.showPopUp = false
                    self.popUpGood = false
                }
            }
        }
        
        guess = ""
        guessArray = []
    }
    
    func shuffle() {
        var nonCenter = hexagons.dropFirst()
        nonCenter.shuffle()
        hexagons = [hexagons[0]]
        hexagons += nonCenter
        toggle.toggle()
    }

}

class HexWord {
    var word: String
    var value: Int
    var isPangram: Bool
    var isGuessed: Bool = false
    
    init(word: String, isPangram: Bool) {
        self.word = word
        self.isPangram = isPangram
        self.value = isPangram ? word.count + 7 : (word.count > 4 ? word.count : 1)
    }
    
}
