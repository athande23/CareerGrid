
import SwiftUI

enum CareerGridStyle {
    static let primaryBlue = Color(
        red: 35.0 / 255.0,
        green: 91.0 / 255.0,
        blue: 168.0 / 255.0
    )

    static let background = Color(
        red: 246.0 / 255.0,
        green: 248.0 / 255.0,
        blue: 251.0 / 255.0
    )

    static let surface = Color.white

    static let secondaryText = Color(
        red: 100.0 / 255.0,
        green: 112.0 / 255.0,
        blue: 128.0 / 255.0
    )

    static let border = Color(
        red: 225.0 / 255.0,
        green: 231.0 / 255.0,
        blue: 239.0 / 255.0
    )

    static let success = Color(
        red: 35.0 / 255.0,
        green: 132.0 / 255.0,
        blue: 91.0 / 255.0
    )

    static let cornerRadius: CGFloat = 16
    static let horizontalPadding: CGFloat = 20
}

struct CompanyLogoView: View {
    let companyName: String

    private var initials: String {
        let words = companyName.split {
            $0.isWhitespace
        }

        if words.count >= 2 {
            return String(words.prefix(2).compactMap(\.first))
                .uppercased()
        }

        return String(companyName.prefix(2)).uppercased()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(CareerGridStyle.primaryBlue.opacity(0.10))

            Text(initials)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(CareerGridStyle.primaryBlue)
        }
        .frame(width: 48, height: 48)
        .accessibilityLabel("\(companyName) logo placeholder")
    }
}
