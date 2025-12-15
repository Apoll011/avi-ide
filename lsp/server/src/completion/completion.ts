// completion.ts
import {
  CompletionItem,
  TextDocumentPositionParams,
  TextDocuments,
} from "vscode-languageserver/node";

import { builtinCompletions } from "./providers/builtins";
import { currentFileCompletions } from "./providers/currentFile";
import { TextDocument } from "vscode-languageserver-textdocument";
import { completionfromScope } from "./providers/scope";

export function completionHandler(
  documents: TextDocuments<TextDocument>,
): (pos: TextDocumentPositionParams) => CompletionItem[] {
  return (pos: TextDocumentPositionParams) => {
  const document = documents.get(pos.textDocument.uri);
    return [
    ...builtinCompletions(),
    ...(document ? currentFileCompletions(document) : []),
    ...(document ? completionfromScope(document, pos) : []),
  ];
  }
}

export function completionResolve(item: CompletionItem): CompletionItem {
    return {
      ...item,
      documentation: item.documentation,
    };
}
