import SwiftUI

extension View {
    var anyView: AnyView {
        return AnyView(self)
    }
}

extension View {
    func makeErrorView(_ error: String) -> AnyView {
        return VStack {
            Text(error)
        }.anyView
    }
    
    func makeLoadingView() -> AnyView {
        return VStack {
            Text("Loading")
            ActivityIndicator(isAnimating: .constant(true), style: .large)
        }.anyView
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(activityIndicatorStyle: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

