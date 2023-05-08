import SwiftUI

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let vertexRadius = min(rect.width, rect.height) / 2.0
        
        var path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y - vertexRadius))
        for i in stride(from: 0, to: 361, by: 60) {
            let x = center.x + vertexRadius * cos(Angle.degrees(Double(i)).radians)
            let y = center.y + vertexRadius * sin(Angle.degrees(Double(i)).radians)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.closeSubpath()
        
        return path
    }
}

struct Hexagon: View {
    var center: Bool
    var letter: String
    @GestureState private var isPressed = false
    @State private var scale: CGFloat = 1
    let pressedScale: CGFloat = 0.85
    
    var body: some View {
        HexagonShape()
            .fill(isPressed ? Color.green : (center ? Color.green : Color("ACC2")))
            .frame(width: hexagonWidth, height: hexagonWidth)
            .scaleEffect(scale * (isPressed ? pressedScale : 1))
            .gesture(LongPressGesture(minimumDuration: 100)
                .updating($isPressed) { value, state, transcation in
                        state = value
                    withAnimation {model.addLetter(letter: self.letter)}
                            }
                        )
            .overlay(
                Text(letter)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("ACC"))
            )
    }
}

struct HexagonShape_Previews: PreviewProvider {
    static var previews: some View {
        HexagonShape()
    }
}
