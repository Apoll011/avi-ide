// completion.ts
import {
  CompletionItem,
  TextDocument,
  TextDocumentPositionParams,
  TextDocuments,
} from "vscode-languageserver/node";

import { builtinCompletions } from "./providers/builtins";
import { currentFileCompletions } from "./providers/currentFile";

export function completionHandler(
  documents: TextDocuments<TextDocument>,
): (pos: TextDocumentPositionParams) => CompletionItem[] {
  return (pos: TextDocumentPositionParams) => {
  const document = documents.get(pos.textDocument.uri);
    return [
    ...builtinCompletions(),
    ...(document ? currentFileCompletions(document) : []),
  ];
  }
}

export function completionResolve(item: CompletionItem): CompletionItem {
    return {
      ...item,
      documentation: item.documentation,
    };
}
