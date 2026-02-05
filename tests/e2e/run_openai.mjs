import fs from "node:fs";
import path from "node:path";
import os from "node:os";

function fail(msg, code = 1) {
  console.error(msg);
  process.exit(code);
}

const apiKey = process.env.OPENAI_API_KEY;
if (!apiKey) fail("FAIL: OPENAI_API_KEY is not set", 2);

// IMPORTANT: Must match tests/e2e/fixtures/basic-feature/metadata.json keys exactly.
const system = [
  "You are generating ONLY file contents for a requirements output.",
  "Return STRICT JSON with keys: metadata_json, sample_code_ts.",
  "",
  "metadata_json MUST be a JSON STRING that matches EXACTLY this key schema:",
  "{",
  '  "_schema": "2.0",',
  '  "request": <string>,',
  '  "status": "complete",',
  '  "phase": "complete",',
  '  "started": <ISO-8601>,',
  '  "lastUpdated": <ISO-8601>,',
  '  "complexity": { "level": "moderate", "questionCounts": { "discovery": 5, "detail": 5 } },',
  '  "progress": { "discovery": { "answered": 5, "total": 5 }, "detail": { "answered": 5, "total": 5 } },',
  '  "validation": { "status": "passed", "score": 90, "blocking": 0, "warnings": 2 },',
  '  "todos": { "status": "injected", "total": 3, "open": 2, "done": 1, "files": ["src/auth.ts","src/login.ts"] }',
  "}",
  "",
  "sample_code_ts MUST be a TypeScript string containing TODO comment lines that include:",
  "- [P:N] where N is 1..3",
  "- [ID:TODO-001] style IDs (zero-padded)",
  "- include at least one [P:3] TODO line (1-line format).",
  "",
  "Return STRICT JSON only. No markdown."
].join("\n");

const user = [
  'Set request to: "Add user authentication feature".',
  "Use started and lastUpdated as ISO-8601 Zulu timestamps (ending in Z).",
  "Ensure todos total=3 open=2 done=1 and open+done=total.",
  "Return STRICT JSON only."
].join("\n");

async function callOpenAI() {
  const body = {
    model: "gpt-4.1-mini",
    temperature: 0,
    response_format: { type: "json_object" },
    messages: [
      { role: "system", content: system },
      { role: "user", content: user }
    ]
  };

  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body)
  });

  const json = await res.json();
  if (!res.ok) fail("ERROR OpenAI: " + JSON.stringify(json).slice(0, 600), 3);

  const content = json?.choices?.[0]?.message?.content;
  if (!content) fail("ERROR: No content returned from OpenAI", 3);

  let parsed;
  try { parsed = JSON.parse(content); } catch {
    fail("ERROR: Model did not return JSON. Starts: " + content.slice(0, 200), 3);
  }

  const { metadata_json, sample_code_ts } = parsed;
  if (typeof metadata_json !== "string" || typeof sample_code_ts !== "string") {
    fail("ERROR: Response must include string fields metadata_json and sample_code_ts", 3);
  }

  return { metadata_json, sample_code_ts };
}

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "ccrb-openai-"));
const outDir = path.join(tmp, "requirements");
fs.mkdirSync(outDir, { recursive: true });

const { metadata_json, sample_code_ts } = await callOpenAI();

fs.writeFileSync(path.join(outDir, "metadata.json"), metadata_json, "utf8");
fs.writeFileSync(path.join(outDir, "sample-code.ts"), sample_code_ts, "utf8");

console.log(outDir);
