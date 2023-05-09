import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all) // Change this to the background color of your image
                
                Image("LaunchImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
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
