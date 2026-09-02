import "dotenv/config";

function required(name: string): string {
  const value = process.env[name];
  if (!value) {
    // Fail loudly at boot rather than surfacing a confusing error deep in
    // a request handler later.
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

export const env = {
  port: Number(process.env.PORT ?? 4000),
  corsOrigins: (process.env.CORS_ORIGINS ?? "http://localhost:3000")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean),

  supabaseUrl: required("SUPABASE_URL"),
  supabaseSecretKey: required("SUPABASE_SECRET_KEY"),

  databricks: {
    host: process.env.DATABRICKS_SERVER_HOSTNAME ?? "",
    httpPath: process.env.DATABRICKS_HTTP_PATH ?? "",
    catalog: process.env.DATABRICKS_CATALOG ?? "c_qube_catalog",
    schema: process.env.DATABRICKS_SCHEMA ?? "campus",
    genieSpaceId: process.env.DATABRICKS_GENIE_SPACE_ID ?? "",

    // Two mutually-exclusive auth modes — see config/databricks-auth.ts.
    // Prefer clientId/clientSecret (OAuth service-principal, no personal
    // token needed) when both are set; accessToken (a static PAT) is
    // the legacy fallback.
    accessToken: process.env.DATABRICKS_ACCESS_TOKEN ?? "",
    clientId: process.env.DATABRICKS_CLIENT_ID ?? "",
    clientSecret: process.env.DATABRICKS_CLIENT_SECRET ?? "",
  },

  allowedEmailDomain: process.env.ALLOWED_EMAIL_DOMAIN ?? "bmsce.ac.in",
};

const hasOAuth = Boolean(env.databricks.clientId && env.databricks.clientSecret);
const hasPat = Boolean(env.databricks.accessToken);

export const isDatabricksAuthConfigured = hasOAuth || hasPat;

export const isDatabricksConfigured = Boolean(
  env.databricks.host && env.databricks.httpPath && isDatabricksAuthConfigured
);

export const isGenieConfigured = Boolean(
  env.databricks.host && env.databricks.genieSpaceId && isDatabricksAuthConfigured
);
