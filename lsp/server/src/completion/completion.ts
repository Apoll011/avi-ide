// completion.ts
import {
  CompletionItem,
  TextDocumentPositionParams,
  TextDocuments,
} from "vscode-languageserver/node";
import { TextDocument } from "vscode-languageserver-textdocument";

import { builtinCompletions } from "./providers/builtins";
import { currentFileCompletions } from "./providers/currentFile";
import { completionfromScope } from "./providers/scope";
import { configProviders } from "../server";

export function completionHandler(
  documents: TextDocuments<TextDocument>,
): (pos: TextDocumentPositionParams) => CompletionItem[] {
  return (pos: TextDocumentPositionParams) => {
    const document = documents.get(pos.textDocument.uri);
    
    return [
      ...(document && configProviders ? configProviders.getCompletions(document, pos) : []),
      ...(document ? completionfromScope(document, pos) : []),
      ...(document ? currentFileCompletions(document) : []),
      ...builtinCompletions(),
    ];
  };
}

export function completionResolve(item: CompletionItem): CompletionItem {
  return {
    ...item,
    documentation: item.documentation,
  };
}