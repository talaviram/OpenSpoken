import ScrollViewProxy
import SwiftUI

struct ContentView: View {
  @ObservedObject var settings = Settings.instance
  @ObservedObject var transcriber = SpeechCore()
  @State private var result = 0

  @State var shouldScroll = false

  var body: some View {
    VStack(spacing: 0) {
      GeometryReader { scrollGeometry in
        ScrollView {
          proxy in
          Text(transcriber.transcribedText)
            .font(.system(size: settings.fontSize))
            .frame(maxWidth: .infinity, alignment: .leading).environment(
              \.layoutDirection, settings.layoutDirection
            )
            .background(
              GeometryReader { (textGeometry: GeometryProxy) in
                HStack {}
                  .onReceive(
                    transcriber.transcribedText.publisher.first(),
                    perform: { _ in
                      if textGeometry.size.height > scrollGeometry.size.height {
                        proxy.scrollTo(.bottom)
                      }
                    })
              })
        }
      }
      if let errorText = transcriber.error {
        Text(errorText).font(.system(size: 25)).foregroundColor(Color.black)
          .padding()
          .fixedSize(horizontal: false, vertical: true)
          .background(Color.red.opacity(0.9))
          .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
      }
      Spacer()
      HStack {
        FontToolbar().padding()
        Spacer()
        Group {
          if transcriber.isRunning {
            HStack {
              Button(
                action: { transcriber.restart() },
                label: {
                  Image(systemName: "clear.fill").foregroundColor(.yellow)
                }
              )
              .padding()
              Button(
                action: { transcriber.tryStop() },
                label: {
                  Image(systemName: "stop.fill").foregroundColor(.red)
                }
              )
              .padding()
              Spacer()
              ProgressView()
            }
          } else {
            Button(
              action: { transcriber.restart() },
              label: {
                Image(systemName: "mic.fill")
              }
            ).disabled(transcriber.error != nil)
              .padding()
          }
          Spacer()
          LanguageMenu(notifyLanguageChanged: {
            if !self.transcriber.isRunning { return }
            self.transcriber.restart()
          }).padding()
        }
      }.disabled(!transcriber.isAvailable)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
