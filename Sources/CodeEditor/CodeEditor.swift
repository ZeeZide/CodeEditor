//
//  CodeEditor.swift
//  CodeEditor
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import Highlightr

/**
 * An simple code editor (or viewer) with highlighting for SwiftUI (iOS and
 * macOS).
 *
 * To use the code editor as a Viewer, simply pass the source code
 *
 *     struct ContentView: View {
 *
 *         var body: some View {
 *             CodeEditor(source: "let a = 42")
 *         }
 *     }
 *
 * If it should act as an actual editor, pass it `Binding`:
 *
 *     struct ContentView: View {
 *
 *         @State private var source = "let a = 42\n"
 *
 *         var body: some View {
 *             CodeEditor(source: $source, language: .swift, theme: .ocean)
 *         }
 *     }
 *
 * ### Languages and Themes
 *
 * Highlight.js supports more than 180 languages and over 80 different themes.
 *
 * The available languages and themes can be accessed using:
 *
 *     CodeEditor.availableLanguages
 *     CodeEditor.availableThemes
 *
 * They can be used in a SwiftUI `Picker` like so:
 *
 *     @State var source   = "let it = be"
 *     @State var language = CodeEditor.Language.swift
 *
 *     Picker("Language", selection: $language) {
 *       ForEach(CodeEditor.availableLanguages) { language in
 *         Text("\(language.rawValue.capitalized)")
 *           .tag(language)
 *       }
 *     }
 *
 *     CodeEditor(source: $source, language: language)
 *
 * Note: The `CodeEditor` doesn't do automatic theme changes if the appearance
 *       changes.
 *
 * ### Font Sizing
 *
 * On macOS the editor supports sizing of the font (using Cmd +/Cmd - and the
 * font panel).
 * To enable sizing commands, the WindowScene needs to have the proper commands
 * applied, e.g.:
 *
 *     WindowGroup {
 *         ContentView()
 *     }
 *     .commands {
 *         TextFormattingCommands()
 *     }
 *
 * To persist the binding, the `fontSize` binding is available.
 *
 * ### Highlightr and Shaper
 *
 * Based on the excellent [Highlightr](https://github.com/raspu/Highlightr).
 * This means that it is using JavaScriptCore as the actual driver. As
 * Highlightr says:
 *
 * > It will never be as fast as a native solution, but it's fast enough to be
 * > used on a real time editor.
 *
 * The editor is similar to (but not exactly the same) the one used by
 * [SVG Shaper for SwiftUI](https://zeezide.de/en/products/svgshaper/),
 * for its SVG and Swift editor parts.
 */
public struct CodeEditor: View {
  
  /// Returns the available themes in the associated Highlightr package.
  public static var availableThemes =
    Highlightr()?.availableThemes().map(ThemeName.init).sorted() ?? []
  
  /// Returns the available languages in the associated Highlightr package.
  public static var availableLanguages =
    Highlightr()?.supportedLanguages().map(Language.init).sorted() ?? []
  

  /**
   * Flags available for `CodeEditor`, currently just:
   * - `.editable`
   * - `.selectable`
   */
  @frozen public struct Flags: OptionSet {
    public let rawValue : UInt8
    @inlinable public init(rawValue: UInt8) { self.rawValue = rawValue }
    
    /// `.editable` requires that the `source` of the `CodeEditor` is a
    /// `Binding`.
    public static let editable   = Flags(rawValue: 1 << 0)
    
    /// Whether the displayed content should be selectable by the user.
    public static let selectable = Flags(rawValue: 1 << 1)
  }
  
  /**
   * Configures a CodeEditor View with the given parameters.
   *
   * - Parameters:
   *   - source:   A binding to a String that holds the source code to be edited
   *               (or displayed).
   *   - language: Optionally set a language (e.g. `.swift`), otherwise
   *               Highlight.js will attempt to detect the language.
   *   - theme:    The name of the theme to use, defaults to "pojoaque".
   *   - fontSize: On macOS this Binding can be used to persist the size of
   *               the font in use. At runtime this is combined with the
   *               theme to produce the full font information. (optional)
   *   - flags:    Configure whether the text is editable and/or selectable
   *               (defaults to both).
   */
  public init(source   : Binding<String>,
              language : Language?         = nil,
              theme    : ThemeName         = .default,
              fontSize : Binding<CGFloat>? = nil,
              flags    : Flags             = [ .selectable, .editable ])
  {
    self.source    = source
    self.fontSize  = fontSize
    self.language  = language
    self.themeName = theme
    self.flags     = flags
  }
  
  /**
   * Configures a read-only CodeEditor View with the given parameters.
   *
   * - Parameters:
   *   - source:   A String that holds the source code to be displayed.
   *   - language: Optionally set a language (e.g. `.swift`), otherwise
   *               Highlight.js will attempt to detect the language.
   *   - theme:    The name of the theme to use, defaults to "pojoaque".
   *   - fontSize: On macOS this Binding can be used to persist the size of
   *               the font in use. At runtime this is combined with the
   *               theme to produce the full font information. (optional)
   *   - flags:    Configure whether the text is selectable
   *               (defaults to both).
   */
  @inlinable
  public init(source   : String,
              language : Language?         = nil,
              theme    : ThemeName         = .default,
              fontSize : Binding<CGFloat>? = nil,
              flags    : Flags             = [ .selectable ])
  {
    assert(!flags.contains(.editable), "Editing requires a Binding")
    self.init(source   : .constant(source),
              language : language,
              theme    : theme,
              fontSize : fontSize,
              flags    : flags.subtracting(.editable))
  }
  
  private var source    : Binding<String>
  private var fontSize  : Binding<CGFloat>?
  private let language  : Language?
  private let themeName : ThemeName
  private let flags     : Flags
  private let inset     = CGSize(width: 8, height: 8)

  public var body: some View {
    UXCodeTextViewRepresentable(source   : source,
                                language : language,
                                theme    : themeName,
                                fontSize : fontSize,
                                flags    : flags)
  }
}

struct CodeEditor_Previews: PreviewProvider {
  
  static var previews: some View {
    
    CodeEditor(source: "let a = 5")
      .frame(width: 200, height: 100)
    
    CodeEditor(source: "let a = 5", language: .swift, theme: .pojoaque)
      .frame(width: 200, height: 100)
    
    CodeEditor(source:
      #"""
      The quadratic formula is $-b \pm \sqrt{b^2 - 4ac} \over 2a$
      \bye
      """#, language: .tex
    )
    .frame(width: 540, height: 200)
  }
}
