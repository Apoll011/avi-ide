import {
  CompletionItem,
  CompletionItemKind,
  InsertTextFormat,
} from "vscode-languageserver/node";
import { TextDocument } from "vscode-languageserver-textdocument";

import { extractFunctions, extractVariables, extractArgNames, parseDoubleUnderscoreLabel, makeSnippet, FunctionScope, extractFunctionScopes, findScopeAtOffset } from "./utils";

export function currentFileCompletions(
  document: TextDocument
): CompletionItem[] {
  const text = document.getText();

  const items: CompletionItem[] = [];

  /* ---------------- FUNCTIONS ---------------- */

  for (const fn of extractFunctions(text)) {
    const { baseLabel, mandatoryArgs } =
      parseDoubleUnderscoreLabel(fn.name);

    const signatureArgs = extractArgNames(fn.signature);

    const item: CompletionItem = {
      label: baseLabel,
      kind: CompletionItemKind.Function,
      data: `workspace_fn_${baseLabel}`,
    };

    item.insertText = makeSnippet(
      baseLabel,
      mandatoryArgs,
      signatureArgs
    );
    item.insertTextFormat = InsertTextFormat.Snippet; 

    items.push(item);
  }

  /* ---------------- VARIABLES ---------------- */

  for (const name of extractVariables(text).globals) {
    items.push({
      label: name,
      kind: CompletionItemKind.Variable,
      data: `workspace_var_${name}`,
    });
  }
  return items;
}
