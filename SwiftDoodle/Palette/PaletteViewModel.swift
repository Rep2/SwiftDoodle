public class PaletteViewModel {
    public enum Tool {
        case pencil
        case eraser
    }

    var tool: Tool
    var color: UIColor
    var width: Float
    var backgroundColor: UIColor

    let scale: CGFloat

    public init(color: UIColor, width: Float, tool: Tool, backgroundColor: UIColor, scale: CGFloat) {
        self.color = color
        self.width = width
        self.tool = tool
        self.backgroundColor = backgroundColor
        self.scale = scale
    }

    public init(palletViewModel: PaletteViewModel) {
        self.color = palletViewModel.color
        self.width = palletViewModel.width
        self.tool = palletViewModel.tool
        self.backgroundColor = palletViewModel.backgroundColor
        self.scale = palletViewModel.scale
    }

    static public var basic: PaletteViewModel {
        return PaletteViewModel(
            color: .black,
            width: 5,
            tool: .pencil,
            backgroundColor: .white,
            scale: 2
        )
    }
}
