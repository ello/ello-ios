////
///  Mapper.swift
//

struct Mapper {

    static func mapToObjectArray(_ dicts: [[String: Any]], type mappingType: MappingType) -> [Model] {
        return dicts.compactMap { object in
            return mapToObject(object, type: mappingType)
        }
    }

    static func mapToObject(_ object: [String: Any], type mappingType: MappingType) -> Model? {
        guard let jsonable = mappingType.fromJSON?(object) else { return nil }

        if let id = (jsonable as? JSONSaveable)?.tableId {
            ElloLinkedStore.shared.saveObject(jsonable, id: id, type: mappingType)
        }
        return jsonable
    }
}
