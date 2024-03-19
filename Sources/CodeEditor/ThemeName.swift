//
//  ThemeName.swift
//  CodeEditor
//
//  Created by Helge Heß.
//  Copyright © 2021-2024 ZeeZide GmbH. All rights reserved.
//

public extension CodeEditor {
  
  @frozen
  struct ThemeName: TypedString, Sendable {
    
    public let rawValue : String
    
    @inlinable
    public init(rawValue: String) { self.rawValue = rawValue }
  }
}

public extension CodeEditor.ThemeName {

  @inlinable static var `default` : Self { pojoaque }
  @inlinable static var pojoaque  : Self { Self(rawValue: "pojoaque") }
  @inlinable static var agate     : Self { Self(rawValue: "agate") }
  @inlinable static var ocean     : Self { Self(rawValue: "ocean") }
  
  @inlinable
  static var atelierSavannaLight : Self {
               Self(rawValue: "atelier-savanna-light") }
  @inlinable
  static var atelierSavannaDark : Self {
               Self(rawValue: "atelier-savanna-dark") }
}
