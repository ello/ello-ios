////
///  CategoryPartial.swift
//

class CategoryPartial: NSObject, NSCoding {
    let id: String
    let name: String
    let slug: String

    init(id: String, name: String, slug: String) {
        self.id = id
        self.name = name
        self.slug = slug
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        self.name = decoder.decodeKey("name")
        self.slug = decoder.decodeKey("slug")
    }

    func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(slug, forKey: "slug")
    }
}
