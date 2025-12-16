// providers/configBased/index.ts
import {
  CompletionItem,
  CompletionItemKind,
  TextDocumentPositionParams,
} from "vscode-languageserver/node";
import { TextDocument } from "vscode-languageserver-textdocument";
import * as yaml from "js-yaml";
import * as fs from "fs";
import * as path from "path";

/**
 * Domain Model: Represents a function that can provide completions
 * based on configuration data
 */
export interface CompletionFunction {
  /** Function name to match in the DSL */
  functionName: string;
  
  /** Argument position (0-indexed) where completion should trigger */
  argumentPosition: number;
  
  /** Path to YAML config file relative to workspace */
  configPath: string;
  
  /** JSON path to extract values from YAML (e.g., "language" for top-level key) */
  dataPath: string;
    
  /** Optional: description template for completion items */
  descriptionTemplate?: string;

  parser: (value: unknown) => unknown;
}

/**
 * Domain Model: Configuration schema for the completion system
 */
export interface CompletionConfig {
  functions: CompletionFunction[];
}

/**
 * Provider that generates completions based on YAML configuration files
 */
export class ConfigBasedCompletionProvider {
  private config: CompletionConfig;
  private workspaceRoot: string;
  private dataCache: Map<string, any> = new Map();

  constructor(workspaceRoot?: string) {
    console.log(`ConfigBasedCompletionProvider initialized with workspace: ${workspaceRoot}`);
    this.workspaceRoot = workspaceRoot || process.cwd();
    this.config = this.loadConfig();
    this.preloadData();
    console.log(`Loaded config for functions: ${this.config.functions.map(f => f.functionName).join(", ")}`);
  }

  /**
   * Load the main configuration that defines which functions
   * use which YAML files
   */
  private loadConfig(): CompletionConfig {
    return {
      functions: [
        {
          functionName: "locale",
          argumentPosition: 0,
          configPath: "responses/en.lang",
          dataPath: "language",
          parser: (value) => Object.keys((value as any).lang)
        },
      ],
    };
  }

  /**
   * Preload all YAML data files into cache
   */
  private preloadData(): void {
    for (const func of this.config.functions) {
      this.loadDataForFunction(func);
    }
  }

  /**
   * Load and cache data for a specific function configuration
   */
  private loadDataForFunction(func: CompletionFunction): string[] | any {
    if (this.dataCache.has(func.configPath)) {
      return this.dataCache.get(func.configPath);
    }

    const fullPath = path.join(this.workspaceRoot, func.configPath);
    if (!fs.existsSync(fullPath)) {
      return null;
    }

    try {
      const content = fs.readFileSync(fullPath, "utf-8");
      const data = yaml.load(content);

      this.dataCache.set(func.configPath, func.parser(data));
      return data;
    } catch (error) {
      console.error(`Error loading ${fullPath}:`, error);
      return null;
    }
  }

  /**
   * Check if the current position is inside a function call
   * that matches our configured functions
   */
  private detectFunctionContext(
    document: TextDocument,
    pos: TextDocumentPositionParams
  ): { func: CompletionFunction; needsQuotes: boolean } | null {
    const text = document.getText();
    const offset = document.offsetAt(pos.position);

    // Get more context - look back further
    const beforeCursor = text.substring(Math.max(0, offset - 500), offset);
    const afterCursor = text.substring(offset, Math.min(text.length, offset + 50));

    for (const func of this.config.functions) {
      const funcPattern = new RegExp(`(?:^|[\\s;,({\\[]|\\.)${func.functionName}\\s*\\(([^)]*)`, "gi");

      let match;
      funcPattern.lastIndex = 0;
      
      while ((match = funcPattern.exec(beforeCursor)) !== null) {
        const insideParens = match[1];
        
        const argIndex = this.countArgumentPosition(insideParens);

        if (argIndex === func.argumentPosition) {
          let currentArg = insideParens.split(",")[argIndex]?.trim() || "";
          let currentArgSplit = currentArg.split(":");
          if (currentArgSplit.length > 1) {
            currentArg = currentArgSplit[1].trim();
          }
          const needsQuotes =  currentArg.startsWith('"') === false && currentArg.startsWith("'") === false;
          
          return { func, needsQuotes };
        }
      }
    }

    return null;
  }

  private countArgumentPosition(insideParens: string): number {
    if (!insideParens.trim()) {
      return 0;
    }

    let depth = 0;
    let inString = false;
    let stringChar = '';
    let argCount = 0;
    
    for (let i = 0; i < insideParens.length; i++) {
      const char = insideParens[i];
      const prevChar = i > 0 ? insideParens[i - 1] : '';

      if ((char === '"' || char === "'" || char === '`') && prevChar !== '\\') {
        if (!inString) {
          inString = true;
          stringChar = char;
        } else if (char === stringChar) {
          inString = false;
          stringChar = '';
        }
      }

      if (inString) continue;

      if (char === '(' || char === '[' || char === '{') {
        depth++;
      } else if (char === ')' || char === ']' || char === '}') {
        depth--;
      }

      if (char === ',' && depth === 0) {
        argCount++;
      }
    }

    return argCount;
  }

  getCompletions(
    document: TextDocument,
    pos: TextDocumentPositionParams
  ): CompletionItem[] {
    const context = this.detectFunctionContext(document, pos);

    if (!context) {
      return [];
    }

    const { func: funcContext, needsQuotes } = context;
    const data: string[] = this.loadDataForFunction(funcContext);

    return data.map((value) => {
      const insertText = needsQuotes ? `"${value}"` : value;
      
      return {
        label: value,
        kind: CompletionItemKind.Value,
        insertText,
        detail: funcContext.descriptionTemplate
          ? funcContext.descriptionTemplate.replace("${value}", value)
          : `From ${funcContext.configPath}`,
        data: `config_${funcContext.functionName}_${value}`,
      };
    });
  }

  /**
   * Reload configuration and data (useful for hot-reloading)
   */
  reload(): void {
    this.dataCache.clear();
    this.config = this.loadConfig();
    this.preloadData();
  }
}