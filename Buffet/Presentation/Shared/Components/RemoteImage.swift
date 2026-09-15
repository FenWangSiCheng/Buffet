import Kingfisher
import SwiftUI

/// The only place in the UI layer that knows how a remote image is fetched and cached.
///
/// Feature views pass a URL and their own placeholder, so replacing the image library stays
/// inside this file instead of reaching every row that shows a picture.
struct RemoteImage<Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let placeholder: () -> Placeholder

    var body: some View {
        KFImage(url)
            .placeholder(placeholder)
            .resizable()
    }
}
