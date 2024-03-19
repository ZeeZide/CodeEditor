<h2>
  CodeEditor
  <img src="https://zeezide.de/img/svgshaper/SVGShaper512.png"
       align="right" width="128" height="128" />
</h2>

![SwiftUI](https://img.shields.io/badge/SwiftUI-orange.svg)
![Swift5](https://img.shields.io/badge/swift-5-blue.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![iOS](https://img.shields.io/badge/os-iOS-green.svg?style=flat)
![visionOS](https://img.shields.io/badge/os-visionOS-green.svg?style=flat)
[![Build and Test](https://github.com/ZeeZide/CodeEditor/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/ZeeZide/CodeEditor/actions/workflows/swift.yml)

A [SwiftUI](https://developer.apple.com/xcode/swiftui/)
TextEditor View with syntax highlighting using
[Highlight.js](https://highlightjs.org).

It builds on top of
[Highlightr](https://github.com/raspu/Highlightr)
which does the wrapping of Highlight.js.
CodeEditor then packages things up for SwiftUI.

Example usage in 
[SVG Shaper for SwiftUI](https://zeezide.de/en/products/svgshaper/)
(used for editing SVG and Swift source):

![SVG Shaper Screenshot](https://pbs.twimg.com/media/E0ydNH9XEAQ-USY?format=png)

(Shaper is not actually using Highlightr, but is otherwise quite similar).

Highlightr example:

![Highlight Example](https://raw.githubusercontent.com/raspu/Highlightr/master/coding.gif)


## Usage

### Adding the Package

The Swift package URL is: `https://github.com/ZeeZide/CodeEditor.git`

### Using it in a SwiftUI App

To use `CodeEditor` as a source code viewer, simply pass the source code
as a string:
```swift
struct ContentView: View {

    var body: some View {
        CodeEditor(source: "let a = 42")
    }
}
```

If it should act as an actual editor, pass in a string `Binding`:

```swift
struct ContentView: View {

    @State private var source = "let a = 42\n"
    
    var body: some View {
        CodeEditor(source: $source, language: .swift, theme: .ocean)
    }
}
```

### Languages and Themes

[Highlight.js](https://highlightjs.org).
supports more than 180 languages and over 80 different themes.

The available languages and themes can be accessed using:
```swift
CodeEditor.availableLanguages
CodeEditor.availableThemes
```

They can be used in a SwiftUI `Picker` like so:

```swift
struct MyEditor: View {
  
    @State private var source   = "let it = be"
    @State private var language = CodeEditor.Language.swift

    var body: some View {
        Picker("Language", selection: $language) {
            ForEach(CodeEditor.availableLanguages) { language in
                Text("\(language.rawValue.capitalized)")
                    .tag(language)
            }
        }
    
        CodeEditor(source: $source, language: language)
    }
}
```

Note: The `CodeEditor` doesn't do automatic theme changes if the appearance
     changes.


### Smart Indent and Open/Close Pairing

Inspired by [NTYSmartTextView](https://github.com/naoty/NTYSmartTextView),
`CodeEditor` now also supports (on macOS):
- smarter indents (preserving the indent of the previous line)
- soft indents (insert a configurable amount of spaces if the user presses tabs)
- auto character pairing, e.g. when entering `{`, the matching `}` will be auto-added

To enable smart indents, add the `smartIndent` flag, e.g.:
```swift
CodeEditor(source: $source, language: language, 
           flags: [ .selectable, .editable, .smartIndent ])
```
It is enabled for editors by default.

To configure soft indents, use the `indentStyle` parameter, e.g.
```swift
CodeEditor(source: $source, language: language,
           indentStyle: .softTab(width: 2))
```
It defaults to tabs, as per system settings.

Auto character pairing is automatic based on the language. E.g. there is a set of 
defaults for C like languages (e.g. Swift), Python or XML. The defaults can be overridden
using the respective static variable in `CodeEditor`,
or the desired pairing can be set explicitly:
```swift
CodeEditor(source: $source, language: language,
           autoPairs: [ "{": "}", "<": ">", "'": "'" ])
```


### Font Sizing

On macOS the editor supports sizing of the font (using Cmd +/Cmd - and the
font panel).
To enable sizing commands, the WindowScene needs to have the proper commands
applied, e.g.:

```swift
WindowGroup {
    ContentView()
}
.commands {
    TextFormattingCommands()
}
```
To persist the size, the `fontSize` binding is available.


 ### Selection and Scrolling
 
 The selected text can be observed and modified via another `Binding`:
 
 ```swift
  struct ContentView: View {
     static private let initialSource = "let a = 42\n"

     @State private var source = Self.initialSource
     @State private var selection = Self.initialSource.endIndex..<Self.initialSource.endIndex

     var body: some View {
         CodeEditor(source: $source,
                    selection: $selection,
                    language: .swift,
                    theme: .ocean,
                    autoscroll: false)
         Button("Select All") {
             selection = source.startIndex..<source.endIndex
         }
     }
 }
 ```
 When `autoscroll` is `true`, the editor automatically scrolls to the respective
 cursor position when `selection` is modfied from the outside, i.e. programatically.

### Highlightr and Shaper

Based on the excellent [Highlightr](https://github.com/raspu/Highlightr).
This means that it is using JavaScriptCore as the actual driver. As
Highlightr says:

> It will never be as fast as a native solution, but it's fast enough to be
> used on a real time editor.

The editor is similar to (but not exactly the same) the one used by
[SVG Shaper for SwiftUI](https://zeezide.de/en/products/svgshaper/),
for its SVG and Swift editor parts.


### Complete Example

```swift
import SwiftUI
import CodeEditor

struct ContentView: View {
  
  #if os(macOS)
    @AppStorage("fontsize") var fontSize = Int(NSFont.systemFontSize)
  #endif
  @State private var source = "let a = 42"
  @State private var language = CodeEditor.Language.swift
  @State private var theme    = CodeEditor.ThemeName.pojoaque

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Picker("Language", selection: $language) {
          ForEach(CodeEditor.availableLanguages) { language in
            Text("\(language.rawValue.capitalized)")
              .tag(language)
          }
        }
        Picker("Theme", selection: $theme) {
          ForEach(CodeEditor.availableThemes) { theme in
            Text("\(theme.rawValue.capitalized)")
              .tag(theme)
          }
        }
      }
      .padding()
    
      Divider()
    
      #if os(macOS)
        CodeEditor(source: $source, language: language, theme: theme,
                   fontSize: .init(get: { CGFloat(fontSize)  },
                                   set: { fontSize = Int($0) }))
          .frame(minWidth: 640, minHeight: 480)
      #else
        CodeEditor(source: $source, language: language, theme: theme)
      #endif
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
```


### Who

CodeEditor is brought to you by [ZeeZide](https://zeezide.de).
We like feedback, GitHub stars, cool contract work, 
presumably any form of praise you can think of.
