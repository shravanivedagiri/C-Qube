import { Calendar, MapPin } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { Badge } from "@/components/ui/badge";
import { formatDate, formatTime } from "@/lib/utils";
import type { EventWithClub } from "@/services/event-service";

export function EventCard({
  event,
  registered,
}: {
  event: EventWithClub;
  registered?: boolean;
}) {
  return (
    <Link
      href={`/events/${event.id}`}
      className="group flex flex-col overflow-hidden rounded-2xl border border-border bg-surface shadow-sm transition hover:shadow-md"
    >
      <div className="relative aspect-[16/9] w-full bg-brand-soft">
        {event.banner_url ? (
          <Image src={event.banner_url} alt="" fill className="object-cover transition group-hover:scale-[1.03]" />
        ) : (
          <div className="flex h-full w-full items-center justify-center">
            <Calendar className="h-8 w-8 text-brand/40" />
          </div>
        )}
        <Badge variant="brand" className="absolute left-3 top-3 bg-surface/90">
          {event.category}
        </Badge>
        {registered && (
          <Badge variant="success" className="absolute right-3 top-3 bg-surface/90">
            Registered ✓
          </Badge>
        )}
      </div>
      <div className="flex flex-1 flex-col p-4">
        <p className="text-xs font-medium text-brand">{event.clubs?.name}</p>
        <h3 className="mt-1 line-clamp-1 text-sm font-semibold">{event.title}</h3>
        <div className="mt-2 space-y-1 text-xs text-muted">
          <p className="flex items-center gap-1.5">
            <Calendar className="h-3.5 w-3.5" />
            {formatDate(event.date)} · {formatTime(event.start_time)}
          </p>
          {event.location && (
            <p className="flex items-center gap-1.5">
              <MapPin className="h-3.5 w-3.5" />
              {event.location}
            </p>
          )}
        </div>
      </div>
    </Link>
  );
}
