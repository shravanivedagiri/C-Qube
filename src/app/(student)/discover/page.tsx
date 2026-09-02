"use client";

import { Compass, Search } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { toast } from "sonner";
import { PageHeader } from "@/components/layout/page-header";
import { ClubCard } from "@/components/shared/club-card";
import { Button } from "@/components/ui/button";
import { EmptyState } from "@/components/ui/empty-state";
import { Input, Select } from "@/components/ui/input";
import { CardSkeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { CLUB_CATEGORIES, DEPARTMENTS } from "@/lib/constants";
import { ClubService } from "@/services/club-service";
import { createClient } from "@/lib/supabase/client";
import type { Database } from "@/types/database";

type Club = Database["public"]["Tables"]["clubs"]["Row"];

export default function DiscoverPage() {
  const { user } = useCurrentProfile();
  const [clubs, setClubs] = useState<Club[]>([]);
  const [following, setFollowing] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("");
  const [department, setDepartment] = useState("");

  useEffect(() => {
    ClubService.listApproved().then(({ data }) => {
      setClubs(data ?? []);
      setLoading(false);
    });
  }, []);

  useEffect(() => {
    if (!user) return;
    createClient()
      .from("club_follows")
      .select("club_id")
      .eq("student_id", user.id)
      .then(({ data }) => setFollowing(new Set((data ?? []).map((f) => f.club_id))));
  }, [user]);

  const filtered = useMemo(() => {
    return clubs.filter((c) => {
      if (search && !c.name.toLowerCase().includes(search.toLowerCase())) return false;
      if (category && c.category !== category) return false;
      if (department && c.department !== department) return false;
      return true;
    });
  }, [clubs, search, category, department]);

  async function toggleFollow(clubId: string) {
    if (!user) {
      toast.info("Log in to follow clubs.");
      return;
    }
    const isFollowing = following.has(clubId);
    setFollowing((prev) => {
      const next = new Set(prev);
      if (isFollowing) next.delete(clubId);
      else next.add(clubId);
      return next;
    });
    const { error } = isFollowing
      ? await ClubService.unfollow(clubId, user.id)
      : await ClubService.follow(clubId, user.id);
    if (error) toast.error(error);
  }

  return (
    <div>
      <PageHeader title="Discover Clubs" description="Find your people on campus." />

      <div className="mb-6 flex flex-col gap-3 sm:flex-row">
        <div className="relative flex-1">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted" />
          <Input
            placeholder="Search clubs..."
            className="pl-9"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <Select value={category} onChange={(e) => setCategory(e.target.value)} className="sm:w-48">
          <option value="">All categories</option>
          {CLUB_CATEGORIES.map((c) => (
            <option key={c}>{c}</option>
          ))}
        </Select>
        <Select value={department} onChange={(e) => setDepartment(e.target.value)} className="sm:w-48">
          <option value="">All departments</option>
          {DEPARTMENTS.map((d) => (
            <option key={d}>{d}</option>
          ))}
        </Select>
      </div>

      {loading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <CardSkeleton key={i} />
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <EmptyState icon={Compass} title="No clubs match those filters" description="Try a different search or clear filters." />
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {filtered.map((club) => (
            <ClubCard
              key={club.id}
              club={club}
              action={
                <Button
                  size="sm"
                  variant={following.has(club.id) ? "secondary" : "primary"}
                  onClick={() => toggleFollow(club.id)}
                >
                  {following.has(club.id) ? "Following" : "Follow"}
                </Button>
              }
            />
          ))}
        </div>
      )}
    </div>
  );
}
