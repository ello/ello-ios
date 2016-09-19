import Ello
import Quick
import Nimble


class CoderSpec: QuickSpec {
    override func spec() {

        var filePath = ""
        if let url = NSURL(string: NSFileManager.ElloDocumentsDir()) {
            filePath = url.URLByAppendingPathComponent("DecoderSpec")!.absoluteString!
        }

        afterEach {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filePath)
            }
            catch {

            }
        }

        it("encodes and decodes required properties") {
            let obj = CoderSpecFake(stringProperty: "prop1", intProperty: 123, boolProperty: true)
            NSKeyedArchiver.archiveRootObject(obj, toFile: filePath)
            let unArchivedObject = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! CoderSpecFake
            expect(unArchivedObject.stringProperty) == "prop1"
            expect(unArchivedObject.intProperty) == 123
            expect(unArchivedObject.boolProperty) == true
            expect(unArchivedObject.optionalStringProperty).to(beNil())
            expect(unArchivedObject.optionalIntProperty).to(beNil())
            expect(unArchivedObject.optionalBoolProperty).to(beNil())
        }

        it("encodes and decodes optional properties") {
            let obj = CoderSpecFake(stringProperty: "prop1", intProperty: 123, boolProperty: true)
            obj.optionalStringProperty = "optionalString"
            obj.optionalIntProperty = 666
            obj.optionalBoolProperty = true
            NSKeyedArchiver.archiveRootObject(obj, toFile: filePath)
            let unArchivedObject = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! CoderSpecFake
            expect(unArchivedObject.stringProperty) == "prop1"
            expect(unArchivedObject.intProperty) == 123
            expect(unArchivedObject.boolProperty) == true
            expect(unArchivedObject.optionalStringProperty) == "optionalString"
            expect(unArchivedObject.optionalIntProperty) == 666
            expect(unArchivedObject.optionalBoolProperty) == true
        }
    }
}


class CoderSpecFake: NSObject {
    let stringProperty: String
    let intProperty: Int
    let boolProperty: Bool
    var optionalStringProperty: String?
    var optionalIntProperty: Int?
    var optionalBoolProperty: Bool?

    init(stringProperty: String, intProperty: Int, boolProperty: Bool) {
        self.stringProperty = stringProperty
        self.intProperty = intProperty
        self.boolProperty = boolProperty
    }

    func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(stringProperty, forKey: "stringProperty")
        coder.encodeObject(intProperty, forKey: "intProperty")
        coder.encodeObject(boolProperty, forKey: "boolProperty")
        coder.encodeObject(optionalStringProperty, forKey: "optionalStringProperty")
        coder.encodeObject(optionalIntProperty, forKey: "optionalIntProperty")
        coder.encodeObject(optionalBoolProperty, forKey: "optionalBoolProperty")
    }

    init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.stringProperty = decoder.decodeKey("stringProperty")
        self.intProperty = decoder.decodeKey("intProperty")
        self.boolProperty = decoder.decodeKey("boolProperty")

        self.optionalStringProperty = decoder.decodeOptionalKey("optionalStringProperty")
        self.optionalIntProperty = decoder.decodeOptionalKey("optionalIntProperty")
        self.optionalBoolProperty = decoder.decodeOptionalKey("optionalBoolProperty")
    }
}
