"use client";

import { AtSign, Globe, Mail, Users } from "lucide-react";
import Image from "next/image";
import { use, useEffect, useRef, useState } from "react";
import { toast } from "sonner";
import { Avatar } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { EmptyState } from "@/components/ui/empty-state";
import { CardSkeleton } from "@/components/ui/skeleton";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { GalleryGrid } from "@/components/shared/gallery-grid";
import { PostCard } from "@/components/shared/post-card";
import { Image as ImageIconLucide } from "lucide-react";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { ClubService, MembershipService, type MembershipStatus } from "@/services/club-service";
import { GalleryService } from "@/services/gallery-service";
import { PostService, type PostWithClub } from "@/services/post-service";
import type { Database } from "@/types/database";

type Club = Database["public"]["Tables"]["clubs"]["Row"];
type GalleryItem = Database["public"]["Tables"]["gallery"]["Row"];

export default function ClubPublicProfilePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const { user, profile } = useCurrentProfile();
  const [club, setClub] = useState<Club | null>(null);
  const [posts, setPosts] = useState<PostWithClub[]>([]);
  const [gallery, setGallery] = useState<GalleryItem[]>([]);
  const [following, setFollowing] = useState(false);
  const [membership, setMembership] = useState<MembershipStatus>("none");
  const [joining, setJoining] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    ClubService.getById(id).then(async ({ data: c }) => {
      setClub(c);
      if (c) {
        const [{ data: p }, { data: g }, isFollowing, membershipStatus] = await Promise.all([
          PostService.listByClub(c.id, user?.id),
          GalleryService.listByClub(c.id),
          user ? ClubService.isFollowing(c.id, user.id) : Promise.resolve(false),
          user ? MembershipService.getStatus(c.id, user.id) : Promise.resolve("none" as MembershipStatus),
        ]);
        setPosts(p ?? []);
        setGallery(g ?? []);
        setFollowing(isFollowing);
        setMembership(membershipStatus);
      }
      setLoading(false);
    });
  }, [id, user]);

  // Real-time profile view count: one row per (club, student) visit —
  // see ClubService.recordView and supabase/migrations/0009_club_profile_views.sql.
  // Only counts logged-in students, and once per page mount (the ref
  // survives React StrictMode's dev-only double effect invocation).
  const recordedViewFor = useRef<string | null>(null);
  useEffect(() => {
    if (!user || profile?.role !== "student") return;
    const key = `${id}:${user.id}`;
    if (recordedViewFor.current === key) return;
    recordedViewFor.current = key;
    ClubService.recordView(id, user.id);
  }, [id, user, profile]);

  async function toggleFollow() {
    if (!user || !club) {
      toast.info("Log in to follow clubs.");
      return;
    }
    setFollowing((f) => !f);
    const { error } = following
      ? await ClubService.unfollow(club.id, user.id)
      : await ClubService.follow(club.id, user.id);
    if (error) toast.error(error);
  }

  async function joinClub() {
    if (!user || !club) {
      toast.info("Log in to join clubs.");
      return;
    }
    setJoining(true);
    const { error } = await MembershipService.requestToJoin(club.id, user.id);
    setJoining(false);
    if (error) {
      toast.error(error);
      return;
    }
    setMembership("pending");
    toast.success("Request sent — the club coordinator will review it.");
  }

  if (loading) return <CardSkeleton />;
  if (!club) return <p className="text-sm text-muted">Club not found.</p>;

  return (
    <div>
      <div className="relative h-40 w-full overflow-hidden rounded-2xl border border-border bg-brand-soft sm:h-56">
        {club.banner_url && <Image src={club.banner_url} alt="" fill className="object-cover" />}
        {/* Scrim so the name below stays legible over any banner image —
            rendered even without a banner, so it also reads fine on the
            plain bg-brand-soft fallback. */}
        <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />
      </div>

      <div className="relative -mt-10 flex flex-wrap items-end justify-between gap-4 px-2 sm:-mt-12">
        <div className="flex items-end gap-4">
          <Avatar src={club.logo_url} name={club.name} size={88} className="border-4 border-background shadow-md" />
          <div className="pb-1">
            <h1 className="font-display text-xl font-semibold text-white [text-shadow:0_1px_4px_rgb(0_0_0_/_0.5)] sm:text-2xl">
              {club.name}
            </h1>
            <div className="mt-1 flex items-center gap-2">
              {club.category && <Badge variant="brand">{club.category}</Badge>}
              <span className="flex items-center gap-1 text-xs text-white/90 [text-shadow:0_1px_3px_rgb(0_0_0_/_0.5)]">
                <Users className="h-3.5 w-3.5" />
                {club.member_count} members
              </span>
            </div>
          </div>
        </div>
        <div className="flex gap-2 pb-1">
          <Button onClick={toggleFollow} variant={following ? "secondary" : "primary"}>
            {following ? "Following" : "Follow"}
          </Button>
          {membership === "member" ? (
            <Button variant="secondary" disabled>
              Member
            </Button>
          ) : membership === "pending" ? (
            <Button variant="secondary" disabled>
              Request Pending
            </Button>
          ) : (
            <Button variant="secondary" loading={joining} onClick={joinClub}>
              {membership === "rejected" ? "Request Again" : "Join Club"}
            </Button>
          )}
        </div>
      </div>

      {club.about && <p className="mt-6 max-w-2xl text-sm leading-relaxed text-foreground/90">{club.about}</p>}

      <div className="mt-4 flex flex-wrap gap-4 text-sm text-muted">
        {club.contact_info?.email && (
          <span className="flex items-center gap-1.5">
            <Mail className="h-3.5 w-3.5" />
            {club.contact_info.email}
          </span>
        )}
        {club.social_links?.instagram && (
          <span className="flex items-center gap-1.5">
            <AtSign className="h-3.5 w-3.5" />
            {club.social_links.instagram}
          </span>
        )}
        {club.social_links?.website && (
          <span className="flex items-center gap-1.5">
            <Globe className="h-3.5 w-3.5" />
            {club.social_links.website}
          </span>
        )}
      </div>

      <Tabs defaultValue="activity" className="mt-8">
        <TabsList>
          <TabsTrigger value="activity">Activity</TabsTrigger>
          <TabsTrigger value="gallery">Gallery</TabsTrigger>
        </TabsList>
        <TabsContent value="activity" className="mt-5">
          {posts.length === 0 ? (
            <EmptyState icon={ImageIconLucide} title="This club hasn't posted anything yet." />
          ) : (
            <div className="space-y-4">
              {posts.map((p) => (
                <PostCard key={p.id} post={p} currentStudentId={user?.id} />
              ))}
            </div>
          )}
        </TabsContent>
        <TabsContent value="gallery" className="mt-5">
          <GalleryGrid items={gallery} />
        </TabsContent>
      </Tabs>
    </div>
  );
}
