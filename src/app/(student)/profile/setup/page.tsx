"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { ChipSelect } from "@/components/shared/chip-select";
import { ImageUpload } from "@/components/shared/image-upload";
import { Wordmark } from "@/components/shared/wordmark";
import { Button } from "@/components/ui/button";
import { Input, Label, Textarea } from "@/components/ui/input";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { INTERESTS } from "@/lib/constants";
import { createClient } from "@/lib/supabase/client";
import { PointsService } from "@/services/points-service";

export default function StudentProfileSetupPage() {
  const router = useRouter();
  const { user, profile } = useCurrentProfile();
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null);
  const [bio, setBio] = useState("");
  const [interests, setInterests] = useState<string[]>([]);
  const [skills, setSkills] = useState("");
  const [goals, setGoals] = useState("");
  const [saving, setSaving] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!user) return;
    setSaving(true);
    const supabase = createClient();
    const [{ error: e1 }, { error: e2 }] = await Promise.all([
      supabase.from("profiles").update({ avatar_url: avatarUrl, bio }).eq("id", user.id),
      PointsService.updateStudentProfile(user.id, {
        interests,
        skills: skills.split(",").map((s) => s.trim()).filter(Boolean),
        goals,
      }),
    ]);
    setSaving(false);
    if (e1 || e2) {
      toast.error(e1?.message ?? e2 ?? "Couldn't save your profile.");
      return;
    }
    toast.success("You're all set!");
    router.push("/home");
    router.refresh();
  }

  return (
    <div className="mx-auto max-w-2xl py-6">
      <Wordmark className="text-base" />
      <p className="mt-6 font-mono text-[11px] uppercase tracking-[0.18em] text-muted">
        Almost there
      </p>
      <h1 className="mt-1.5 font-display text-2xl font-semibold tracking-tight sm:text-3xl">
        Tell us about you, {profile?.name?.split(" ")[0] ?? "there"}
      </h1>
      <p className="mt-2 text-sm text-muted">
        This helps us recommend the right clubs and events. You can change it anytime.
      </p>

      <form onSubmit={onSubmit} className="mt-8 space-y-6 rounded-2xl border border-border bg-surface p-6 shadow-sm">
        <div className="flex items-center gap-4">
          <ImageUpload
            value={avatarUrl}
            onChange={setAvatarUrl}
            folder="avatars"
            ownerId={user?.id ?? ""}
            label="Photo"
            aspect="h-24 w-24"
            shape="circle"
          />
          <p className="text-xs text-muted">A friendly photo helps classmates recognize you.</p>
        </div>

        <div>
          <Label htmlFor="bio">Bio</Label>
          <Textarea id="bio" rows={3} placeholder="A short intro about you" value={bio} onChange={(e) => setBio(e.target.value)} />
        </div>

        <div>
          <Label>Interests</Label>
          <ChipSelect options={INTERESTS} value={interests} onChange={setInterests} />
        </div>

        <div>
          <Label htmlFor="skills">Skills (comma separated)</Label>
          <Input id="skills" placeholder="Figma, Python, Public speaking" value={skills} onChange={(e) => setSkills(e.target.value)} />
        </div>

        <div>
          <Label htmlFor="goals">Goals</Label>
          <Textarea id="goals" rows={2} placeholder="What do you want to get out of campus life?" value={goals} onChange={(e) => setGoals(e.target.value)} />
        </div>

        <Button type="submit" fullWidth size="lg" loading={saving}>
          Finish setup
        </Button>
      </form>
    </div>
  );
}
