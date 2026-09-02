"use client";

import { useEffect, useState } from "react";
import { toast } from "sonner";
import { ClubProfileForm } from "@/components/club/club-profile-form";
import { PageHeader } from "@/components/layout/page-header";
import { CardSkeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { ClubService } from "@/services/club-service";
import type { Database } from "@/types/database";

type Club = Database["public"]["Tables"]["clubs"]["Row"];

export default function ClubSettingsPage() {
  const { user } = useCurrentProfile();
  const [club, setClub] = useState<Club | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;
    ClubService.getMyClub(user.id).then(({ data }) => {
      setClub(data);
      setLoading(false);
    });
  }, [user]);

  if (loading) return <CardSkeleton />;
  if (!club) return null;

  return (
    <div className="max-w-2xl">
      <PageHeader title="Settings" description="Update your club's public profile." />
      <ClubProfileForm club={club} onSaved={() => toast.success("Profile updated.")} />
    </div>
  );
}
