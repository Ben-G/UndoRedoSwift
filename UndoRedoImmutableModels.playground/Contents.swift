//: Playground - noun: a place where people can play

import Cocoa

enum Color {
    case red
    case blue
    case yellow
}

class DB {
    var state: Set<Annotation> = []

    init() {}

    func saveAnnotation(annotation: Annotation) {
        // Replace old with new
        self.state.remove(annotation)
        self.state.insert(annotation)
    }

    func delete(annotation: Annotation) {
        self.state.remove(annotation)
    }

}

struct UndoStep<T> {
    let oldValue: T?
    let newValue: T?

    func flip() -> UndoStep<T> {
        return UndoStep(oldValue: self.newValue, newValue: self.oldValue)
    }
}

class AnnotationStore {

    var db: DB

    init(db: DB) {
        self.db = db
    }

    var state: Set<Annotation> = []

    var undoStack: [UndoStep<Annotation>] = []
    var redoStack: [UndoStep<Annotation>] = []

    func annotationById(annotationId: UUID) -> Annotation? {
        return self.state.filter { $0.id == annotationId }.first
    }

    func save(annotation: Annotation, isUndoRedo: Bool = false) {
        if !isUndoRedo {
            // Fetch old value
            let oldValue = self.annotationById(annotationId: annotation.id)
            // Store change on undo stack
            let undoStep = UndoStep(oldValue: oldValue, newValue: annotation)
            self.undoStack.append(undoStep)

            // Reset redo stack
            self.redoStack = []
        }

        // Replace old with new
        self.state.remove(annotation)
        self.state.insert(annotation)
        self.db.saveAnnotation(annotation: annotation)
    }

    func delete(annotation: Annotation) {
        self.state.remove(annotation)
        self.db.delete(annotation: annotation)
    }

    func undo() {
        guard let undoStep = self.undoStack.popLast() else {
            return
        }

        if let annotation = undoStep.oldValue {
            self.save(annotation: annotation, isUndoRedo: true)
        } else if let annotation = undoStep.newValue {
            self.delete(annotation: annotation)
        } else {
            fatalError("Undo step with either old nor new value makes no sense")
        }

        self.redoStack.append(undoStep.flip())
    }

    func redo() {
        guard let undoStep = self.redoStack.popLast() else {
            return
        }

        if let annotation = undoStep.oldValue {
            self.save(annotation: annotation, isUndoRedo: true)
        } else if let annotation = undoStep.newValue {
            self.delete(annotation: annotation)
        } else {
            fatalError("Undo step with either old nor new value makes no sense")
        }

        self.undoStack.append(undoStep.flip())
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
let updatedAnnotation2 = annotation.changeColor(color: .yellow)
store.save(annotation: updatedAnnotation2)


func performAndPrint(closure: () -> Void) {
    closure()
    print(store.state)
    print(db.state)
}

print(store.state)
print(db.state)

performAndPrint {
    store.undo()
}

performAndPrint {
    store.undo()
}

performAndPrint {
    store.undo()
}

performAndPrint {
    store.redo()
}

performAndPrint {
    store.redo()
}

performAndPrint {
    store.redo()
}

performAndPrint {
    store.undo()
}

