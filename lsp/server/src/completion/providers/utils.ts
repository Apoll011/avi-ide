import { FN_REGEX, VAR_REGEX } from "./regex";

export interface WorkspaceFunction {
  name: string;
  signature: string;
}

export function parseDoubleUnderscoreLabel(label: string): {
  baseLabel: string;
  mandatoryArgs: string[];
} {
  const parts = label.split("__");
  if (parts.length === 1) {
    return { baseLabel: label, mandatoryArgs: [] };
  }

  return {
    baseLabel: parts[0],
    mandatoryArgs: parts[1].split("_"),
  };
}

export function makeSnippet(
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
    if (!args.includes(name) && mandatoryArgs.length === 0) {
      args.push(name);
    }
  }

  if (args.length === 0) {
    return `${label}()`;
  }

  const placeholders = args.map((name, i) => {
    return `${name}: \${${i + 1}:${mandatoryArgs.length === 0 ? name : signatureArgs[i].split(":")[0].trim()}}`;
  });

  return `${label}(${placeholders.join(", ")})`;
}

export function extractFunctions(text: string): WorkspaceFunction[] {
  const result: WorkspaceFunction[] = [];
  let match: RegExpExecArray | null;

  while ((match = FN_REGEX.exec(text))) {
    const name = match[1];
    const args = match[2] ?? "";
    result.push({
      name,
      signature: `${name}(${args})`,
    });
  }

  return result;
}

export function extractVariables(text: string): string[] {
  const vars = new Set<string>();
  let match: RegExpExecArray | null;

  while ((match = VAR_REGEX.exec(text))) {
    vars.add(match[1]);
  }

  return [...vars];
}

export function extractArgNames(argString: string): string[] {
  if (!argString) return [];

  const match = argString.match(/\(([^)]*)\)/);
  if (!match) return [];

  const inside = match[1].trim();
  if (inside === "") return [];

  return inside
    .split(",")
    .map((arg: string) => arg.trim())
    .map((arg: string) =>
      arg
        .replace(/^mut\s+/, "")
        .split(":")[0]
        .trim()
    );
}