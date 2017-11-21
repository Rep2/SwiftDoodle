public class PaletteViewModel {
    public enum Tool {
        case pencil
        case eraser
    }

    var tool: Tool
    var color: UIColor
    var width: Float

    public init(color: UIColor, width: Float, tool: Tool) {
        self.color = color
        self.width = width
        self.tool = tool
    }
}
