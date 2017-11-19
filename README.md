# SwiftDoodle
Drop in draw view written in Swift. Drawing is done using modified [TouchCanvas](https://developer.apple.com/library/content/samplecode/TouchCanvas/Introduction/Intro.html#//apple_ref/doc/uid/TP40016561-Intro-DontLinkElementID_2)

Supports coalesced, predicted and estimated touches. 

## Usage

Drawing is done using CanvasView.

```Swift
view = CanvasView(frame: view.frame)
```
