/**
 * Idempotent club-data import: reads CLUBS from ./club-data.ts, matches
 * each club's logo/banner from the given asset directories by filename,
 * uploads matched files to Supabase Storage, and upserts `clubs` rows
 * (matched on the unique `email` column, so re-running is safe).
 *
 * Usage:
 *   npx tsx scripts/import-clubs.ts --logos "<dir>" --banners "<dir>" [--domain bmsce.ac.in]
 *
 * Never invents or substitutes an asset: a club with no matching file
 * is imported with that field left null and reported at the end.
 */
import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import { existsSync, readdirSync, readFileSync } from "fs";
import { extname, join } from "path";
import { CLUBS, type ClubSeed } from "./club-data";

function arg(name: string): string | undefined {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 ? process.argv[i + 1] : undefined;
}

const logoDir = arg("logos");
const bannerDir = arg("banners");
const domain = arg("domain") ?? "bmsce.ac.in";

if (!logoDir || !bannerDir) {
  console.error("Usage: tsx scripts/import-clubs.ts --logos <dir> --banners <dir> [--domain <domain>]");
  process.exit(1);
}

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SECRET_KEY;
if (!supabaseUrl || !supabaseKey) {
  console.error("SUPABASE_URL and SUPABASE_SECRET_KEY must be set (see backend/.env).");
  process.exit(1);
}
const supabase = createClient(supabaseUrl, supabaseKey);

function slugify(name: string) {
  return name.toLowerCase().replace(/[^a-z0-9]+/g, "");
}

/** Finds the first file in `dir` whose name contains one of `keys` (case-insensitive). */
function findAsset(dir: string, keys: string[]): string | null {
  if (!existsSync(dir)) return null;
  const files = readdirSync(dir);
  for (const key of keys) {
    const match = files.find((f) => f.toLowerCase().includes(key.toLowerCase()));
    if (match) return join(dir, match);
  }
  return null;
}

async function uploadAsset(
  clubSlug: string,
  kind: "logo" | "banner",
  filePath: string
): Promise<string> {
  const ext = extname(filePath).slice(1) || "jpg";
  const storagePath = `clubs/${clubSlug}/${kind}.${ext}`;
  const bytes = readFileSync(filePath);
  const { error } = await supabase.storage
    .from("media")
    .upload(storagePath, bytes, { upsert: true, contentType: `image/${ext === "jpg" ? "jpeg" : ext}` });
  if (error) throw error;
  const { data } = supabase.storage.from("media").getPublicUrl(storagePath);
  return data.publicUrl;
}

interface Report {
  name: string;
  logo: "uploaded" | "missing";
  banner: "uploaded" | "missing";
  action: "created" | "updated";
}

async function importClub(club: ClubSeed): Promise<Report> {
  const slug = slugify(club.name);
  const email = `${slug}@${domain}`;

  const logoPath = findAsset(logoDir!, club.assetKeys);
  const bannerPath = findAsset(bannerDir!, club.assetKeys);

  const logo_url = logoPath ? await uploadAsset(slug, "logo", logoPath) : null;
  const banner_url = bannerPath ? await uploadAsset(slug, "banner", bannerPath) : null;

  const { data: existing } = await supabase.from("clubs").select("id").eq("email", email).maybeSingle();

  const row = {
    name: club.name,
    email,
    about: club.about,
    category: club.category,
    department: club.department,
    is_approved: true,
    profile_complete: true,
    ...(logo_url ? { logo_url } : {}),
    ...(banner_url ? { banner_url } : {}),
  };

  if (existing) {
    const { error } = await supabase.from("clubs").update(row).eq("id", existing.id);
    if (error) throw error;
  } else {
    const { error } = await supabase.from("clubs").insert(row);
    if (error) throw error;
  }

  return {
    name: club.name,
    logo: logo_url ? "uploaded" : "missing",
    banner: banner_url ? "uploaded" : "missing",
    action: existing ? "updated" : "created",
  };
}

async function main() {
  const reports: Report[] = [];
  for (const club of CLUBS) {
    console.log(`Importing ${club.name}...`);
    reports.push(await importClub(club));
  }

  console.log("\n=== Import report ===");
  for (const r of reports) {
    console.log(
      `${r.action === "created" ? "+ created " : "~ updated "}${r.name.padEnd(16)} logo: ${r.logo.padEnd(8)} banner: ${r.banner}`
    );
  }
  const missingLogo = reports.filter((r) => r.logo === "missing").map((r) => r.name);
  const missingBanner = reports.filter((r) => r.banner === "missing").map((r) => r.name);
  if (missingLogo.length) console.log(`\nNo logo matched for: ${missingLogo.join(", ")}`);
  if (missingBanner.length) console.log(`No banner matched for: ${missingBanner.join(", ")}`);
  console.log(`\nDone. ${reports.length} clubs processed.`);
}

main().catch((err) => {
  console.error("Import failed:", err);
  process.exit(1);
});
