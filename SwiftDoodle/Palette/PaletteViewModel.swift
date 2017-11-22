public class PaletteViewModel {
    public enum Tool {
        case pencil
        case eraser
    }

    var tool: Tool
    var color: UIColor
    var width: Float
    var backgroundColor: UIColor

    var drawColor: UIColor {
        switch tool {
        case .pencil:
            return color
        case .eraser:
            return backgroundColor
        }
    }

    public init(color: UIColor, width: Float, tool: Tool, backgroundColor: UIColor) {
        self.color = color
        self.width = width
        self.tool = tool
        self.backgroundColor = backgroundColor
    }
}
