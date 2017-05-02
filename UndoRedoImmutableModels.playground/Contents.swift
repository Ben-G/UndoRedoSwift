//: Playground - noun: a place where people can play

import Cocoa

enum Color {
    case red
    case blue
}

class DB {
    var state: Set<Annotation> = []

    init() {}

    func saveAnnotation(annotation: Annotation) {
        // Replace old with new
        self.state.remove(annotation)
        self.state.insert(annotation)
    }
}

class AnnotationStore {

    var db: DB

    init(db: DB) {
        self.db = db
    }

    var state: Set<Annotation> = []

    func save(annotation: Annotation) {
        // Replace old with new
        self.state.remove(annotation)
        self.state.insert(annotation)
        self.db.saveAnnotation(annotation: annotation)
    }

    func undo() {

    }

    func redo() {

    }

}

struct Annotation: Hashable, Equatable {
    let id: UUID
    let color: Color

    private init(id: UUID, color: Color) {
        self.id = id
        self.color = color
    }

    init(color: Color) {
        self.id = UUID()
        self.color = color
    }

    func changeColor(color: Color) -> Annotation {
        return Annotation(
            id: self.id,
            color: color
        )
    }

    var hashValue: Int {
        return self.id.hashValue
    }

    static func ==(lhs: Annotation, rhs: Annotation) -> Bool {
        return lhs.id == rhs.id
    }
}

let db = DB()
let store = AnnotationStore(db: db)

let annotation = Annotation(color: .red)
store.save(annotation: annotation)
let updatedAnnotation = annotation.changeColor(color: .blue)
store.save(annotation: updatedAnnotation)

print(store.state)
print(db.state)
