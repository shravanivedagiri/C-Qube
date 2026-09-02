"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { ClubProfileForm } from "@/components/club/club-profile-form";
import { Wordmark } from "@/components/shared/wordmark";
import { Skeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { ClubService } from "@/services/club-service";
import type { Database } from "@/types/database";

type Club = Database["public"]["Tables"]["clubs"]["Row"];

export default function ClubSetupPage() {
  const router = useRouter();
  const { user, loading: authLoading } = useCurrentProfile();
  const [club, setClub] = useState<Club | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;
    ClubService.getMyClub(user.id).then(({ data }) => {
      setClub(data);
      if (data?.profile_complete) router.replace("/dashboard");
      setLoading(false);
    });
  }, [user, router]);

  function onSaved() {
    toast.success("Club profile complete!");
    router.push("/dashboard");
    router.refresh();
  }

  if (authLoading || loading) {
    return (
      <div className="mx-auto max-w-2xl space-y-4 py-10">
        <Skeleton className="h-8 w-64" />
        <Skeleton className="h-48 w-full" />
      </div>
    );
  }

  if (!club) {
    return (
      <div className="mx-auto max-w-md py-16 text-center">
        <p className="text-sm text-muted">
          We couldn&rsquo;t find a club linked to this account. Contact the C-QUBE administrator.
        </p>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl py-6">
      <Wordmark className="text-base" />
      <p className="mt-6 font-mono text-[11px] uppercase tracking-[0.18em] text-muted">
        Step 1 of 1
      </p>
      <h1 className="mt-1.5 font-display text-2xl font-semibold tracking-tight sm:text-3xl">
        Complete your club profile
      </h1>
      <p className="mt-2 text-sm text-muted">
        This is what students see on {club.name}&rsquo;s public page. You can edit it any time from
        Settings.
      </p>

      <div className="mt-8">
        <ClubProfileForm club={club} onSaved={onSaved} submitLabel="Finish setup" />
      </div>
    </div>
  );
}
