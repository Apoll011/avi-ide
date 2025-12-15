import {
  CompletionItem,
  CompletionItemKind,
  TextDocumentPositionParams,
} from "vscode-languageserver/node";

import { TextDocument } from "vscode-languageserver-textdocument";
import { extractFunctionScopes, findScopeAtOffset } from "./utils";

export function completionfromScope(
    document: TextDocument, 
    position: TextDocumentPositionParams
): CompletionItem[] {
    const text = document.getText();
    const offset = document.offsetAt(position.position);
  
    const scopes = extractFunctionScopes(text);
    const scope = findScopeAtOffset(scopes, offset);
    
    if (!scope) return [];
    
    const items: CompletionItem[] = [];
    
    for (const arg of scope.args) {
        items.push({
            label: arg,
            kind: CompletionItemKind.Variable,
            data: `arg_${arg}`,
        });
    }
    
    for (const local of scope.locals) {
        items.push({
            label: local,
            kind: CompletionItemKind.Variable,
            data: `local_${local}`,
        });
    }
    
    return items;
}