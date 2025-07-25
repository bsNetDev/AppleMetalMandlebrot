import SwiftUI

struct ContentView: View {
    @State private var image: CGImage? = nil

    var body: some View {
        VStack {
            if let img = image {
                Image(decorative: img, scale: 1.0)
                    .interpolation(.none)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView("Computing Mandelbrot Set…")
            }
        }
        .padding()
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                let renderer = MandelbrotRenderer()
                let img = renderer.generateImage(width: 1024, height: 768)
                DispatchQueue.main.async {
                    self.image = img
                }
            }
        }
    }
}
