
import UIKit

class DashedBorderView: UIView {

    let _border = CAShapeLayer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    init() {
        super.init(frame: .zero)
        setup()
    }

    func setup() {
        _border.strokeColor = UIColor.white.cgColor
        _border.fillColor = nil
        _border.lineDashPattern = [20, 10]
        _border.lineWidth = 2
        self.layer.addSublayer(_border)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        _border.path = UIBezierPath(roundedRect: self.bounds, cornerRadius:12).cgPath
        _border.frame = self.bounds
    }
}
