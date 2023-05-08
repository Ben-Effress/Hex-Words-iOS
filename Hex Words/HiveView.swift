import SwiftUI

var model: GameModel = GameModel()

let hexagonWidth: CGFloat = 100.0

struct TextBox: View {
    @ObservedObject var hexagonModel: GameModel = model
    var body: some View {
        HStack {
            ForEach(hexagonModel.guessArray, id: \.self) { letter in
                let letterColor: Color = (letter == hexagonModel.middleLetter) ? Color.green : Color("ACC2")
                Text(letter)
                    .font(.system(size: 30, weight: .bold))
                    .padding(.trailing, -8)
                    .foregroundColor(letterColor)
            }
        }
    }
}

struct ScoreView: View {
    @ObservedObject var hexagonModel: GameModel = model
    var body: some View {
        HStack {
            Text("Score: \(hexagonModel.score)")
        }
    }
}

func getTitleText() -> String {
    @ObservedObject var hexagonModel: GameModel = model
    let nGW = hexagonModel.guessedWords.reversed().map {fW(word: $0)}
    let text = nGW.joined(separator: " ")
    return text.count > 0 ? (text.count > 30 ? (Array(text)[27] == " " ? text.prefix(25) + "..." : text.prefix(27) + "...") : text) : "No Words"
}

func fW(word: String) -> String {
    return word.prefix(1) + word.dropFirst().lowercased()
}

struct WordsView: View {
    @ObservedObject var hexagonModel: GameModel = model
    @Binding var isExpanded: Bool
    var titleText: String = getTitleText()
    
    var body: some View {
        var leftCount: Int = model.stringWords.count <= 30 ? (model.stringWords.count <= 15 ? model.stringWords.count : 15) : model.stringWords.count / 2 + 1
        var rightCount: Int = model.stringWords.count - leftCount
        return DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                ScrollView {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(0..<leftCount) { index in
                                let word = model.stringWords.sorted()[index]
                                HStack(alignment: .top) {
                                    if model.guessedWords.contains(word) {
                                        if model.pangramWords.contains(word) {
                                            Text(fW(word: word))
                                                .bold()
                                                .foregroundColor(Color.green)
                                        } else {
                                            Text(fW(word: word))
                                                .foregroundColor(Color("ACC2"))
                                                .bold()
                                        }
                                    } else {
                                        Text(word.prefix(2))
                                            .foregroundColor(Color("ACC2"))
                                    }
                                    Spacer()
                                }
                            }
                        }
                        if rightCount > 0 {
                            VStack(alignment: .leading, spacing: 3) {
                                ForEach(0..<rightCount) { index in
                                    let word = model.stringWords.sorted().suffix(from: leftCount)[leftCount + index]
                                    HStack(alignment: .top) {
                                        if model.guessedWords.contains(word) {
                                            if model.pangramWords.contains(word) {
                                                Text(fW(word: word))
                                                    .bold()
                                                    .foregroundColor(Color.green)
                                            } else {
                                                Text(fW(word: word))
                                                    .foregroundColor(Color("ACC2"))
                                                    .bold()
                                            }
                                        } else {
                                            Text(word.prefix(2))
                                                .foregroundColor(Color("ACC2"))
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: 450)
                .padding(.top, 10)
            },
            label: {
                Text(isExpanded ? "You have found \(model.guessedWords.count) words" : titleText)
            }
        )
            .accentColor(Color("ACC2"))
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("ACC"))
            )
            .padding()
    }
}

struct PopUp: View {
    @State var score: Int
    @State var text: String
    var body: some View {
        HStack(spacing: 6) {
            if model.popUpGood {
                Text(text)
                    .padding(10)
                    .background(Color("ACC"))
                    .foregroundColor(Color("ACC2"))
                    .font(.system(size: 15, weight: (text == "Pangram! LEGEND!" ? .bold : .regular)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray)
                    )
                Text("+\(score)")
                    .foregroundColor(Color("ACC2"))
                    .bold()
            } else {
                Text(text)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color("ACC2"))
                    )
                    .foregroundColor(Color("ACC"))
                    .font(.system(size: 15))
            }
        }
    }
}

struct HiveView: View {
    @ObservedObject var hexagons: GameModel = model
    @State var expanded: Bool = false
    @GestureState var deletePressed: Bool = false
    @GestureState var enterPressed: Bool = false
    @GestureState var rotatePressed: Bool = false
    var body: some View {
        
        ZStack {
            Color("ACC")
                .edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let radius: CGFloat = CGFloat(Int(0.93 * 2 * (hexagonWidth / 2)))
                let xOffset: CGFloat = CGFloat(Int(0.875 * radius))
                
                let xCenter = geometry.size.width / 2
                let yCenter = geometry.size.height / 2
                let buttonYOffset = 200.0
                let positions: [CGPoint] = [
                    CGPoint(x: xCenter, y: yCenter),
                    CGPoint(x: xCenter - xOffset, y: yCenter - radius / 2),
                    CGPoint(x: xCenter, y: yCenter - radius),
                    CGPoint(x: xCenter + xOffset, y: yCenter - radius / 2),
                    CGPoint(x: xCenter + xOffset, y: yCenter + radius / 2),
                    CGPoint(x: xCenter, y: yCenter + radius),
                    CGPoint(x: xCenter - xOffset, y: yCenter + radius / 2)
                ]
                
                
                ZStack(alignment: .top) {
                    Text(String(model.score))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Circle()
                            .fill(Color.green))
                        .offset(x: 0, y: 30)
                    ForEach(0..<7) { index in
                        model.hexagons.reversed()[index]
                            .position(positions.reversed()[index])
                    }
                    let buttonSpacing: CGFloat = 80.0
                    RotateButton()
                        .background(
                            Circle()
                                .fill(rotatePressed ? Color.green : Color("ACC"))
                            .scaleEffect(2.2)
                    )
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.gray)
                        )
                        .position(x: xCenter, y: yCenter + buttonYOffset)
                        .gesture(LongPressGesture(minimumDuration: 1)
                            .updating($rotatePressed) { value, state, transcation in
                                state = value
                                withAnimation {model.shuffle()}
                            }
                        )
                    DeleteButton()
                        .frame(width: 80, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 30.0)
                                .fill(deletePressed ? Color.green : Color("ACC"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30.0)
                                .stroke(Color.gray)
                        )
                        .position(x: (xCenter - buttonSpacing), y: yCenter + buttonYOffset)
                        .gesture(LongPressGesture(minimumDuration: 1)
                            .updating($deletePressed) { value, state, transcation in
                                state = value
                                withAnimation {model.deleteLetter()}
                            }
                        )
                    EnterButton()
                        .frame(width: 80, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 30.0)
                                .fill(enterPressed ? Color.green : Color("ACC"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30.0)
                                .stroke(Color.gray)
                        )
                        .position(x: (xCenter + buttonSpacing), y: yCenter + buttonYOffset)
                        .gesture(LongPressGesture(minimumDuration: 1)
                            .updating($enterPressed) { value, state, transcation in
                                state = value
                                withAnimation {
                                    model.checkGuess();
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                    }
                                }
                            }
                        )
                    TextBox()
                        .position(x: screenWidth / 2, y: yCenter - buttonYOffset)
                    if model.showPopUp {
                        PopUp(score: model.popUpScore, text: model.popUpText)
                            .position(x: xCenter, y: model.popUpY)
                            .offset(x: 0, y: -model.popUpYOffset)
                            .onReceive(model.timer) { _ in
                                if model.popUpGood {
                                    model.popUpYOffset += 0.2
                                }
                            }
                    }
                    Button(action: {withAnimation{model.startNewGame()}}, label: {Text("New Game")
                            .foregroundColor(Color.white)
                            .font(.system(size: 15, weight: .bold))
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 30)
                                .fill(Color.green)
                            )
                            
                    })
                    //800
                        .position(x: xCenter, y: yCenter + 320)
                    if expanded {
                        Button(action:
                                {withAnimation {expanded = false}}, label: {
                            Rectangle()
                                .fill(Color.black.opacity(0))
                        }
                               )
                    }
                    WordsView(isExpanded: $expanded)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray)
                                .padding(.all, 15)
                        )
                        .offset(x: 0, y: 80)
                        .statusBar(hidden: false)
                    
                }
            }
        }
    }
}


struct HiveView_Previews: PreviewProvider {
    static var previews: some View {
        HiveView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}
