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
    ["vec2"]       = "keyword",
    ["vec3"]       = "keyword",
    ["vec4"]       = "keyword",
    
    -- Storage modifiers
    ["static"]     = "keyword2",
    ["mut"]        = "keyword2",
    ["const"]      = "keyword2",
    ["let"]        = "keyword2",
    ["global"]     = "keyword2",
    ["this"]       = "keyword2",
    
    -- Boolean constants
    ["true"]       = "literal",
    ["false"]      = "literal",
    
    -- Built-in types
    ["any"]        = "keyword2",
    ["bool"]       = "keyword2",
    ["f32"]        = "keyword2",
    ["f64"]        = "keyword2",
    ["i32"]        = "keyword2",
    ["i64"]        = "keyword2",
    ["u32"]        = "keyword2",
    ["u64"]        = "keyword2",
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
    
    -- Built-in functions
    ["get_constant"]       = "keyword2",
    ["get_setting"]        = "keyword2",
    ["locale"]             = "keyword2",
    ["get_setting_full"]   = "keyword2",
    ["validate_setting"]   = "keyword2",
    ["list_settings"]      = "keyword2",
    ["list_constants"]     = "keyword2",
    ["has_constant"]       = "keyword2",
    ["list_locales"]       = "keyword2",
    ["get_manifest"]       = "keyword2",
    ["get_permissions"]    = "keyword2",
    ["is_disabled"]        = "keyword2",
    ["has_setting"]        = "keyword2",
    ["json_parse"]         = "keyword2",
    ["json_stringify"]     = "keyword2",
    ["crypto_hash"]        = "keyword2",
    ["crypto_hmac"]        = "keyword2",
    ["time_parse_duration"]= "keyword2",
    ["time_format_date"]   = "keyword2",
    ["type_of"]            = "keyword2",
    ["print"]              = "keyword2",
    ["println"]            = "keyword2",
    ["debug"]              = "keyword2",
    ["eval"]               = "keyword2",
    ["is_def_var"]         = "keyword2",
    ["is_def_fn"]          = "keyword2",
    ["is_shared"]          = "keyword2",
    ["curry"]              = "keyword2",
    ["functions"]          = "keyword2",
  },
}