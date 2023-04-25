import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        VStack {
            Spacer()
            Image("LaunchImage")
                .resizable()
                .scaledToFit()
                .padding()
            Spacer()
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
