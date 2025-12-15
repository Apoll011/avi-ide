// providers/builtin.ts
import { CompletionItem, InsertTextFormat } from "vscode-languageserver/node";
import { AVI_BUILTINS } from "../builtins";

function countArgs(signature?: string | null): string[] {
  if (!signature) return [];

  const match = signature.match(/\(([^)]*)\)/);
  if (!match) return [];

  const inside = match[1].trim();
  if (inside === "") return [];

  return inside
    .split(",")
    .map(s => s.trim())
    .filter(Boolean);
}

function makeSnippet(label: string, args: string[]): string {
  if (args.length === 0) {
    return `${label}()`;
  }

  const placeholders = args.map((arg, i) => {
    const name = arg.split(":")[0].trim();
    return `\${${i + 1}:${name || "arg"}}`;
  });

  return `${label}(${placeholders.join(", ")})`;
}

export function builtinCompletions(): CompletionItem[] {
  return AVI_BUILTINS.map((sym) => {
    const item: CompletionItem = {
      ...sym,
      data: sym.label + "_" + sym.kind,
    };

    if (sym.detail) {
      const args = countArgs(sym.detail);

      item.insertText = makeSnippet(sym.label, args);
      item.insertTextFormat = InsertTextFormat.Snippet;
    }

    return item;
  });
}
