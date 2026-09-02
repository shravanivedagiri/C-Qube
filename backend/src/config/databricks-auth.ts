import { env } from "./env";

/**
 * Supplies a bearer token for Databricks REST calls, in one of two modes:
 *
 *  1. OAuth machine-to-machine (recommended, and the only option when a
 *     workspace has personal access tokens disabled — a common admin
 *     policy). Requires DATABRICKS_CLIENT_ID + DATABRICKS_CLIENT_SECRET
 *     from a Databricks *service principal* (Settings → Identity and
 *     access → Service principals → Secrets → Generate secret). This
 *     module exchanges them for a short-lived (1hr) access token via
 *     the client_credentials grant and refreshes it automatically.
 *
 *  2. A static personal access token (DATABRICKS_ACCESS_TOKEN) — kept
 *     as a fallback for workspaces where PATs are still allowed.
 *
 * Callers just `await getDatabricksToken()` — they don't need to know
 * which mode is active.
 */

let cachedToken: { value: string; expiresAt: number } | null = null;

function baseUrl() {
  const host = env.databricks.host.replace(/^https?:\/\//, "").replace(/\/$/, "");
  return `https://${host}`;
}

async function fetchOAuthToken(): Promise<{ value: string; expiresAt: number }> {
  const credentials = Buffer.from(
    `${env.databricks.clientId}:${env.databricks.clientSecret}`
  ).toString("base64");

  const res = await fetch(`${baseUrl()}/oidc/v1/token`, {
    method: "POST",
    headers: {
      Authorization: `Basic ${credentials}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials&scope=all-apis",
    signal: AbortSignal.timeout(15000),
  });

  if (!res.ok) {
    const body = await res.text().catch(() => "");
    throw new Error(`Databricks OAuth token request failed (${res.status}): ${body.slice(0, 300)}`);
  }

  const data = (await res.json()) as { access_token: string; expires_in: number };
  // Refresh a little early rather than racing the exact expiry.
  const expiresAt = Date.now() + (data.expires_in - 60) * 1000;
  return { value: data.access_token, expiresAt };
}

export async function getDatabricksToken(): Promise<string> {
  const usingOAuth = Boolean(env.databricks.clientId && env.databricks.clientSecret);

  if (!usingOAuth) {
    if (!env.databricks.accessToken) {
      throw new Error("Databricks is not configured — set either a service-principal OAuth pair or an access token.");
    }
    return env.databricks.accessToken;
  }

  if (cachedToken && cachedToken.expiresAt > Date.now()) {
    return cachedToken.value;
  }
  cachedToken = await fetchOAuthToken();
  return cachedToken.value;
}
