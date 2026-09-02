"use client";

import { PlayCircle, Trash2 } from "lucide-react";
import Image from "next/image";
import { EmptyState } from "@/components/ui/empty-state";
import { Image as ImageIconLucide } from "lucide-react";
import type { Database } from "@/types/database";

type GalleryItem = Database["public"]["Tables"]["gallery"]["Row"];

export function GalleryGrid({
  items,
  canManage,
  onDelete,
}: {
  items: GalleryItem[];
  canManage?: boolean;
  onDelete?: (id: string) => void;
}) {
  if (items.length === 0) {
    return (
      <EmptyState icon={ImageIconLucide} title="No photos or videos yet." />
    );
  }

  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4">
      {items.map((item) => (
        <div
          key={item.id}
          className="group relative aspect-square overflow-hidden rounded-xl border border-border bg-border/20"
        >
          <Image src={item.media_url} alt={item.caption ?? ""} fill className="object-cover" />
          {item.media_type === "video" && (
            <div className="absolute inset-0 flex items-center justify-center bg-black/20">
              <PlayCircle className="h-10 w-10 text-white drop-shadow" />
            </div>
          )}
          {canManage && (
            <button
              onClick={() => onDelete?.(item.id)}
              aria-label="Remove"
              className="absolute right-2 top-2 rounded-full bg-black/60 p-1.5 text-white opacity-0 transition group-hover:opacity-100 hover:bg-danger"
            >
              <Trash2 className="h-3.5 w-3.5" />
            </button>
          )}
        </div>
      ))}
    </div>
  );
}
