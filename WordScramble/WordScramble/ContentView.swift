//
//  ContentView.swift
//  WordScramble
//
//  Created by SANIYA KHATARKAR on 19/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    @MainActor
    class UITextView : UIScrollView {
        
    }
    
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section{
                    ForEach(usedWords, id: \.self){
                        word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                VStack{Text("Score: \(score)")
                                }
                
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .toolbar(){
                Button("Reload", action: startGame)
            }
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else{
            wordError(title: "Word used already", message: "Be more original, kiddo")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognised", message: "Doesn't belong in my dictionary :/")
            return
        }
        
        guard invalidAns(word: answer) else {
            wordError(title: "Answer is invalid", message: "Its either too short or the start word itself")
            return
        }
        increaseScore()

                usedWords.insert(answer, at: 0)
                newWord = ""
        
//        withAnimation {
//            usedWords.insert(answer, at: 0)
//        }
//        newWord = ""
    }
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle ://")
    }
    
    //to check if word is being used the first time
    func isOriginal(word : String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word : String) -> Bool {
        var tempWord = rootWord
        
        // the logic : this loops over the word, if letter is in word and rootword(tempword), then that letter is removed from the word. if at the end, nothing is left, then yess it is possible
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
        
    }
    
    func isReal(word: String)-> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    //to disallow answers that are shorter than 3 letters or just our start word
    func invalidAns(word: String) ->Bool{
        if(word.count < 3 || word == rootWord){
            return false
        }
        else {return true}
    }
    
    func increaseScore(){
        if usedWords.count <= 5 {
            score += 1
        } else {
            score += usedWords.count - 2
            
        }
    }
    func both(){
            increaseScore()
            addNewWord()
        }

}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
