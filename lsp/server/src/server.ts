import {
	createConnection,
	TextDocuments,
	ProposedFeatures,
	InitializeParams,
	TextDocumentSyncKind,
	InitializeResult,
	DocumentDiagnosticReport,
	DocumentDiagnosticReportKind,
} from 'vscode-languageserver/node';

import {
	TextDocument
} from 'vscode-languageserver-textdocument';
import { completionHandler, completionResolve } from './completion/completion';

const connection = createConnection(ProposedFeatures.all);

const documents = new TextDocuments(TextDocument);

connection.onInitialize((params: InitializeParams) => {
	const capabilities = params.capabilities;
	
	const result: InitializeResult = {
		capabilities: {
			textDocumentSync: TextDocumentSyncKind.Incremental,
			completionProvider: {
				resolveProvider: true
			},
			diagnosticProvider: {
				interFileDependencies: false,
				workspaceDiagnostics: false
			},
			workspace: {
				workspaceFolders: {
					supported: false
				}
			}
		}
	};
	return result;
});

connection.onInitialized(() => {
	connection.sendNotification('window/showMessage', { type: 3, message: 'Avi LSP Server is running' });
});


connection.languages.diagnostics.on(async (params) => {
	const document = documents.get(params.textDocument.uri);
	if (document !== undefined) {
		return {
			kind: DocumentDiagnosticReportKind.Full,
			items: []
		} satisfies DocumentDiagnosticReport;
	} else {
		// We don't know the document. We can either try to read it from disk
		// or we don't report problems for it.
		return {
			kind: DocumentDiagnosticReportKind.Full,
			items: []
		} satisfies DocumentDiagnosticReport;
	}
});

connection.onCompletion(completionHandler(documents));
connection.onCompletionResolve(completionResolve);
documents.listen(connection);

connection.listen();
