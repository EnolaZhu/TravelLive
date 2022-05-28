# TravelLive

<p align="center">
  <img width="150" height="150" src="https://imgur.com/LFv96UR.png">
</p>

<h5 align="center">An instant live stream that allows you to travel around the world at home.</h5>

<p align="center">
   <img src="https://img.shields.io/badge/platform-iOS-blue?style=flat-square"> 
   <img src="https://img.shields.io/badge/release-v1.0-brightgreen?style=flat-square"> 
</p>

<p align="center">
	<a href="https://apps.apple.com/tw/app/travellive/id1619736503">
<img src="https://i.imgur.com/Olh4CyC.png" width="120" height="40"/>
</a></p>

</br></br>

## Features
#### Start streaming
>  Start sharing your life and show subtitles by STT
> 
>  Accomplished multiplayer online chat room
> 
>  Synchronized showing animation

<img src="https://imgur.com/02oow1m.gif" width="150"/>


#### Start viewing
> Positions you on the location of the streamer closest to you

<img src="https://imgur.com/OT9whgq.png" width="150"/>


> Send heart animation

<img src="https://imgur.com/J4gJXWq.png" width="150"/>

#### Discover nearby attractions and activities
> Recommend nearby attractions based on your location dynamically

<img src="https://imgur.com/aHYnOHH.png" width="150"/> 

> Click to view details

<img src="https://i.imgur.com/Zot71RK.gif" width="150"/> 

#### Provides recommendations for attractions in specific cities
> Go to the second tab and click to view details

<img src="https://imgur.com/uvBsd41.png" width="150"/>

#### Explore user posts

> Search specific content with automatic tag by ML Kit

<img src="https://imgur.com/GtZEuRA.gif" width="150"/>

> Comment and like

<img src="https://imgur.com/QwNrLYP.png" width="150"/> 

> Go into video wall

<img src="https://imgur.com/vx4PW6l.gif" width="150"/> 

#### Share your travel

> Show your properties and content you've liked

<img src="https://imgur.com/yf2jpMl.gif" width="150"/>

## Technical Highlights
- Used **`MVC`** and **`OOP`** design patterns to achieve expandable, readable, and maintainable program structure.
- Built APP UI in **`Storyboard`**, **`xib`**, and **`programmatically`**.
- **`Debounce`** animation events and **`filtered`** data by **`RxSwift`**, preventing multiple consecutive clicks effectively
- Accomplished multiplayer synchronization of real-time subtitles by **`STT`** during live-streaming
- **`Synchronized`** showing animation and chat messages during live-streaming
- Encoding and decoding through **`PubNub`** to complete multi-party instant synchronous transmission
- Implemented Google **`Analytics`**, collecting the user streaming counts
- Added tags on images automatically by **`Google ML Kit`** identification, providing accurate and real-time labels
- Applied **`Google Maps SDK`** for fetching and updating streamer’s locations
- Accomplished multiplayer **`online chat room`**, providing real-time communication
- Shared the live-streaming with a **`dynamic link`** by viewers
- Integrated **`Crashlytics`** for app crash tracking, improving stability
- Implemented global **`Firebase Notification`** to notify users when the streamer starts streaming
- Implement a TikTok-like video wall with **`AVFoundation`**, providing a swipe gesture for viewing collections of videos
- Implemented live room recording by **`ReplayKit`**, recording live moments and preparing materials for the video wall
- Utilized Firebase Storage and Firestore for data management
- Fetched open data from government through **`RESTful APIs`**, displaying nearby attractions and activities
- Implemented **`Sign in with Apple`** for the login process, protecting user privacy

## Libraries
- [mobile-ffmpeg-full 4.4](https://github.com/tanersener/mobile-ffmpeg)
- [RxSwift 6.5.0](https://github.com/ReactiveX/RxSwift)
- [PubNub 4](https://www.pubnub.com/)
- [TXLiteAVSDK_Professional](https://cloud.tencent.com/document/product/454/7873)
- [GoogleMaps](https://developers.google.com/maps?hl=zh-tw)
- [Google-Mobile-Ads-SDK](https://developers.google.com/admob/ios/download)
- [GoogleMLKit/ImageLabeling 2.6.0](https://developers.google.com/ml-kit/vision/image-labeling/ios)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [Firebase](https://firebase.google.com)
- [MJRefresh](https://github.com/CoderMJLee/MJRefresh)
- [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager)
- [lottie-ios](https://github.com/airbnb/lottie-ios)
- [Toast-Swift 5.0.1](https://github.com/scalessec/Toast-Swift)
- [SwiftLint](https://github.com/realm/SwiftLint)

## Requirement
- Swift 5.0
- Xcode 13.0
- iOS 13.0 or higher

## Contact
Enola Zhu enola0314@gmail.com

## License
MIT License

Copyright (c) 2022 Enola Zhu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
