"use client";

import { Loader2, Upload } from "lucide-react";
import { useCallback, useEffect, useRef, useState } from "react";
import { toast } from "sonner";
import { PageHeader } from "@/components/layout/page-header";
import { GalleryGrid } from "@/components/shared/gallery-grid";
import { Button } from "@/components/ui/button";
import { useConfirm } from "@/components/ui/confirm-dialog";
import { CardSkeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { uploadMedia } from "@/lib/supabase/storage";
import { ClubService } from "@/services/club-service";
import { GalleryService } from "@/services/gallery-service";
import type { Database } from "@/types/database";

type GalleryItem = Database["public"]["Tables"]["gallery"]["Row"];

export default function ClubGalleryPage() {
  const { user } = useCurrentProfile();
  const [clubId, setClubId] = useState<string | null>(null);
  const [items, setItems] = useState<GalleryItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);
  const { confirm, confirmDialog } = useConfirm();

  const load = useCallback(async () => {
    if (!user) return;
    const { data: club } = await ClubService.getMyClub(user.id);
    if (!club) {
      setLoading(false);
      return;
    }
    setClubId(club.id);
    const { data } = await GalleryService.listByClub(club.id);
    setItems(data ?? []);
    setLoading(false);
  }, [user]);

  useEffect(() => {
    load();
  }, [load]);

  async function handleFiles(files: FileList | null) {
    if (!files || !clubId) return;
    setUploading(true);
    const uploaded: { club_id: string; media_url: string; media_type: "image" | "video" }[] = [];
    for (const file of Array.from(files)) {
      const type = file.type.startsWith("video/") ? "video" : "image";
      const { url, error } = await uploadMedia("gallery", clubId, file);
      if (error) {
        toast.error(`${file.name}: ${error}`);
        continue;
      }
      if (url) uploaded.push({ club_id: clubId, media_url: url, media_type: type });
    }
    if (uploaded.length) {
      await GalleryService.add(uploaded);
      toast.success(`Uploaded ${uploaded.length} file${uploaded.length > 1 ? "s" : ""}.`);
      load();
    }
    setUploading(false);
  }

  async function remove(id: string) {
    const ok = await confirm({
      title: "Remove this item?",
      description: "It will no longer appear in your club's gallery.",
      confirmLabel: "Remove",
      danger: true,
    });
    if (!ok) return;
    await GalleryService.remove(id);
    setItems((prev) => prev.filter((i) => i.id !== id));
  }

  if (loading) return <CardSkeleton />;

  return (
    <div>
      {confirmDialog}
      <PageHeader
        title="Gallery"
        description="Photos and videos from your club's activities."
        actions={
          <>
            <input
              ref={inputRef}
              type="file"
              accept="image/*,video/*"
              multiple
              className="hidden"
              onChange={(e) => handleFiles(e.target.files)}
            />
            <Button
              icon={uploading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Upload className="h-4 w-4" />}
              onClick={() => inputRef.current?.click()}
              disabled={uploading}
            >
              {uploading ? "Uploading…" : "Upload"}
            </Button>
          </>
        }
      />
      <GalleryGrid items={items} canManage onDelete={remove} />
    </div>
  );
}
