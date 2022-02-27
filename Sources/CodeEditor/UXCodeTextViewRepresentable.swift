//
//  UXCodeTextViewRepresentable.swift
//  CodeEditor
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

#if os(macOS)
  typealias UXViewRepresentable = NSViewRepresentable
#else
  typealias UXViewRepresentable = UIViewRepresentable
#endif

/**
 * Move the gritty details out of the main representable.
 */
struct UXCodeTextViewRepresentable : UXViewRepresentable {
  
  /**
   * Configures a CodeEditor View with the given parameters.
   *
   * - Parameters:
   *   - source:      A binding to a String that holds the source code to be
   *                  edited (or displayed).
   *   - language:    Optionally set a language (e.g. `.swift`), otherwise
   *                  Highlight.js will attempt to detect the language.
   *   - theme:       The name of the theme to use.
   *   - fontSize:    On macOS this Binding can be used to persist the size of
   *                  the font in use. At runtime this is combined with the
   *                  theme to produce the full font information.
   *   - flags:       Configure whether the text is editable and/or selectable.
   *   - indentStyle: Optionally insert a configurable amount of spaces if the
   *                  user hits "tab".
   *   - inset:       The editor can be inset in the scroll view. Defaults to
   *                  8/8.
   *   - autoPairs:   A mapping of open/close characters, where the close
   *                  characters are automatically injected when the user enters
   *                  the opening character. For example: `[ "<": ">" ]` would
   *                  automatically insert the closing ">" if the user enters
   *                  "<".
   *   - autoscroll:  If enabled, the editor automatically scrolls to the respective
   *                  region when the `selection` is changed programatically.
   */
  public init(source      : Binding<String>,
              selection   : Binding<Range<String.Index>>?,
              language    : CodeEditor.Language?,
              theme       : CodeEditor.ThemeName,
              fontSize    : Binding<CGFloat>?,
              flags       : CodeEditor.Flags,
              indentStyle : CodeEditor.IndentStyle,
              autoPairs   : [ String : String ],
              inset       : CGSize,
              autoscroll  : Bool)
  {
    self.source      = source
    self.selection = selection
    self.fontSize    = fontSize
    self.language    = language
    self.themeName   = theme
    self.flags       = flags
    self.indentStyle = indentStyle
    self.autoPairs   = autoPairs
    self.inset       = inset
    self.autoscroll = autoscroll
  }
    
  private var source      : Binding<String>
  private var selection   : Binding<Range<String.Index>>?
  private var fontSize    : Binding<CGFloat>?
  private let language    : CodeEditor.Language?
  private let themeName   : CodeEditor.ThemeName
  private let flags       : CodeEditor.Flags
  private let indentStyle : CodeEditor.IndentStyle
  private let inset       : CGSize
  private let autoPairs   : [ String : String ]
  private let autoscroll  : Bool

  // The inner `value` is true, exactly when execution is inside
  // the `updateTextView(_:)` method. The `Coordinator` can use this
  // value to guard against update cycles.
  // This needs to be a `State`, as the `UXCodeTextViewRepresentable`
  // might be destructed and recreated in between calls to `makeCoordinator()`
  // and `updateTextView(_:)`.
  @State private var isCurrentlyUpdatingView = ReferenceTypeBool(value: false)
  
  // MARK: - TextView Delegate  Coordinator
    
  public final class Coordinator: NSObject, UXCodeTextViewDelegate {
    
    var parent : UXCodeTextViewRepresentable
    
    var fontSize : CGFloat? {
      set { if let value = newValue { parent.fontSize?.wrappedValue = value } }
      get { parent.fontSize?.wrappedValue }
    }
    
    init(_ parent: UXCodeTextViewRepresentable) {
      self.parent = parent
    }
    
    #if os(macOS)
      public func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? UXTextView else {
          assertionFailure("unexpected notification object")
          return
        }
        textViewDidChange(textView: textView)
      }    
    #elseif os(iOS)
      public func textViewDidChange(_ textView: UITextView) {
        textViewDidChange(textView: textView)
      }
    #else
      #error("Unsupported OS")
    #endif
      
    private func textViewDidChange(textView: UXTextView) {
      // This function may be called as a consequence of updating the text string
      //  in UXCodeTextViewRepresentable/updateTextView(_:)`.
      // Since this function might update the `parent.source` `Binding`, which in
      // turn might update a `State`, this would lead to undefined behavior.
      // (Changing a `State` during a `View` update is not permitted).
      guard !parent.isCurrentlyUpdatingView.value else {
        return
      }
      
      parent.source.wrappedValue = textView.string
    }
      
    #if os(macOS)
      public func textViewDidChangeSelection(_ notification: Notification) {
        guard let textView = notification.object as? UXTextView else {
          assertionFailure("unexpected notification object")
          return
        }
        
        textViewDidChangeSelection(textView: textView as! UXCodeTextView)
      }
    #elseif os(iOS)
      public func textViewDidChangeSelection(_ textView: UITextView) {
        textViewDidChangeSelection(textView: textView as! UXCodeTextView)
      }
    #else
      #error("Unsupported OS")
    #endif
      
    private func textViewDidChangeSelection(textView: UXCodeTextView) {
      // This function may be called as a consequence of updating the selected
      // range in UXCodeTextViewRepresentable/updateTextView(_:)`.
      // Since this function might update the `parent.selection` `Binding`, which in
      // turn might update a `State`, this would lead to undefined behavior.
      // (Changing a `State` during a `View` update is not permitted).
      guard !parent.isCurrentlyUpdatingView.value else {
        return
      }
      
      guard let selection = parent.selection else {
        return
      }

      let range = textView.swiftSelectedRange
      
      if selection.wrappedValue != range {
        selection.wrappedValue = range
      }
    }
    
    var allowCopy: Bool {
      return parent.flags.contains(.selectable)
          || parent.flags.contains(.editable)
    }
  }
    
  public func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
  
  private func updateTextView(_ textView: UXCodeTextView) {
    isCurrentlyUpdatingView.value = true
    defer {
      isCurrentlyUpdatingView.value = false
    }
      
    if let binding = fontSize {
      textView.applyNewTheme(themeName, andFontSize: binding.wrappedValue)
    }
    else {
      textView.applyNewTheme(themeName)
    }
    textView.language = language
    
    textView.indentStyle          = indentStyle
    textView.isSmartIndentEnabled = flags.contains(.smartIndent)
    textView.autoPairCompletion   = autoPairs

    if source.wrappedValue != textView.string {
      if let textStorage = textView.codeTextStorage {
        textStorage.replaceCharacters(in   : NSMakeRange(0, textStorage.length),
                                      with : source.wrappedValue)
      }
      else {
        assertionFailure("no text storage?")
        textView.string = source.wrappedValue
      }
    }
    
    if let selection = selection {
      let range = selection.wrappedValue
      
      if range != textView.swiftSelectedRange {
        let nsrange = NSRange(range, in: textView.string)
        #if os(macOS)
          textView.setSelectedRange(nsrange)
        #elseif os(iOS)
          textView.selectedRange = nsrange
        #else
          #error("Unsupported OS")
        #endif
        
        if autoscroll {
          textView.scrollRangeToVisible(nsrange)
        }
      }
    }
    
    textView.isEditable   = flags.contains(.editable)
    textView.isSelectable = flags.contains(.selectable)
  }

  #if os(macOS)
    public func makeNSView(context: Context) -> NSScrollView {
      let textView = UXCodeTextView()
      textView.autoresizingMask   = [ .width, .height ]
      textView.delegate           = context.coordinator
      textView.allowsUndo         = true
      textView.textContainerInset = inset

      let scrollView = NSScrollView()
      scrollView.hasVerticalScroller = true
      scrollView.documentView = textView
      
      updateTextView(textView)
      return scrollView
    }
    
    public func updateNSView(_ scrollView: NSScrollView, context: Context) {
      guard let textView = scrollView.documentView as? UXCodeTextView else {
        assertionFailure("unexpected text view")
        return
      }
      if textView.delegate !== context.coordinator {
        textView.delegate = context.coordinator
      }
      textView.textContainerInset = inset
      updateTextView(textView)
    }
  #else // iOS etc
    private var edgeInsets: UIEdgeInsets {
      return UIEdgeInsets(
        top    : inset.height, left  : inset.width,
        bottom : inset.height, right : inset.width
      )
    }
    public func makeUIView(context: Context) -> UITextView {
      let textView = UXCodeTextView()
      textView.autoresizingMask   = [ .flexibleWidth, .flexibleHeight ]
      textView.delegate           = context.coordinator
      textView.textContainerInset = edgeInsets
      #if os(iOS)
      textView.autocapitalizationType = .none
      textView.smartDashesType = .no
      textView.autocorrectionType = .no
      textView.spellCheckingType = .no
      textView.smartQuotesType = .no
      #endif
      updateTextView(textView)
      return textView
    }
    
    public func updateUIView(_ textView: UITextView, context: Context) {
      guard let textView = textView as? UXCodeTextView else {
        assertionFailure("unexpected text view")
        return
      }
      if textView.delegate !== context.coordinator {
        textView.delegate = context.coordinator
      }
      textView.textContainerInset = edgeInsets
      updateTextView(textView)
    }
  #endif // iOS
}

extension UXCodeTextViewRepresentable {
  // A wrapper around a `Bool` that enables updating
  // the wrapped value during `View` renders.
  private class ReferenceTypeBool {
    var value: Bool
      
    init(value: Bool) {
      self.value = value
    }
  }
}

struct UXCodeTextViewRepresentable_Previews: PreviewProvider {
  
  static var previews: some View {
    
    UXCodeTextViewRepresentable(source      : .constant("let a = 5"),
                                selection   : nil,
                                language    : nil,
                                theme       : .pojoaque,
                                fontSize    : nil,
                                flags       : [ .selectable ],
                                indentStyle : .system,
                                autoPairs   : [:],
                                inset       : .init(width: 8, height: 8),
                                autoscroll  : false)
      .frame(width: 200, height: 100)
    
    UXCodeTextViewRepresentable(source: .constant("let a = 5"),
                                selection   : nil,
                                language    : .swift,
                                theme       : .pojoaque,
                                fontSize    : nil,
                                flags       : [ .selectable ],
                                indentStyle : .system,
                                autoPairs   : [:],
                                inset       : .init(width: 8, height: 8),
                                autoscroll  : false)
      .frame(width: 200, height: 100)
    
    UXCodeTextViewRepresentable(
      source: .constant(
        #"""
        The quadratic formula is $-b \pm \sqrt{b^2 - 4ac} \over 2a$
        \bye
        """#
      ),
      selection   : nil,
      language    : .tex,
      theme       : .pojoaque,
      fontSize    : nil,
      flags       : [ .selectable ],
      indentStyle : .system,
      autoPairs   : [:],
      inset       : .init(width: 8, height: 8),
      autoscroll  : false
    )
    .frame(width: 540, height: 200)
  }
}
