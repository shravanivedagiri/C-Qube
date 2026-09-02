import { Users } from "lucide-react";
import Link from "next/link";
import { Avatar } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import type { Database } from "@/types/database";

type Club = Database["public"]["Tables"]["clubs"]["Row"];

export function ClubCard({
  club,
  action,
}: {
  club: Pick<Club, "id" | "name" | "logo_url" | "category" | "about" | "member_count">;
  action?: React.ReactNode;
}) {
  return (
    <div className="flex flex-col rounded-2xl border border-border bg-surface p-5 shadow-sm transition hover:shadow-md">
      <div className="flex items-start gap-3">
        <Avatar src={club.logo_url} name={club.name} size={44} />
        <div className="min-w-0 flex-1">
          <Link href={`/clubs/${club.id}`} className="line-clamp-1 text-sm font-semibold hover:underline">
            {club.name}
          </Link>
          {club.category && (
            <Badge variant="brand" className="mt-1">
              {club.category}
            </Badge>
          )}
        </div>
      </div>
      {club.about && (
        <p className="mt-3 line-clamp-2 flex-1 text-sm text-muted">{club.about}</p>
      )}
      <div className="mt-4 flex items-center justify-between">
        <span className="flex items-center gap-1.5 text-xs text-muted">
          <Users className="h-3.5 w-3.5" />
          {club.member_count} members
        </span>
        {action}
      </div>
    </div>
  );
}
