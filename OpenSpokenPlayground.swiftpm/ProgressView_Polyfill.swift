import SwiftUI

struct ProgressViewPolyfill: UIViewRepresentable {

//    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ProgressViewPolyfill>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .medium)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ProgressViewPolyfill>) {
        uiView.startAnimating()
    }
}

