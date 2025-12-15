-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Avi",
  files = { "%.avi$" },
  comment = "//",
  block_comment = { "/*", "*/" },
  patterns = {
    -- Documentation comments (must come before regular comments)
    { pattern = "//[!/].-\n",                                      type = "comment"  },
    { pattern = { "/%*[%*!]", "%*/" },                             type = "comment"  },
    
    -- Regular comments
    { pattern = "//.-\n",                                          type = "comment"  },
    { pattern = { "/%*", "%*/" },                                  type = "comment"  },
    
    -- Strings with escape sequences
    { pattern = { '"', '"', '\\' },                                type = "string"   },
    { pattern = { 'b"', '"', '\\' },                               type = "string"   },
    
    -- Numbers (more specific patterns first)
    { pattern = "%d+%.%d+[eE][%+%-]?%d+f?%d?%d?",                  type = "number"   },
    { pattern = "%d+%.%d+f?%d?%d?",                                type = "number"   },
    { pattern = "%d+[eE][%+%-]?%d+f?%d?%d?",                       type = "number"   },
    { pattern = "%d+_?%d*",                                        type = "number"   },
    
    -- Lifetimes (e.g., 'a, 'static)
    { pattern = "'[%a_][%w_]*",                                    type = "keyword" },
    
    -- Type annotations (Type after colon)
    { pattern = ":%s*[A-Z][%w_]*",                                type = "keyword" },
    
    -- Operators (compound operators first!)
    { pattern = ":=",                                              type = "operator" },
    { pattern = "%+%=",                                            type = "operator" },
    { pattern = "%-=",                                             type = "operator" },
    { pattern = "%*=",                                             type = "operator" },
    { pattern = "/=",                                              type = "operator" },
    { pattern = "%%=",                                             type = "operator" },
    { pattern = "%^=",                                             type = "operator" },
    { pattern = "&=",                                              type = "operator" },
    { pattern = "|=",                                              type = "operator" },
    { pattern = "<<=",                                             type = "operator" },
    { pattern = ">>=",                                             type = "operator" },
    { pattern = "&&",                                              type = "operator" },
    { pattern = "||",                                              type = "operator" },
    { pattern = "==",                                              type = "operator" },
    { pattern = "!=",                                              type = "operator" },
    { pattern = "<=",                                              type = "operator" },
    { pattern = ">=",                                              type = "operator" },
    { pattern = "<<",                                              type = "operator" },
    { pattern = ">>",                                              type = "operator" },
    { pattern = "%.%.%.",                                          type = "operator" },
    { pattern = "%.%.",                                            type = "operator" },
    { pattern = "->",                                              type = "operator" },
    { pattern = "=>",                                              type = "operator" },
    { pattern = "[%+%-=/%*%%<>!%^&|~]",                            type = "operator" },
    { pattern = "%?",                                              type = "operator" },
    
    { pattern = "fn%s+()[%a_][%w_]*",                              type = { "keyword", "function" } },
    
    -- Function calls (identifier followed by opening parenthesis)
    { pattern = "[%a_][%w_]*%f[(]",                             type = "function" },
        
    -- Generic/swizzle patterns (like .xyz, .rgba)
    { pattern = "%.[xyzwrgba]+",                                   type = "keyword"  },
    
    -- Identifiers
    { pattern = "[%a_][%w_]*",                                     type = "symbol"   },
  },
  symbols = {
    -- Control flow keywords
    ["break"]      = "keyword",
    ["continue"]   = "keyword",
    ["else"]       = "keyword",
    ["if"]         = "keyword",
    ["for"]        = "keyword",
    ["loop"]       = "keyword",
    ["while"]      = "keyword",
    ["return"]     = "keyword",
    ["in"]         = "keyword",
    
    -- Function keywords
    ["fn"]         = "keyword",
    ["private"]    = "keyword",
    
    -- Module/Import keywords
    ["ns"]         = "keyword",
    ["use"]        = "keyword",
    ["import"]     = "keyword",
    ["export"]     = "keyword",
    ["as"]         = "keyword",
    
    -- Other keywords
    ["grab"]       = "keyword",
    ["try"]        = "keyword",
    ["catch"]      = "keyword",
    ["throw"]      = "keyword",
    ["sum"]        = "keyword",
    ["sum_vec4"]   = "keyword",
    ["prod"]       = "keyword",
    ["prod_vec4"]  = "keyword",
    ["min"]        = "keyword",
    ["max"]        = "keyword",
    ["all"]        = "keyword",
    ["sift"]       = "keyword",
    ["and"]        = "keyword",
    ["or"]         = "keyword",
    ["go"]         = "keyword",
    ["call"]       = "keyword",
    
    -- Vector constructors
    ["vec4"]       = "keyword",
    
    -- Storage modifiers
    ["mut"]        = "keyword2",
    
    -- Boolean constants
    ["true"]       = "literal",
    ["false"]      = "literal",
    
    -- Built-in types
    ["any"]        = "keyword2",
    ["bool"]       = "keyword2",
    ["f64"]        = "keyword2",
    ["str"]        = "keyword2",
    ["opt"]        = "keyword2",
    ["res"]        = "keyword2",
    ["thr"]        = "keyword2",
    ["link"]       = "keyword2",
    ["sec"]        = "keyword2",
    
    -- Result/Option variants
    ["some"]       = "literal",
    ["none"]       = "literal",
    ["ok"]         = "literal",
    ["err"]        = "literal",
  },
}