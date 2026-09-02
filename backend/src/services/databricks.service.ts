import { env, isDatabricksConfigured } from "../config/env";
import { getDatabricksToken } from "../config/databricks-auth";

/**
 * Databricks SQL Statement Execution API client — runs analytical
 * queries against the configured SQL Warehouse / Delta tables
 * (c_qube_catalog.campus). Server-only; the token never reaches the
 * browser, and the frontend never talks to Databricks directly.
 */

function warehouseId(): string {
  // http_path looks like /sql/1.0/warehouses/<id>
  const parts = env.databricks.httpPath.split("/").filter(Boolean);
  return parts[parts.length - 1] ?? "";
}

function baseUrl() {
  const host = env.databricks.host.replace(/^https?:\/\//, "").replace(/\/$/, "");
  return `https://${host}`;
}

interface StatementResult {
  columns: string[];
  rows: (string | null)[][];
}

interface SqlStatementResponse {
  status: { state: string; error?: { message: string } };
  manifest?: { schema: { columns: { name: string }[] } };
  result?: { data_array: (string | null)[][] };
  statement_id: string;
}

async function fetchStatement(path: string): Promise<SqlStatementResponse> {
  const token = await getDatabricksToken();
  const res = await fetch(`${baseUrl()}${path}`, {
    headers: { Authorization: `Bearer ${token}` },
    signal: AbortSignal.timeout(30000),
  });
  if (!res.ok) throw new Error(`Databricks SQL API ${res.status}`);
  return (await res.json()) as SqlStatementResponse;
}

/**
 * Executes a SQL statement against the configured warehouse/catalog/schema
 * and returns column names + rows. Throws if the warehouse/table isn't
 * reachable or the query fails — callers should catch and fall back.
 */
export async function executeStatement(statement: string): Promise<StatementResult> {
  if (!isDatabricksConfigured) {
    throw new Error("Databricks SQL Warehouse is not configured.");
  }

  const token = await getDatabricksToken();
  const res = await fetch(`${baseUrl()}/api/2.0/sql/statements`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      statement,
      warehouse_id: warehouseId(),
      catalog: env.databricks.catalog,
      schema: env.databricks.schema,
      wait_timeout: "30s",
    }),
    signal: AbortSignal.timeout(35000),
  });
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    throw new Error(`Databricks SQL API ${res.status}: ${body.slice(0, 300)}`);
  }
  let data = (await res.json()) as SqlStatementResponse;

  // Poll if the warehouse hadn't finished within wait_timeout.
  let attempts = 0;
  while (
    (data.status?.state === "PENDING" || data.status?.state === "RUNNING") &&
    attempts < 10
  ) {
    await new Promise((r) => setTimeout(r, 1500));
    data = await fetchStatement(`/api/2.0/sql/statements/${data.statement_id}`);
    attempts++;
  }

  if (data.status?.state !== "SUCCEEDED") {
    throw new Error(data.status?.error?.message ?? `Query did not succeed (${data.status?.state}).`);
  }

  return {
    columns: data.manifest?.schema.columns.map((c) => c.name) ?? [],
    rows: data.result?.data_array ?? [],
  };
}
