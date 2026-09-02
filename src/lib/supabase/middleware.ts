import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";
import { SUPABASE_PUBLISHABLE_KEY, SUPABASE_URL, isSupabaseConfigured } from "./env";

const STUDENT_PREFIX = "/home";
const STUDENT_ROUTES = [
  "/home",
  "/discover",
  "/events",
  "/calendar",
  "/friends",
  "/notifications",
  "/profile",
  "/genie",
];
const CLUB_ROUTES = [
  "/dashboard",
  "/club-profile",
  "/gallery",
  "/club-events",
  "/recruitment",
  "/analytics",
  "/settings",
  "/setup",
];
const ADMIN_ROUTES = ["/admin"];
const AUTH_ROUTES = ["/auth"];

function isPathIn(pathname: string, routes: string[]) {
  return routes.some((r) => pathname === r || pathname.startsWith(r + "/"));
}

/**
 * Refreshes the Supabase auth session on every request and enforces
 * coarse role-based routing:
 *  - signed-out users are bounced to the landing page for protected routes
 *  - students can never reach club-management routes and vice versa
 * Fine-grained authorization still lives in RLS policies server-side.
 */
export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  if (!isSupabaseConfigured) {
    return supabaseResponse;
  }

  const supabase = createServerClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        supabaseResponse = NextResponse.next({ request });
        cookiesToSet.forEach(({ name, value, options }) =>
          supabaseResponse.cookies.set(name, value, options)
        );
      },
    },
  });

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { pathname } = request.nextUrl;

  const protectedRoute = isPathIn(pathname, [...STUDENT_ROUTES, ...CLUB_ROUTES, ...ADMIN_ROUTES]);

  if (!user && protectedRoute) {
    const url = request.nextUrl.clone();
    url.pathname = "/";
    url.searchParams.set("auth", "required");
    return NextResponse.redirect(url);
  }

  if (user) {
    const { data: profile } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .maybeSingle();

    const role = profile?.role;
    const homeFor = (r: string | undefined) =>
      r === "club" ? "/dashboard" : r === "admin" ? "/admin/dashboard" : STUDENT_PREFIX;

    // Each role may only reach its own route group. Selecting a role
    // client-side never grants access — this checks the database role.
    const foreignRoutes =
      role === "student"
        ? [...CLUB_ROUTES, ...ADMIN_ROUTES]
        : role === "club"
          ? [...STUDENT_ROUTES, ...ADMIN_ROUTES]
          : role === "admin"
            ? [...STUDENT_ROUTES, ...CLUB_ROUTES]
            : [];

    if (isPathIn(pathname, foreignRoutes)) {
      const url = request.nextUrl.clone();
      url.pathname = homeFor(role);
      return NextResponse.redirect(url);
    }

    // Already-authenticated users shouldn't linger on auth screens.
    if (isPathIn(pathname, AUTH_ROUTES)) {
      const url = request.nextUrl.clone();
      url.pathname = homeFor(role);
      return NextResponse.redirect(url);
    }
  }

  return supabaseResponse;
}
