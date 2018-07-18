////
///  GQLVariable.swift
//

struct GQLVariable {
    let type: String
    let name: String
    let value: Any?

    static func string(_ name: String, _ value: String) -> GQLVariable          { return GQLVariable(type: "String!", name: name, value: value) }
    static func optionalString(_ name: String, _ value: String?) -> GQLVariable { return GQLVariable(type: "String", name: name, value: value) }
    static func id(_ name: String, _ value: String) -> GQLVariable              { return GQLVariable(type: "ID!", name: name, value: value) }
    static func optionalID(_ name: String, _ value: String?) -> GQLVariable     { return GQLVariable(type: "ID", name: name, value: value) }
    static func int(_ name: String, _ value: Int) -> GQLVariable                { return GQLVariable(type: "Int!", name: name, value: value) }
    static func optionalInt(_ name: String, _ value: Int?) -> GQLVariable       { return GQLVariable(type: "Int", name: name, value: value) }
    static func float(_ name: String, _ value: Float) -> GQLVariable            { return GQLVariable(type: "Float!", name: name, value: value) }
    static func optionalFloat(_ name: String, _ value: Float?) -> GQLVariable   { return GQLVariable(type: "Float", name: name, value: value) }
    static func bool(_ name: String, _ value: Bool) -> GQLVariable              { return GQLVariable(type: "Bool!", name: name, value: value) }
    static func optionalBool(_ name: String, _ value: Bool?) -> GQLVariable     { return GQLVariable(type: "Bool", name: name, value: value) }
    static func `enum`(_ name: String, _ value: Any, _ type: String) -> GQLVariable { return GQLVariable(type: "\(type)!", name: name, value: value) }
    static func optionalEnum(_ name: String, _ value: Any?, _ type: String) -> GQLVariable { return GQLVariable(type: type, name: name, value: value) }
}
