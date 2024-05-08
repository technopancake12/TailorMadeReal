//ALL CODE IN THIS FILE BY SHARVAY AJIT
import SwiftUI
import UIKit

// Main view that displays a list of saved drawings and allows the user to create new ones.
struct DrawingGalleryView: View {
    @State private var drawings: [Drawing] = [] // Stores the list of drawings.
    @State private var selectedDrawing: Drawing? // The currently selected drawing for editing.

    var body: some View {
        NavigationView {
            VStack {
                // List of drawings, each item is a button to select and edit that drawing.
                List(drawings, id: \.id) { drawing in
                    Button(drawing.name) {
                        selectedDrawing = drawing
                    }
                }

                // Button to create a new drawing.
                Button("Start New Drawing") {
                    let newDrawing = Drawing(name: "New Drawing \(Date())", lines: [])
                    drawings.append(newDrawing)
                    selectedDrawing = newDrawing
                }
            }
            // Presents the drawing editor sheet when a drawing is selected.
            .sheet(item: $selectedDrawing) { drawing in
                DrawingView(drawing: drawing, onSave: { updatedDrawing in
                    // Update the drawing list when the drawing is saved.
                    if let index = drawings.firstIndex(where: { $0.id == updatedDrawing.id }) {
                        drawings[index] = updatedDrawing
                    }
                })
            }
            .navigationBarTitle("My Drawings")
        }
    }
}

// Model representing a drawing.
struct Drawing: Identifiable {
    let id: UUID // Unique identifier for each drawing.
    var name: String // Name of the drawing.
    var lines: [Line] // Lines that make up the drawing.

    init(id: UUID = UUID(), name: String, lines: [Line] = []) {
        self.id = id
        self.name = name
        self.lines = lines
    }
}

// View for creating and editing drawings.
struct DrawingView: View {
    @Environment(\.presentationMode) var presentationMode // Manages the presentation mode of the view.
    var drawing: Drawing // The drawing being edited.
    var onSave: (Drawing) -> Void // Closure called when the drawing is saved.
    @State private var lines: [Line] // The lines currently being drawn.
    @State private var currentColor: Color = .black // Current color for new lines.
    @State private var lineWidth: CGFloat = 2 // Current line width.
    @State private var isErasing = false // Whether the eraser tool is active.

    init(drawing: Drawing, onSave: @escaping (Drawing) -> Void) {
        self.drawing = drawing
        self._lines = State(initialValue: drawing.lines)
        self.onSave = onSave
    }

    var body: some View {
        VStack {
            HStack {
                Button("Back") { // Back button
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
            }
            .padding()

            DrawingControls(currentColor: $currentColor, lineWidth: $lineWidth, isErasing: $isErasing, undoAction: undo, onSave: {
                onSave(Drawing(id: drawing.id, name: drawing.name, lines: lines))
                saveImageToCameraRoll()
                presentationMode.wrappedValue.dismiss()
            })

            Canvas { context, size in
                for line in lines {
                    var path = Path()
                    path.addLines(line.points)
                    context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                }
            }
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    let newPoint = value.location
                    if lines.isEmpty || lines.last!.points.isEmpty {
                        let newLine = Line(points: [newPoint], color: isErasing ? .white : currentColor, lineWidth: lineWidth)
                        lines.append(newLine)
                    } else {
                        lines[lines.count - 1].points.append(newPoint)
                    }
                }
                .onEnded { _ in
                    lines.append(Line(points: [], color: .clear, lineWidth: 0))
                }
            )
        }
    }
    // Undo function for drawing
    private func undo() {
        if !lines.isEmpty {
            lines.removeLast()
        }
    }

    // Function to save the Canvas content as an image to the camera roll.
    private func saveImageToCameraRoll() {
        // Initializes a graphics image renderer with a specific size (400x600 pixels).
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 600))
        
        // Creates an image by rendering content within the given context.
        let image = renderer.image { ctx in
            // Retrieve the current drawing context.
            let context = ctx.cgContext
            
            // Iterate over each line that has been drawn on the canvas.
            for line in lines {
                // Check if the line's color can be converted to a CGColor.
                if let cgColor = line.color.cgColor {
                    // Create a new mutable path for the line.
                    let path = CGMutablePath()
                    
                    // Add a series of points to the path (defining the line).
                    path.addLines(between: line.points)
                    
                    // Add the path to the current context.
                    context.addPath(path)
                    
                    // Set the stroke (line) color in the context.
                    context.setStrokeColor(cgColor)
                    
                    // Set the line width in the context.
                    context.setLineWidth(line.lineWidth)
                    
                    // Draw the path with the current settings (stroke color, line width).
                    context.strokePath()
                }
            }
        }
        
        // Execute the save to the photo album on the main thread to ensure UI operations are safe.
        DispatchQueue.main.async {
            // Saves the rendered image to the device's photo album.
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}

// Represents a single line in a drawing.
struct Line {
    var points: [CGPoint] // Points that make up the line.
    var color: Color // Color of the line.
    var lineWidth: CGFloat // Width of the line.
}

// Controls for adjusting the drawing tools and saving the drawing.
struct DrawingControls: View {
    @Binding var currentColor: Color // Binding to the current drawing color.
    @Binding var lineWidth: CGFloat // Binding to the current line width.
    @Binding var isErasing: Bool // Binding to the erase tool state.
    var undoAction: () -> Void // Closure to call for undoing an action.
    var onSave: () -> Void // Closure to call when saving the drawing.

    var body: some View {
        HStack {
            ColorPicker("Color", selection: $currentColor)
                .onChange(of: currentColor) { _ in isErasing = false }
            Slider(value: $lineWidth, in: 1...10, step: 0.1)
                .onChange(of: lineWidth) { _ in isErasing = false }
            Button(action: { isErasing.toggle() }) {
                Text(isErasing ? "Stop Erasing" : "Erase")
            }
            Button("Undo", action: undoAction)
            Button("Save", action: onSave)
        }
        .padding()
    }
}
