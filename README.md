<h1 align="center">
    <img src="https://raw.githubusercontent.com/talaviram/OpenSpoken/main/Media/OpenSpoken_Icon_1024x1024.png" alt="OpenSpoken Logo" width="20%"/>
    <br>
    <p>Open Spoken</p>
    <br>
</h1>

<h4 align="center">Live transcription of audio from microphone for iOS/iPadOS and macOS</h4>
<br>

## Description

I've made this app since due to personal need of a family member with hearing problems.
It simply gets the audio from the microphone and transcribes it to text using [Apple's Speech Recognition framework](https://developer.apple.com/documentation/speech/sfspeechrecognizer).

The app should support many languages (as long as they're available within Apple's Speech Recognition).

# Requirements

- iOS/iPadOS 13 or newer.
- macOS 11 (Big Sur) or newer. (native Apple silicon and Intel support)

<img src="https://raw.githubusercontent.com/talaviram/OpenSpoken/main/Media/screenshot_macOS.jpg" alt="Open Spoken Screenshot on macOS" />

## Tech-bits

- The app uses Apple's Catalyst to support most of Apple devices.
- It uses SwiftUI.
- It also has a Playground project to support development and experimenting also on the iPad.
