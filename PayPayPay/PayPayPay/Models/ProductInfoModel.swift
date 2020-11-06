//
//  ProductInfoModel.swift
//  SwiftModul
//
//  Created by wangsicheng on 2019/8/29.
//  Copyright © 2019 fenrir-cd. All rights reserved.
//

import UIKit

struct ProductInfoModel: Equatable, Codable, Identifiable {

    public var id: String?
    
    public var name: String?

    public var image: String?

    public var originalPrice: String?

    public var price: String?

    public var sold: Int?

    public var barcode: String?

    public var shopCarCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: self.id!)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: self.id!)
        }

    }

    public var isSelected: Bool {
        get {
            return UserDefaults.standard.bool(forKey: self.id! + goodSelectedKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: self.id! + goodSelectedKey)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case originalPrice = "original_price"
        case price
        case image
        case sold
        case barcode
    }
    
    static func == (lhs: ProductInfoModel, rhs: ProductInfoModel) -> Bool {
        return lhs.id == rhs.id
    }

}

extension ProductInfoModel: ProductInfoProtocal {

    var shopCarCountStr: String {
        return "\(self.shopCarCount)"
    }

    var soldStr: String {
        return "已售: \(self.sold ?? 0)"
    }

    var goodNameStr: String? {
        return self.name
    }

    var oriPriceStr: String {
        return  "￥\(self.originalPrice ?? "")"
    }

    var priceStr: String {
        return "￥\(self.price ?? "")"
    }

    var imageUrl: URL? {
        guard let image = self.image else {
            return nil
        }
        let imageUrl = APIConst.basePath + "/image/\(image)"
        return URL(string: imageUrl)
    }

}

//modelProtocal
protocol ProductInfoProtocal {

    var goodNameStr: String? { get }
    var imageUrl: URL? { get }
    var oriPriceStr: String { get }
    var priceStr: String { get }
    var soldStr: String { get }
    var shopCarCountStr: String { get }
}
