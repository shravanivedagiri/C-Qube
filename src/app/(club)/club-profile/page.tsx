"use client";

import { Calendar, Pencil } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";
import { Avatar } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { LinkButton } from "@/components/ui/button";
import { CardSkeleton } from "@/components/ui/skeleton";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { GalleryGrid } from "@/components/shared/gallery-grid";
import { PostCard } from "@/components/shared/post-card";
import { EmptyState } from "@/components/ui/empty-state";
import { Image as ImageIconLucide } from "lucide-react";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { ClubService } from "@/services/club-service";
import { GalleryService } from "@/services/gallery-service";
import { PostService, type PostWithClub } from "@/services/post-service";
import type { Database } from "@/types/database";

type Club = Database["public"]["Tables"]["clubs"]["Row"];
type GalleryItem = Database["public"]["Tables"]["gallery"]["Row"];

export default function ClubProfilePage() {
  const { user } = useCurrentProfile();
  const [club, setClub] = useState<Club | null>(null);
  const [posts, setPosts] = useState<PostWithClub[]>([]);
  const [gallery, setGallery] = useState<GalleryItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;
    ClubService.getMyClub(user.id).then(async ({ data: myClub }) => {
      setClub(myClub);
      if (myClub) {
        const [{ data: p }, { data: g }] = await Promise.all([
          PostService.listByClub(myClub.id),
          GalleryService.listByClub(myClub.id),
        ]);
        setPosts(p ?? []);
        setGallery(g ?? []);
      }
      setLoading(false);
    });
  }, [user]);

  if (loading) return <CardSkeleton />;
  if (!club) return null;

  return (
    <div>
      <div className="relative h-40 w-full overflow-hidden rounded-2xl border border-border bg-brand-soft sm:h-56">
        {club.banner_url && (
          <Image src={club.banner_url} alt="" fill className="object-cover" />
        )}
        {/* Scrim so the name below stays legible over any banner image —
            rendered even without a banner, so it also reads fine on the
            plain bg-brand-soft fallback. */}
        <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />
      </div>

      <div className="relative -mt-10 flex flex-wrap items-end justify-between gap-4 px-2 sm:-mt-12">
        <div className="flex items-end gap-4">
          <Avatar
            src={club.logo_url}
            name={club.name}
            size={88}
            className="border-4 border-background shadow-md"
          />
          <div className="pb-1">
            <h1 className="font-display text-xl font-semibold text-white [text-shadow:0_1px_4px_rgb(0_0_0_/_0.5)] sm:text-2xl">
              {club.name}
            </h1>
            <div className="mt-1 flex items-center gap-2">
              {club.category && <Badge variant="brand">{club.category}</Badge>}
              {club.department && <Badge>{club.department}</Badge>}
            </div>
          </div>
        </div>
        <div className="flex gap-2 pb-1">
          <LinkButton href="/club-events" variant="secondary" icon={<Calendar className="h-4 w-4" />}>
            Calendar
          </LinkButton>
          <LinkButton href="/settings" icon={<Pencil className="h-4 w-4" />}>
            Edit profile
          </LinkButton>
        </div>
      </div>

      {club.about && (
        <p className="mt-6 max-w-2xl text-sm leading-relaxed text-foreground/90">{club.about}</p>
      )}

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
                <PostCard key={p.id} post={p} />
              ))}
            </div>
          )}
        </TabsContent>

        <TabsContent value="gallery" className="mt-5">
          <GalleryGrid items={gallery} />
          <Link href="/gallery" className="mt-4 inline-block text-sm font-medium text-brand hover:underline">
            Manage gallery →
          </Link>
        </TabsContent>
      </Tabs>
    </div>
  );
}
