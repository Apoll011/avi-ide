// completion.ts
import {
  CompletionItem,
  TextDocumentPositionParams,
} from "vscode-languageserver/node";

import { builtinCompletions } from "./providers/builtins";
import { workspaceCompletions } from "./providers/workspace";

export function completionHandler(
  _pos: TextDocumentPositionParams
): CompletionItem[] {
  return [
    ...builtinCompletions(),
    ...workspaceCompletions(), // future parser symbols
  ];
}

export function completionResolve(item: CompletionItem): CompletionItem {
    return {
      ...item,
      documentation: item.documentation,
    };
}
