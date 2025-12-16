import { CompletionItem, CompletionItemKind, InsertTextFormat } from 'vscode-languageserver-types';

export interface AviSymbol extends CompletionItem {
  label: string;
  kind: CompletionItemKind;
  detail?: string;
  documentation?: string;
}

export const AVI_BUILTINS: AviSymbol[] = [
  // Control flow
  { label: "if", kind: CompletionItemKind.Keyword, insertTextFormat: InsertTextFormat.Snippet, insertText: "if (${1:condition}) {\n\t$0\n}", documentation: "Conditional branch" },
  { label: "else if", kind: CompletionItemKind.Keyword, insertTextFormat: InsertTextFormat.Snippet, insertText: "else if (${1:condition}) {\n\t$0\n}", documentation: "Alternative If branch" },
  { label: "else", kind: CompletionItemKind.Keyword, insertTextFormat: InsertTextFormat.Snippet, insertText: "else {\n\t$0\n}", documentation: "Alternative branch" },
  { label: "for", kind: CompletionItemKind.Keyword, insertTextFormat: InsertTextFormat.Snippet, insertText: "for ${1:i} = 0; ${1:i} < ${2:n}; ${1:i}++ {\n\t$0\n}", documentation: "For loop" },
  { label: "loop", kind: CompletionItemKind.Keyword, insertTextFormat: InsertTextFormat.Snippet, insertText: "loop {\n\t$0\n}", documentation: "Infinite loop" },
  { label: "return", kind: CompletionItemKind.Keyword, insertTextFormat: InsertTextFormat.Snippet, insertText: "return $0", documentation: "Return from function" },

  // Declarations
  { label: "fn", kind: CompletionItemKind.Keyword, insertTextFormat: InsertTextFormat.Snippet, insertText: "fn ${1:name}(${2:args}) {\n\t$0\n}", documentation: "Defines a new function" },
  { label: "mut", kind: CompletionItemKind.TypeParameter, documentation: "Mutable variable" },

  // Types
  { label: "bool", kind: CompletionItemKind.TypeParameter, documentation: "Boolean type" },
  { label: "f64", kind: CompletionItemKind.TypeParameter, documentation: "64-bit floating point" },
  { label: "str", kind: CompletionItemKind.TypeParameter, documentation: "String type" },
  { label: "any", kind: CompletionItemKind.TypeParameter, documentation: "Any type" },
  { label: "vec4", kind: CompletionItemKind.TypeParameter, documentation: "4D vector type" },
  { label: "mat4", kind: CompletionItemKind.TypeParameter, documentation: "4x4 matrix type" },
  { label: "opt", kind: CompletionItemKind.TypeParameter, documentation: "Optional type" },
  { label: "res", kind: CompletionItemKind.TypeParameter, documentation: "Result type" },
  { label: "link", kind: CompletionItemKind.TypeParameter, documentation: "Linked list type" },
  { label: "sec", kind: CompletionItemKind.TypeParameter, documentation: "Secret/traced type" },
  { label: "thr", kind: CompletionItemKind.TypeParameter, documentation: "Thread type" },
  { label: "in", kind: CompletionItemKind.TypeParameter, documentation: "Input channel type" },

  // Literals
  { label: "true", kind: CompletionItemKind.Value, documentation: "Boolean true value" },
  { label: "false", kind: CompletionItemKind.Value, documentation: "Boolean false value" },

  
  // Tracing functions
  { label: "why", kind: CompletionItemKind.Function, detail: "(var: sec[bool]) -> [any]", documentation: "Returns derived information for truth value, used with ∃/any and ∀/all loops" },
  { label: "where", kind: CompletionItemKind.Function, detail: "(var: sec[f64]) -> [any]", documentation: "Returns derived information for value, used with min and max loops" },
  { label: "explain_why", kind: CompletionItemKind.Function, detail: "(var: bool, msg) -> sec[bool]", documentation: "Adds message to derived information for truth value" },
  { label: "explain_where", kind: CompletionItemKind.Function, detail: "(var: f64, msg) -> sec[f64]", documentation: "Adds message to derived information for value" },

  // I/O functions
  { label: "print", kind: CompletionItemKind.Function, detail: "(var)", documentation: "Prints variable to stdout" },
  { label: "println", kind: CompletionItemKind.Function, detail: "(var)", documentation: "Prints variable to stdout with newline" },
  { label: "eprint", kind: CompletionItemKind.Function, detail: "(var)", documentation: "Prints variable to stderr" },
  { label: "eprintln", kind: CompletionItemKind.Function, detail: "(var)", documentation: "Prints variable to stderr with newline" },
  { label: "read_line", kind: CompletionItemKind.Function, detail: "() -> str", documentation: "Reads a line from stdin" },
  { label: "read_number", kind: CompletionItemKind.Function, detail: "(message: str) -> f64", documentation: "Reads a number from stdin with message, re-prompts on invalid input" },

  // Utility functions
  { label: "clone", kind: CompletionItemKind.Function, detail: "(var) -> any", documentation: "Clones variable and all its references" },
  { label: "debug", kind: CompletionItemKind.Function, detail: "()", documentation: "Prints stack and local stack state" },
  { label: "backtrace", kind: CompletionItemKind.Function, detail: "()", documentation: "Prints call stack" },
  { label: "typeof", kind: CompletionItemKind.Function, detail: "(var) -> str", documentation: "Returns simple description of variable type" },
  { label: "sleep", kind: CompletionItemKind.Function, detail: "(seconds: f64)", documentation: "Sleeps for given seconds" },
  { label: "random", kind: CompletionItemKind.Function, detail: "() -> f64", documentation: "Returns random number between 0 and 1" },

  // Link/List functions
  { label: "is_empty", kind: CompletionItemKind.Function, detail: "(l: link) -> bool", documentation: "Returns true if link is empty" },
  { label: "head", kind: CompletionItemKind.Function, detail: "(l: link) -> opt[any]", documentation: "Returns first item in link" },
  { label: "tail", kind: CompletionItemKind.Function, detail: "(l: link) -> link", documentation: "Returns link except first item" },
  { label: "tip", kind: CompletionItemKind.Function, detail: "(l: link) -> opt[any]", documentation: "Returns last item in link" },
  { label: "neck", kind: CompletionItemKind.Function, detail: "(l: link) -> link", documentation: "Returns link except last item" },

  // Array functions
  { label: "len", kind: CompletionItemKind.Function, detail: "(array: [any]) -> f64", documentation: "Returns length of array" },
  { label: "push", kind: CompletionItemKind.Function, detail: "(mut array, item)", documentation: "Appends deep clone of item at end of array" },
  { label: "push_ref", kind: CompletionItemKind.Function, detail: "(mut array, item)", documentation: "Appends item reference at end of array" },
  { label: "pop", kind: CompletionItemKind.Function, detail: "(mut array) -> any", documentation: "Removes and returns last item from array" },
  { label: "insert", kind: CompletionItemKind.Function, detail: "(mut array, index: f64, item)", documentation: "Inserts deep clone at index" },
  { label: "insert_ref", kind: CompletionItemKind.Function, detail: "(mut array, index: f64, item)", documentation: "Inserts item reference at index" },
  { label: "remove", kind: CompletionItemKind.Function, detail: "(mut array, index: f64) -> any", documentation: "Removes and returns item at index" },
  { label: "reverse", kind: CompletionItemKind.Function, detail: "(mut array)", documentation: "Reverses items in array" },
  { label: "clear", kind: CompletionItemKind.Function, detail: "(mut array)", documentation: "Removes all items from array" },
  { label: "swap", kind: CompletionItemKind.Function, detail: "(mut array, i: f64, j: f64)", documentation: "Swaps two items in array" },

  // String functions
  { label: "str", kind: CompletionItemKind.Function, detail: "(var) -> str", documentation: "Returns string representation of variable" },
  { label: "trim", kind: CompletionItemKind.Function, detail: "(text: str) -> str", documentation: "Removes whitespace from both sides" },
  { label: "trim_left", kind: CompletionItemKind.Function, detail: "(text: str) -> str", documentation: "Removes whitespace from left side" },
  { label: "trim_right", kind: CompletionItemKind.Function, detail: "(text: str) -> str", documentation: "Removes whitespace from right side" },
  { label: "chars", kind: CompletionItemKind.Function, detail: "(text: str) -> [str]", documentation: "Returns characters of a string" },
  { label: "parse_number", kind: CompletionItemKind.Function, detail: "(text: str) -> opt[f64]", documentation: "Parses number from string" },
  { label: "json_string", kind: CompletionItemKind.Function, detail: "(text: str) -> str", documentation: "Creates JSON string of text" },
  { label: "fmt__tab_string", kind: CompletionItemKind.Function, detail: "(tab: f64, text: str) -> str", documentation: "Formats text with newlines and tab shifts using spaces" },
  { label: "errstr__string_start_len_msg", kind: CompletionItemKind.Function, detail: "(text: str, start: f64, len: f64, msg: str) -> str", documentation: "Generates error message string with source location" },

  // Math functions
  { label: "abs", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns absolute value" },
  { label: "round", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Rounds number to nearest integer" },
  { label: "floor", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns highest smaller integer" },
  { label: "ceil", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns smallest higher integer" },
  { label: "sqrt", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns square root" },
  { label: "sin", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns sine of number" },
  { label: "asin", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns inverse sine" },
  { label: "cos", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns cosine of number" },
  { label: "acos", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns inverse cosine" },
  { label: "tan", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns tangent in radians" },
  { label: "atan", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns inverse tangent in radians" },
  { label: "atan2", kind: CompletionItemKind.Function, detail: "(y: f64, x: f64) -> f64", documentation: "Returns inverse tangent in radians" },
  { label: "exp", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns natural exponential (e^x)" },
  { label: "ln", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns natural logarithm" },
  { label: "log2", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns logarithm base 2" },
  { label: "log10", kind: CompletionItemKind.Function, detail: "(v: f64) -> f64", documentation: "Returns logarithm base 10" },
  { label: "min", kind: CompletionItemKind.Function, detail: "(array: [f64]) -> f64", documentation: "Returns smallest number in array (NaN if empty)" },
  { label: "max", kind: CompletionItemKind.Function, detail: "(array: [f64]) -> f64", documentation: "Returns largest number in array (NaN if empty)" },
  { label: "is_nan", kind: CompletionItemKind.Function, detail: "(v: f64) -> bool", documentation: "Returns true if number is NaN" },
  { label: "tau", kind: CompletionItemKind.Function, detail: "() -> f64", documentation: "Returns radians in a circle (2*pi)" },

  // Vector functions
  { label: "norm", kind: CompletionItemKind.Function, detail: "(v: vec4) -> f64", documentation: "Returns length of 4D vector" },
  { label: "dot", kind: CompletionItemKind.Function, detail: "(a, b) -> f64", documentation: "Returns dot product" },
  { label: "cross", kind: CompletionItemKind.Function, detail: "(a: vec4, b: vec4) -> vec4", documentation: "Returns cross product" },
  { label: "x", kind: CompletionItemKind.Function, detail: "(v: vec4) -> f64", documentation: "Returns x component of vector" },
  { label: "y", kind: CompletionItemKind.Function, detail: "(v: vec4) -> f64", documentation: "Returns y component of vector" },
  { label: "z", kind: CompletionItemKind.Function, detail: "(v: vec4) -> f64", documentation: "Returns z component of vector" },
  { label: "w", kind: CompletionItemKind.Function, detail: "(v: vec4) -> f64", documentation: "Returns w component of vector" },
  { label: "s", kind: CompletionItemKind.Function, detail: "(v: vec4, ind: f64) -> f64", documentation: "Returns component by index" },
  { label: "dir__angle", kind: CompletionItemKind.Function, detail: "(angle: f64) -> vec4", documentation: "Returns unit vector at angle (rotating from (1,0) around z-axis)" },

  // Matrix functions
  { label: "rx", kind: CompletionItemKind.Function, detail: "(m: mat4) -> vec4", documentation: "Returns row vector x (basis vector)" },
  { label: "ry", kind: CompletionItemKind.Function, detail: "(m: mat4) -> vec4", documentation: "Returns row vector y (basis vector)" },
  { label: "rz", kind: CompletionItemKind.Function, detail: "(m: mat4) -> vec4", documentation: "Returns row vector z (basis vector)" },
  { label: "rw", kind: CompletionItemKind.Function, detail: "(m: mat4) -> vec4", documentation: "Returns row vector w (basis vector)" },
  { label: "rv", kind: CompletionItemKind.Function, detail: "(m: mat4, ind: f64) -> vec4", documentation: "Returns row vector by index" },
  { label: "cx", kind: CompletionItemKind.Function, detail: "(m: mat4) -> vec4", documentation: "Returns column vector x (transposed basis)" },
  { label: "cy", kind: CompletionItemKind.Function, detail: "(m: mat4) -> vec4", documentation: "Returns column vector y (transposed basis)" },
  { label: "cz", kind: CompletionItemKind.Function, detail: "(m: mat4) -> vec4", documentation: "Returns column vector z (transposed basis)" },
  { label: "cv", kind: CompletionItemKind.Function, detail: "(m: mat4, ind: f64) -> vec4", documentation: "Returns column vector by index" },
  { label: "det", kind: CompletionItemKind.Function, detail: "(m: mat4) -> f64", documentation: "Returns determinant of matrix" },
  { label: "inv", kind: CompletionItemKind.Function, detail: "(m: mat4) -> mat4", documentation: "Returns inverse of matrix" },
  { label: "mov", kind: CompletionItemKind.Function, detail: "(v: vec4) -> mat4", documentation: "Returns translation matrix (ignores 4th component)" },
  { label: "rot__axis_angle", kind: CompletionItemKind.Function, detail: "(axis: vec4, angle: f64) -> mat4", documentation: "Returns rotation matrix around axis by angle (radians)" },
  { label: "ortho__pos_right_up_forward", kind: CompletionItemKind.Function, detail: "(pos, right, up, forward) -> mat4", documentation: "Returns orthogonal view matrix from position and axes" },
  { label: "proj__fov_near_far_ar", kind: CompletionItemKind.Function, detail: "(fov, near, far, ar) -> mat4", documentation: "Returns projection matrix from field of view, near/far clip, aspect ratio" },
  { label: "mvp__model_view_projection", kind: CompletionItemKind.Function, detail: "(model, view, projection) -> mat4", documentation: "Returns model-view-projection matrix" },
  { label: "scale", kind: CompletionItemKind.Function, detail: "(v: vec4) -> mat4", documentation: "Returns scale matrix (ignores 4th component)" },

  // Color functions
  { label: "str__color", kind: CompletionItemKind.Function, detail: "(color: vec4) -> str", documentation: "Returns HTML hex color string (clamped 0-1)" },
  { label: "srgb_to_linear__color", kind: CompletionItemKind.Function, detail: "(color: vec4) -> vec4", documentation: "Converts sRGB to linear color space (for math operations)" },
  { label: "linear_to_srgb__color", kind: CompletionItemKind.Function, detail: "(color: vec4) -> vec4", documentation: "Converts linear to sRGB color space (after math operations)" },

  // Option/Result types
  { label: "none", kind: CompletionItemKind.Function, detail: "() -> opt[any]", documentation: "Creates none() option variant" },
  { label: "some", kind: CompletionItemKind.Function, detail: "(var) -> opt[any]", documentation: "Creates some(var) option variant" },
  { label: "ok", kind: CompletionItemKind.Function, detail: "(var) -> res[any]", documentation: "Creates ok(var) result variant" },
  { label: "err", kind: CompletionItemKind.Function, detail: "(var) -> res[any]", documentation: "Creates err(var) result variant" },
  { label: "unwrap", kind: CompletionItemKind.Function, detail: "(var) -> any", documentation: "Unwraps value from some(x) or ok(x)" },
  { label: "unwrap_err", kind: CompletionItemKind.Function, detail: "(var) -> any", documentation: "Unwraps error from err(x)" },
  { label: "unwrap_or", kind: CompletionItemKind.Function, detail: "(var, def) -> any", documentation: "Unwraps value or returns default (lazy evaluation)" },
  { label: "is_err", kind: CompletionItemKind.Function, detail: "(var: res) -> bool", documentation: "Returns true if err(x)" },
  { label: "is_ok", kind: CompletionItemKind.Function, detail: "(var: res) -> bool", documentation: "Returns true if ok(x)" },

  // Module functions
  { label: "load", kind: CompletionItemKind.Function, detail: "(source: str) -> res[any]", documentation: "Loads module from source file" },
  { label: "load__source_imports", kind: CompletionItemKind.Function, detail: "(source: str, imports: [any]) -> res[any]", documentation: "Loads module with dependencies" },
  { label: "module__in_string_imports", kind: CompletionItemKind.Function, detail: "(name: str, code: str, imports: [any]) -> res[any]", documentation: "Creates module from string" },
  { label: "check__in_string_imports", kind: CompletionItemKind.Function, detail: "(name: str, code: str, imports: [any]) -> res[[{}]]", documentation: "Returns lifetime/type-checker data (ignores errors)" },
  { label: "call", kind: CompletionItemKind.Function, detail: "(module, function: str, arguments: [any])", documentation: "Calls function in module" },
  { label: "call_ret", kind: CompletionItemKind.Function, detail: "(module, function: str, arguments: [any]) -> any", documentation: "Calls function and returns result" },
  { label: "functions", kind: CompletionItemKind.Function, detail: "() -> any", documentation: "Returns list of available functions (sorted)" },
  { label: "functions__module", kind: CompletionItemKind.Function, detail: "(module) -> any", documentation: "Returns list of functions in module (sorted)" },

  // Object functions
  { label: "has", kind: CompletionItemKind.Function, detail: "(obj: {}, key: str) -> bool", documentation: "Returns true if object has key" },
  { label: "keys", kind: CompletionItemKind.Function, detail: "(obj: {}) -> [str]", documentation: "Returns all keys of object" },

  // File I/O functions
  { label: "load_string__file", kind: CompletionItemKind.Function, detail: "(file: str) -> res[str]", documentation: "Loads string from file" },
  { label: "load_string__url", kind: CompletionItemKind.Function, detail: "(url: str) -> res[str]", documentation: "Loads string from URL" },
  { label: "save__string_file", kind: CompletionItemKind.Function, detail: "(string: str, file: str) -> res[str]", documentation: "Saves string to file" },
  { label: "download__url_file", kind: CompletionItemKind.Function, detail: "(url: str, file: str) -> res[str]", documentation: "Downloads file from URL" },
  { label: "load_data__file", kind: CompletionItemKind.Function, detail: "(file: str) -> res[any]", documentation: "Loads Dyon data from file" },
  { label: "save__data_file", kind: CompletionItemKind.Function, detail: "(data, file: str) -> res[str]", documentation: "Saves Dyon data to file" },
  { label: "load_data__string", kind: CompletionItemKind.Function, detail: "(string: str) -> res[any]", documentation: "Loads Dyon data from string" },

  // Meta/parsing functions
  { label: "load__meta_file", kind: CompletionItemKind.Function, detail: "(meta_file: str, file: str) -> res[[[any]]]", documentation: "Loads meta data from file using Piston-Meta syntax" },
  { label: "load__meta_url", kind: CompletionItemKind.Function, detail: "(meta_file: str, url: str) -> res[[any]]", documentation: "Loads meta data from URL using Piston-Meta syntax" },
  { label: "syntax__in_string", kind: CompletionItemKind.Function, detail: "(name: str, text: str) -> res[any]", documentation: "Parses meta syntax rules from string" },
  { label: "meta__syntax_in_string", kind: CompletionItemKind.Function, detail: "(syntax, name: str, text: str) -> res[[any]]", documentation: "Parses meta data from string" },
  { label: "json_from_meta_data", kind: CompletionItemKind.Function, detail: "(meta_data: [[any]]) -> str", documentation: "Generates JSON from meta data" },

  // JSON functions
  { label: "json_parse", kind: CompletionItemKind.Function, detail: "(json: str) -> any", documentation: "Parses JSON string into data structure" },
  { label: "json_stringify", kind: CompletionItemKind.Function, detail: "(data) -> str", documentation: "Converts data structure to JSON string" },

  // Threading functions
  { label: "join__thread", kind: CompletionItemKind.Function, detail: "(t: thr) -> res[any]", documentation: "Waits for thread to finish and returns result" },
  { label: "wait_next", kind: CompletionItemKind.Function, detail: "(channel: in) -> opt[any]", documentation: "Blocks thread until message received from channel" },
  { label: "next", kind: CompletionItemKind.Function, detail: "(channel: in) -> opt[any]", documentation: "Checks for message on channel (non-blocking)" },

  // Time functions
  { label: "now", kind: CompletionItemKind.Function, detail: "() -> f64", documentation: "Returns seconds since Unix Epoch (negative if before)" },
  { label: "time_parse_duration", kind: CompletionItemKind.Function, detail: "(duration: str) -> f64", documentation: "Parses duration string and returns seconds" },
  { label: "time_format_date", kind: CompletionItemKind.Function, detail: "(timestamp: f64, format: str) -> str", documentation: "Formats Unix timestamp as date string" },

  // Crypto functions
  { label: "crypto_hash", kind: CompletionItemKind.Function, detail: "(algorithm: str, data: str) -> str", documentation: "Computes cryptographic hash using specified algorithm" },
  { label: "crypto_hmac", kind: CompletionItemKind.Function, detail: "(algorithm: str, key: str, data: str) -> str", documentation: "Computes HMAC using specified algorithm and key" },

  // System functions
  { label: "get_constant", kind: CompletionItemKind.Function, detail: "(key: str) -> any", documentation: "Gets constant value by key" },
  { label: "get_setting", kind: CompletionItemKind.Function, detail: "(key: str) -> any", documentation: "Gets setting value by key" },
  { label: "get_setting_full", kind: CompletionItemKind.Function, detail: "(key: str) -> any", documentation: "Gets full setting information by key" },
  { label: "locale", kind: CompletionItemKind.Function, detail: "(key: str) -> any", documentation: "Gets localized string by key" },
  { label: "has_constant", kind: CompletionItemKind.Function, detail: "(key: str) -> bool", documentation: "Returns true if constant exists" },
  { label: "has_setting", kind: CompletionItemKind.Function, detail: "(key: str) -> bool", documentation: "Returns true if setting exists" },
  { label: "validate_setting", kind: CompletionItemKind.Function, detail: "(key: str) -> any", documentation: "Validates setting by key" },
  { label: "list_locales", kind: CompletionItemKind.Function, detail: "(key: str) -> any", documentation: "Returns list of available locales" },
  { label: "list_settings", kind: CompletionItemKind.Function, detail: "() -> any", documentation: "Returns list of all available settings" },
  { label: "list_constants", kind: CompletionItemKind.Function, detail: "() -> any", documentation: "Returns list of all available constants" },
  { label: "get_manifest", kind: CompletionItemKind.Function, detail: "() -> any", documentation: "Returns program manifest information" },
  { label: "get_permissions", kind: CompletionItemKind.Function, detail: "() -> any", documentation: "Returns the permissions data" },
  { label: "is_disabled", kind: CompletionItemKind.Function, detail: "() -> bool", documentation: "Returns true if functionality is disabled" },
];