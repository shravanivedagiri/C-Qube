# Club data import

`import-clubs.ts` imports real club data (currently transcribed into
`club-data.ts` from `club_info.pdf`) and matches/uploads each club's
logo and banner from local asset folders.

## Run it

```bash
cd backend
npx tsx scripts/import-clubs.ts --logos "<path to logo folder>" --banners "<path to banner folder>" [--domain bmsce.ac.in]
```

Idempotent — matched and upserted on `clubs.email`, safe to re-run
(e.g. after fixing a missing asset or updating `club-data.ts`).

## What was imported (2026-09-02)

8 clubs from `club_info.pdf`: Pentagram, Protocol, OSCode, IEEE,
Rotaract, Danceaddix, Mountaineering, Panache.

| Club | Logo | Banner |
|---|---|---|
| Pentagram | ✅ | ❌ missing |
| Protocol | ✅ | ✅ |
| OSCode | ✅ | ✅ |
| IEEE | ✅ | ✅ |
| Rotaract | ✅ | ❌ missing |
| Danceaddix | ✅ (matched via `danzaddix_logo.jpeg` — see below) | ❌ missing |
| Mountaineering | ❌ missing | ❌ missing |
| Panache | ✅ | ❌ missing |

No asset was substituted or reused across clubs — missing ones were
left `null` rather than guessed. Provide `mountaineering_logo.*` and
the five missing `*_banner.*` files, then re-run the script to fill
them in.

## Data-quality notes from the source PDF

- **Filename mismatch**: the logo file is `danzaddix_logo.jpeg` but the
  club is named "Danceaddix" in the PDF text. Matched via an alias
  list in `club-data.ts` (`assetKeys: ["danceaddix", "danzaddix"]`) —
  worth confirming which spelling is actually correct.
- **Copy-paste error**: the "About" text for Danceaddix in the source
  PDF is identical to Rotaract's About text (both describe "service,
  leadership, and personal growth"), which is almost certainly wrong
  for a dance club. Transcribed verbatim rather than silently rewritten
  — needs a real description from the club.
- **Header typo**: the PDF's section header reads "ROTRACT" but the
  body text says "Rotaract BMSCE" — used "Rotaract" as the canonical
  name.

## Fields inferred rather than sourced from the PDF

The PDF gives each club's name, about text, and leadership roster —
nothing else the `clubs` table needs. These were derived, not
fabricated as facts about real people/systems:

- **`email`** (required, unique — used for club login): `<slugified
  name>@bmsce.ac.in`, e.g. `protocol@bmsce.ac.in`. This is a
  placeholder institutional-style address, not a claim that this inbox
  exists — replace with each club's real email before relying on it
  for actual login.
- **`category`**: inferred from each club's stated purpose (e.g.
  Protocol → Technical, Rotaract → Social Service, Panache → Arts &
  Design) — a judgment call, not stated in the PDF.
- **`department`**: left `null` except Protocol, which the PDF
  explicitly calls "the Computer Science and Engineering Department
  Club of BMSCE." No other club states a department affiliation.
- **`coordinator_email`**: intentionally left blank for every club —
  the PDF gives real people's names (President, Team Lead, etc.) but
  no email addresses, and guessing an email format for a named
  individual isn't something to do without their input.
- **No account was created for any of these clubs.** `owner_id` is
  `null` for all 8 — nobody can log in as them yet. Provisioning a
  coordinator account requires their real email, going through the
  normal request → admin-approval flow (`/admin/club-requests`) with
  that real address, not a fabricated one.

## What was NOT imported

The PDF has no events, posts, or gallery media for these clubs, so
none were created — each club's Activity/Gallery tab is genuinely
empty (`This club hasn't posted anything yet.` / `No photos or videos
yet.`) until a real coordinator logs in and posts something. Leadership
roster data (President, Secretary, etc.) was transcribed into
`club-data.ts` but isn't stored anywhere in the database — there's no
`club_officers`-type table yet; let me know if you want one.
