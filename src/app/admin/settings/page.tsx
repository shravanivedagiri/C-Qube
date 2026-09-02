"use client";

import { PageHeader } from "@/components/layout/page-header";
import { Avatar } from "@/components/ui/avatar";
import { Card, CardContent } from "@/components/ui/card";
import { useCurrentProfile } from "@/hooks/use-current-profile";

export default function AdminSettingsPage() {
  const { profile } = useCurrentProfile();

  return (
    <div className="max-w-xl">
      <PageHeader title="Settings" description="Your admin account." />
      <Card>
        <CardContent className="flex items-center gap-4 p-5">
          <Avatar src={profile?.avatar_url} name={profile?.name ?? "Admin"} size={56} />
          <div>
            <p className="font-medium">{profile?.name}</p>
            <p className="text-sm text-muted">{profile?.email}</p>
          </div>
        </CardContent>
      </Card>
      <p className="mt-4 text-xs text-muted">
        Admin accounts aren&rsquo;t self-service — contact another administrator or update your role
        directly in Supabase if you need changes made here.
      </p>
    </div>
  );
}
