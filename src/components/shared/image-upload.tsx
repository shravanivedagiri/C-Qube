"use client";

import { ImagePlus, Loader2, X } from "lucide-react";
import Image from "next/image";
import { useRef, useState } from "react";
import { uploadMedia } from "@/lib/supabase/storage";
import { cn } from "@/lib/utils";

export function ImageUpload({
  value,
  onChange,
  folder,
  ownerId,
  label = "Upload image",
  aspect = "aspect-video",
  shape = "square",
}: {
  value: string | null;
  onChange: (url: string | null) => void;
  folder: "avatars" | "clubs" | "posts" | "events" | "gallery" | "recruitment";
  ownerId: string;
  label?: string;
  aspect?: string;
  shape?: "square" | "circle";
}) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleFile(file: File | undefined) {
    if (!file) return;
    if (!file.type.startsWith("image/")) {
      setError("Please choose an image file.");
      return;
    }
    setError(null);
    setUploading(true);
    const { url, error } = await uploadMedia(folder, ownerId, file);
    setUploading(false);
    if (error) {
      setError(error);
      return;
    }
    onChange(url);
  }

  return (
    <div>
      <button
        type="button"
        onClick={() => inputRef.current?.click()}
        className={cn(
          "relative flex w-full items-center justify-center overflow-hidden border border-dashed border-border bg-border/20 text-muted transition hover:border-brand/50 hover:text-brand",
          aspect,
          shape === "circle" ? "rounded-full" : "rounded-2xl"
        )}
      >
        {value ? (
          <Image src={value} alt={label} fill className="object-cover" />
        ) : uploading ? (
          <Loader2 className="h-6 w-6 animate-spin" />
        ) : (
          <span className="flex flex-col items-center gap-1.5 p-4 text-center text-xs font-medium">
            <ImagePlus className="h-5 w-5" />
            {label}
          </span>
        )}
        {value && !uploading && (
          <span
            role="button"
            aria-label="Remove image"
            onClick={(e) => {
              e.stopPropagation();
              onChange(null);
            }}
            className="absolute right-2 top-2 rounded-full bg-black/60 p-1 text-white transition hover:bg-black/80"
          >
            <X className="h-3.5 w-3.5" />
          </span>
        )}
      </button>
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        className="hidden"
        onChange={(e) => handleFile(e.target.files?.[0])}
      />
      {error && <p className="mt-1.5 text-xs text-danger">{error}</p>}
    </div>
  );
}
