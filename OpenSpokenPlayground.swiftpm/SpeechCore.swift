@preconcurrency import Speech
import SwiftUI

@MainActor public class SpeechCore: ObservableObject {
  @ObservedObject var settings = Settings.instance

  private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "he-IL"))!
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()

  @Published var isRunning = false
  @Published var isAvailable = false
  @Published var error: String?

  @Published var transcribedText = "Tap the start below to begin"

  init() {
    // Asynchronously make the authorization request.
    SFSpeechRecognizer.requestAuthorization { @Sendable authStatus in

      // Divert to the app's main thread so that the UI
      // can be updated.
      Task { @MainActor in
        self.isAvailable = false
        switch authStatus {
        case .authorized:
          self.error = nil
          self.isAvailable = true
        case .denied:
          self.error = "Denied access to speech recognition"

        case .restricted:
          self.error = "Speech recognition restricted on this device"

        case .notDetermined:
          self.error = "Speech recognition not yet authorized"

        default:
          self.error = "Speech unavailble due to unknown reason"
        }
      }
    }
  }

  private func tryToStart() throws {
    speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: settings.transcribeLanguage))!

    // Cancel the previous task if it's running.
    recognitionTask?.cancel()
    recognitionTask = nil

    clear()

    // Configure the audio session for the app.
    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    let inputNode = audioEngine.inputNode

    // Create and configure the speech recognition request.
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    recognitionRequest?.requiresOnDeviceRecognition = self.settings.offlineTranscribe

    guard let request = recognitionRequest else {
      return
    }

    // Create a recognition task for the speech recognition session.
    // Keep a reference to the task so that it can be canceled.
    recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
      var isFinal = false

      guard let result = result else { return }
      // Update the text view with the results.
      let best = result.bestTranscription.formattedString
      isFinal = result.isFinal
      Task { @MainActor in
        self.transcribedText = best
        #if DEBUG
          print(self.transcribedText)
        #endif
      }

      if let error = error {
        Task { @MainActor in
          // Stop recognizing speech if there is a problem.
          self.audioEngine.stop()
          inputNode.removeTap(onBus: 0)

          self.recognitionRequest = nil
          self.recognitionTask = nil

          self.isRunning = false
          self.error =
            "Recognition stopped due to a problem \(error.localizedDescription) isFinal: \(isFinal)"
        }
      }
    }

    // Configure the microphone input.
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    let recognitionRequest = self.recognitionRequest
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
      @Sendable [recognitionRequest] buffer, _ in
      recognitionRequest?.append(buffer)
    }

    audioEngine.prepare()
    try audioEngine.start()
    print("Finished initializing speech recognition")
  }

  public func tryStop() {
    if audioEngine.isRunning {
      audioEngine.stop()
      audioEngine.inputNode.removeTap(onBus: 0)
      recognitionRequest?.endAudio()
      isRunning = false
    }
  }

  public func clear() {
    transcribedText = ""
  }

  public func restart() {
    tryStop()
    do {
      try tryToStart()
    } catch {
      isRunning = false
    }
    isRunning = true
  }
}
