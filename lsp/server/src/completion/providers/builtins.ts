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

function parseDoubleUnderscoreLabel(label: string): {
  baseLabel: string;
  mandatoryArgs: string[];
} {
  const parts = label.split("__");
  if (parts.length === 1) {
    return { baseLabel: label, mandatoryArgs: [] };
  }

  return {
    baseLabel: parts[0],
    mandatoryArgs: parts.slice(1),
  };
}

function makeSnippet(
  label: string,
  mandatoryArgs: string[],
  signatureArgs: string[]
): string {
  const args: string[] = [];

  for (const name of mandatoryArgs) {
    args.push(name);
  }

  for (const arg of signatureArgs) {
    const name = arg.split(":")[0].trim();
    if (!args.includes(name)) {
      args.push(name);
    }
  }

  if (args.length === 0) {
    return `${label}()`;
  }

  const placeholders = args.map((name, i) => {
    return `${name}: \${${i + 1}:${name}}`;
  });

  return `${label}(${placeholders.join(", ")})`;
}

export function builtinCompletions(): CompletionItem[] {
  return AVI_BUILTINS.map((sym) => {
    const { baseLabel, mandatoryArgs } =
      parseDoubleUnderscoreLabel(sym.label);

    const signatureArgs = sym.detail
      ? countArgs(sym.detail)
      : [];

    const item: CompletionItem = {
      ...sym,
      label: baseLabel,
      data: sym.label + "_" + sym.kind,
    };

    if (mandatoryArgs.length > 0 || sym.detail) {
      item.insertText = makeSnippet(
        baseLabel,
        mandatoryArgs,
        signatureArgs
      );
      item.insertTextFormat = InsertTextFormat.Snippet;
    }

    return item;
  });
}
