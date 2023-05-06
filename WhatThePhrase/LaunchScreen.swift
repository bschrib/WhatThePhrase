import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Image("LaunchImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
