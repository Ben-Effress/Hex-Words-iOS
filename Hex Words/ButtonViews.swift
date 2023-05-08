import SwiftUI

struct DeleteButton: View {
    let width: CGFloat = 0
    let height: CGFloat = 0
    let padding: CGFloat = 20.0
    var body: some View {
        Text("Delete")
            .foregroundColor(Color("ACC2"))
    }
}

struct EnterButton: View {
    let width: CGFloat = 0
    let height: CGFloat = 0
    let padding: CGFloat = 20.0
    var body: some View {
        Text("Enter")
            .foregroundColor(Color("ACC2"))
    }
}

struct RotateButton: View {
    @GestureState var localIsPressed: Bool = false
    var width: CGFloat = 50.0
    let height: CGFloat = 50.0
    let padding: CGFloat = 30.0
    var body: some View {
        Image("Rotate")
            .resizable()
            .renderingMode(.original)
            .frame(width: width - padding, height: height - padding)
    }
}

struct ButtonViews_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButton()
    }
}
