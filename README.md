# SwiftDoodle
Easy to use draw tool written in Swift.

Currently supports iPad screen sizes.

## Usage

Simply initialize or extend CanvasViewController.

For more costumization use DrawView with PaletteView.

```Swift
lazy var paletteViewModel: PaletteViewModel = {
    return PaletteViewModel(color: .black, width: 5, tool: .pencil, backgroundColor: self.view.backgroundColor ?? .white)
}()

lazy var canvasView: DrawView = {
    let view = DrawView(scale: UIApplication.shared.keyWindow?.screen.scale ?? 2, paletteViewModel: paletteViewModel)

    view.backgroundColor = .white

    return view
}()

lazy var paletteView: PaletteView = {
    let view = PaletteView.viewFromNib

    view.eventHandler = self
    view.present(viewModel: self.paletteViewModel)

    return view
}()
```

![showcase](https://i.imgur.com/BcDXlbN.png)

Implementation was inspiered by [TouchCanvas](https://developer.apple.com/library/content/samplecode/TouchCanvas/Introduction/Intro.html#//apple_ref/doc/uid/TP40016561-Intro-DontLinkElementID_2)
