public protocol FromNib {
    static var viewFromNib: Self { get }
}

extension FromNib {
    public static var viewFromNib: Self {
        if let view = Bundle(for: DrawView.self)
            .loadNibNamed(String(describing: Self.self), owner: nil, options: nil)?
            .last as? Self {
            return view
        } else {
            fatalError("Nib named \(String(describing: Self.self)) could not be loaded")
        }
    }
}
