//
//  FontStyle.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI

enum FontStyle {
    static func placeholder() -> Font {
        Font(
            UIFont.systemFont(
                ofSize: 24,
                weight: .medium,
                width: .condensed
            )
        )
    }
    
    static func kilometer() -> Font {
        Font(
            UIFont.systemFont(
                ofSize: 24,
                weight: .heavy,
                width: .condensed
            )
        )
    }
    
    static func button() -> Font {
        Font(
            UIFont.systemFont(
                ofSize: 24,
                weight: .semibold,
                width: .condensed
            )
        )
    }
    
    static func miniPlaceholder() -> Font {
        Font(
            UIFont.systemFont(
                ofSize: 12,
                weight: .medium,
                width: .condensed
            )
        )
    }
    
    static func cellTitle() -> Font {
        Font(
            UIFont.systemFont(
                ofSize: 32,
                weight: .black,
                width: .condensed
            )
        )
    }
    
    static func cellSubtitle() -> Font {
        Font(
            UIFont.systemFont(
                ofSize: 15,
                weight: .medium,
                width: .condensed
            )
        )
    }
    
    static func hallOfFame() -> Font {
        Font(
            UIFont.systemFont(
                ofSize: 32,
                weight: .bold,
                width: .condensed
            )
        )
    }
    
    static func myPageCell() -> Font {
        Font(
            UIFont.systemFont(
                ofSize: 24,
                weight: .bold,
                width: .condensed
            )
        )
    }
}

