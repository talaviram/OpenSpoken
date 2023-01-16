import Speech
import SwiftUI

class Settings: ObservableObject {
    @Published var fontSize: CGFloat = 40.0 {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }

    @Published var useLocale: Bool = true {
        didSet {
            UserDefaults.standard.set(useLocale, forKey: "useLocale")
        }
    }

    @Published var transcribeLanguage: String = "en-US" {
        didSet {
            UserDefaults.standard.set(transcribeLanguage, forKey: "locale")
        }
    }

    @Published var offlineTranscribe: Bool = false {
        didSet {
            UserDefaults.standard.set(offlineTranscribe, forKey: "offlineTranscribe")
        }
    }

    @Published var layoutDirection = LayoutDirection.leftToRight

    @ObservedObject static var instance: Settings = Settings()

    init() {
        load()
    }

    deinit {
        save()
    }

    private let fontStep = CGFloat(2)

    public func increaseFont() {
        fontSize = min(fontSize + fontStep, CGFloat(180.0))
    }

    public func decreaseFont() {
        fontSize = max(fontSize - fontStep, CGFloat(12.0))
    }

    public static func getLanguageIdentifierLocaleOrFallback(_ identifier: String?) -> String {
        let desiredLocale = Locale(identifier: identifier ?? Locale.current.identifier)
        if !SFSpeechRecognizer.supportedLocales().contains(desiredLocale) {
            return "en-US"
        } else {
            return desiredLocale.identifier
        }
    }

    public func currentLanguageAsText() -> String {
        let language = Locale(identifier: transcribeLanguage)
        return language.localizedString(forLanguageCode: language.languageCode ?? "en") ?? "Language"
    }

    public static func getDirectionForLocale(_ identifier: String) -> LayoutDirection {
        if Locale.characterDirection(forLanguage: identifier) == .rightToLeft {
            return .rightToLeft
        } else {
            return .leftToRight
        }
    }

    public func save() {
        let storage = UserDefaults.standard
        storage.set(fontSize, forKey: "fontSize")
        storage.set(useLocale, forKey: "useLocale")
        storage.set(transcribeLanguage, forKey: "locale")
        storage.set(offlineTranscribe, forKey: "offlineTranscribe")
    }

    private func load() {
        let storage = UserDefaults.standard
        fontSize = CGFloat(storage.optionalFloat(forKey: "fontSize") ?? 40.0)
        useLocale = storage.optionalBool(forKey: "useLocale") ?? true
        if useLocale {
            transcribeLanguage = Settings.getLanguageIdentifierLocaleOrFallback(nil)
        } else {
            transcribeLanguage = storage.string(forKey: "locale") ?? "en-US"
        }
        layoutDirection = Settings.getDirectionForLocale(transcribeLanguage)
        offlineTranscribe = storage.optionalBool(forKey: "offlineTranscribe") ?? false
    }
}

private func getLocaleString(_ locale: Locale) -> String {
    let language = locale.localizedString(forLanguageCode: locale.languageCode ?? "") ?? ""
    let country = locale.localizedString(forRegionCode: locale.regionCode ?? "") ?? ""
    if country.isEmpty { return language }
    else {
        return "\(language) (\(country))"
    }
}

struct LanguageView: View {
    let onLanguageSelected: (_ language: String?) -> Void
    let onDismiss: () -> Void
    @State var selectedLanguage: String
    private let supportedLocale = SFSpeechRecognizer.supportedLocales()
    var body: some View {
        NavigationView {
            List {
                Button("Use Locale", action: {
                    Settings.instance.useLocale = true
                    onLanguageSelected(nil)
                })
                Section {
                    ForEach(supportedLocale.sorted { $0.identifier < $1.identifier }, id: \.self.identifier) {
                        locale in
                        let isSelected = Settings.instance.transcribeLanguage == locale.identifier
                        HStack {
                            Text(getLocaleString(locale))
                            if isSelected {
                                Spacer()
                                Image(systemName: "mic")
                            }
                        }
                        .foregroundColor(isSelected ? Color.accentColor : Color.primary)
                        .onTapGesture {
                            onLanguageSelected(locale.identifier)
                        }
                    }
                }
                Section {
                    Toggle("On-Device Only", isOn: Settings.$instance.offlineTranscribe)
                }
            }
            .navigationBarItems(leading: Button(action: {
                self.onDismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.backward")
                    Text("Cancel")
                }
            })
        }
    }
}

struct LanguageMenu: View {
    var notifyLanguageChanged: () -> Void
    @State private var isVisible = false
    @ObservedObject private var settings = Settings.instance
    func onSelected(_ newLanguage: String?) {
        settings.useLocale = newLanguage == nil
        settings.transcribeLanguage = Settings.getLanguageIdentifierLocaleOrFallback(newLanguage)
        settings.layoutDirection = Settings.getDirectionForLocale(settings.transcribeLanguage)
        isVisible = false
        notifyLanguageChanged()
    }

    var body: some View {
        Button(Settings.instance.currentLanguageAsText(), action: { isVisible = true }).sheet(isPresented: $isVisible) {
            LanguageView(onLanguageSelected: onSelected, onDismiss: { self.isVisible = false }, selectedLanguage: Settings.instance.transcribeLanguage)
        }
    }
}

struct FontToolbar: View {
    func increase() {
        Settings.instance.increaseFont()
    }

    func decrease() {
        Settings.instance.decreaseFont()
    }

    var body: some View {
        Group {
            HStack {
                Button("-", action: { Settings.instance.decreaseFont() })
                Image(systemName: "textformat.size")
                Button("+", action: { Settings.instance.increaseFont() })
            }.buttonStyle(.plain)
        }
        .frame(width: 120)
    }
}

// https://stackoverflow.com/a/53127813
extension UserDefaults {
    public func optionalFloat(forKey defaultName: String) -> Float? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Float
        }
        return nil
    }

    public func optionalBool(forKey defaultName: String) -> Bool? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Bool
        }
        return nil
    }
}
