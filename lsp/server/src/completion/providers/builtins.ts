// providers/builtin.ts
import { CompletionItem, CompletionItemKind, InsertTextFormat } from "vscode-languageserver/node";
import { AVI_BUILTINS } from "../builtins";
import { extractArgNames, makeSnippet, parseDoubleUnderscoreLabel } from "./utils";

function generateFunctionCompletionItem(sym: CompletionItem): CompletionItem {
    const { baseLabel, mandatoryArgs } =
      parseDoubleUnderscoreLabel(sym.label);

    const signatureArgs = sym.detail
      ? extractArgNames(sym.detail)
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
}

function generateTypeParameter(sym: CompletionItem): CompletionItem {
    const item: CompletionItem = {
      ...sym,
      data: sym.label + "_" + sym.kind,
    };
    return item;
}

function generateKeyword(sym: CompletionItem): CompletionItem {
    const item: CompletionItem = {
      ...sym,
      data: sym.label + "_" + sym.kind,
    };
    return item;
}

function generateGeneric(sym: CompletionItem): CompletionItem {
    const item: CompletionItem = {
      ...sym,
      data: sym.label + "_" + sym.kind,
    };
    return item;
}

export function builtinCompletions(): CompletionItem[] {
  return AVI_BUILTINS.map((sym) => {
      switch (sym.kind) {
        case CompletionItemKind.Function:
          return generateFunctionCompletionItem(sym);
        case CompletionItemKind.TypeParameter:
          return generateTypeParameter(sym);
        case CompletionItemKind.Keyword:
          return generateKeyword(sym);
        default:
          return generateGeneric(sym);
      }
    });
}