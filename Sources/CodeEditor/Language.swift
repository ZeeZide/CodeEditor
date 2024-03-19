//
//  Language.swift
//  CodeEditor
//
//  Created by Helge Heß.
//  Copyright © 2021-2024 ZeeZide GmbH. All rights reserved.
//

public extension CodeEditor {
  
  @frozen
  struct Language: TypedString, Sendable {
    
    public let rawValue : String
    
    @inlinable
    public init(rawValue: String) { self.rawValue = rawValue }
  }
}

public extension CodeEditor.Language {

  @inlinable static var accesslog    : Self { Self(rawValue: "accesslog") }
  @inlinable static var actionscript : Self { Self(rawValue: "actionscript") }
  @inlinable static var ada          : Self { Self(rawValue: "ada") }
  @inlinable static var apache       : Self { Self(rawValue: "apache") }
  @inlinable static var applescript  : Self { Self(rawValue: "applescript") }
  @inlinable static var bash         : Self { Self(rawValue: "bash") }
  @inlinable static var basic        : Self { Self(rawValue: "basic") }
  @inlinable static var brainfuck    : Self { Self(rawValue: "brainfuck") }
  @inlinable static var c            : Self { Self(rawValue: "c") }
  @inlinable static var cpp          : Self { Self(rawValue: "cpp") }
  @inlinable static var cs           : Self { Self(rawValue: "cs") }
  @inlinable static var css          : Self { Self(rawValue: "css") }
  @inlinable static var diff         : Self { Self(rawValue: "diff") }
  @inlinable static var dockerfile   : Self { Self(rawValue: "dockerfile") }
  @inlinable static var go           : Self { Self(rawValue: "go") }
  @inlinable static var http         : Self { Self(rawValue: "http") }
  @inlinable static var java         : Self { Self(rawValue: "java") }
  @inlinable static var javascript   : Self { Self(rawValue: "javascript") }
  @inlinable static var json         : Self { Self(rawValue: "json") }
  @inlinable static var lua          : Self { Self(rawValue: "lua") }
  @inlinable static var markdown     : Self { Self(rawValue: "markdown") }
  @inlinable static var makefile     : Self { Self(rawValue: "makefile") }
  @inlinable static var nginx        : Self { Self(rawValue: "nginx") }
  @inlinable static var objectivec   : Self { Self(rawValue: "objectivec") }
  @inlinable static var pgsql        : Self { Self(rawValue: "pgsql") }
  @inlinable static var php          : Self { Self(rawValue: "php") }
  @inlinable static var python       : Self { Self(rawValue: "python") }
  @inlinable static var ruby         : Self { Self(rawValue: "ruby") }
  @inlinable static var rust         : Self { Self(rawValue: "rust") }
  @inlinable static var shell        : Self { Self(rawValue: "shell") }
  @inlinable static var smalltalk    : Self { Self(rawValue: "smalltalk") }
  @inlinable static var sql          : Self { Self(rawValue: "sql") }
  @inlinable static var swift        : Self { Self(rawValue: "swift") }
  @inlinable static var tcl          : Self { Self(rawValue: "tcl") }
  @inlinable static var tex          : Self { Self(rawValue: "tex") }
  @inlinable static var twig         : Self { Self(rawValue: "twig") }
  @inlinable static var typescript   : Self { Self(rawValue: "typescript") }
  @inlinable static var vbnet        : Self { Self(rawValue: "vbnet") }
  @inlinable static var vbscript     : Self { Self(rawValue: "vbscript") }
  @inlinable static var xml          : Self { Self(rawValue: "xml") }
  @inlinable static var yaml         : Self { Self(rawValue: "yaml") }
}
