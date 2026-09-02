"use client";

import { useState } from "react";
import { toast } from "sonner";
import { ImageUpload } from "@/components/shared/image-upload";
import { Button } from "@/components/ui/button";
import { Input, Label, Select, Textarea } from "@/components/ui/input";
import { CLUB_CATEGORIES, DEPARTMENTS } from "@/lib/constants";
import { ClubService } from "@/services/club-service";
import type { Database } from "@/types/database";

type Club = Database["public"]["Tables"]["clubs"]["Row"];

export function ClubProfileForm({
  club,
  onSaved,
  submitLabel = "Save changes",
}: {
  club: Club;
  onSaved: (club: Club) => void;
  submitLabel?: string;
}) {
  const [form, setForm] = useState({
    logo_url: club.logo_url,
    banner_url: club.banner_url,
    about: club.about ?? "",
    category: club.category ?? CLUB_CATEGORIES[0],
    department: club.department ?? DEPARTMENTS[0],
    contact_email: club.contact_info?.email ?? "",
    contact_phone: club.contact_info?.phone ?? "",
    instagram: club.social_links?.instagram ?? "",
    website: club.social_links?.website ?? "",
  });
  const [saving, setSaving] = useState(false);

  function set<K extends keyof typeof form>(key: K, value: (typeof form)[K]) {
    setForm((f) => ({ ...f, [key]: value }));
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!form.about || !form.category) {
      toast.error("Add an about section and pick a category.");
      return;
    }
    setSaving(true);
    const { data, error } = await ClubService.update(club.id, {
      logo_url: form.logo_url,
      banner_url: form.banner_url,
      about: form.about,
      category: form.category,
      department: form.department,
      contact_info: { email: form.contact_email, phone: form.contact_phone },
      social_links: { instagram: form.instagram, website: form.website },
      profile_complete: true,
    });
    setSaving(false);
    if (error || !data) {
      toast.error(error ?? "Couldn't save changes.");
      return;
    }
    toast.success("Saved.");
    onSaved(data);
  }

  return (
    <form onSubmit={onSubmit} className="space-y-6 rounded-2xl border border-border bg-surface p-6 shadow-sm">
      <div>
        <Label>Banner</Label>
        <ImageUpload
          value={form.banner_url}
          onChange={(url) => set("banner_url", url)}
          folder="clubs"
          ownerId={club.id}
          label="Upload a banner image"
          aspect="aspect-[3/1]"
        />
      </div>

      <div className="flex items-center gap-4">
        <ImageUpload
          value={form.logo_url}
          onChange={(url) => set("logo_url", url)}
          folder="clubs"
          ownerId={club.id}
          label="Logo"
          aspect="h-24 w-24"
          shape="circle"
        />
        <p className="text-xs text-muted">Square logo, shown across C-QUBE.</p>
      </div>

      <div>
        <Label htmlFor="about">About the club</Label>
        <Textarea id="about" rows={4} value={form.about} onChange={(e) => set("about", e.target.value)} />
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div>
          <Label htmlFor="category">Category</Label>
          <Select id="category" value={form.category} onChange={(e) => set("category", e.target.value)}>
            {CLUB_CATEGORIES.map((c) => (
              <option key={c}>{c}</option>
            ))}
          </Select>
        </div>
        <div>
          <Label htmlFor="department">Department</Label>
          <Select id="department" value={form.department} onChange={(e) => set("department", e.target.value)}>
            {DEPARTMENTS.map((d) => (
              <option key={d}>{d}</option>
            ))}
          </Select>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div>
          <Label htmlFor="contact_email">Contact email</Label>
          <Input id="contact_email" type="email" value={form.contact_email} onChange={(e) => set("contact_email", e.target.value)} />
        </div>
        <div>
          <Label htmlFor="contact_phone">Contact phone</Label>
          <Input id="contact_phone" value={form.contact_phone} onChange={(e) => set("contact_phone", e.target.value)} />
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div>
          <Label htmlFor="instagram">Instagram</Label>
          <Input id="instagram" placeholder="@yourclub" value={form.instagram} onChange={(e) => set("instagram", e.target.value)} />
        </div>
        <div>
          <Label htmlFor="website">Website</Label>
          <Input id="website" placeholder="https://" value={form.website} onChange={(e) => set("website", e.target.value)} />
        </div>
      </div>

      <Button type="submit" fullWidth size="lg" loading={saving}>
        {submitLabel}
      </Button>
    </form>
  );
}
