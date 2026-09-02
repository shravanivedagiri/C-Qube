"use client";

import {
  ChevronLeft,
  Megaphone,
  Newspaper,
  PartyPopper,
  Plus,
  UserPlus,
} from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";
import { ImageUpload } from "@/components/shared/image-upload";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTrigger } from "@/components/ui/dialog";
import { Input, Label, Select, Textarea } from "@/components/ui/input";
import { EVENT_CATEGORIES } from "@/lib/constants";
import { EventService } from "@/services/event-service";
import { PostService } from "@/services/post-service";
import { RecruitmentService } from "@/services/recruitment-service";

type Mode = "menu" | "announcement" | "post" | "event" | "recruitment";

const OPTIONS: { mode: Mode; icon: typeof Megaphone; title: string; desc: string }[] = [
  { mode: "announcement", icon: Megaphone, title: "Create Announcement", desc: "Share news with a title, description, and image." },
  { mode: "post", icon: Newspaper, title: "Create Post", desc: "A general update or achievement for your feed." },
  { mode: "event", icon: PartyPopper, title: "Host Event", desc: "Full event details — added to the campus calendar." },
  { mode: "recruitment", icon: UserPlus, title: "Open Recruitment", desc: "Start a recruitment drive with applications." },
];

export function CreateActivityDialog({
  clubId,
  onCreated,
}: {
  clubId: string;
  onCreated: () => void;
}) {
  const [open, setOpen] = useState(false);
  const [mode, setMode] = useState<Mode>("menu");

  function close(created: boolean) {
    setOpen(false);
    setMode("menu");
    if (created) onCreated();
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(o) => {
        setOpen(o);
        if (!o) setMode("menu");
      }}
    >
      <DialogTrigger asChild>
        <Button icon={<Plus className="h-4 w-4" />}>Create Activity</Button>
      </DialogTrigger>
      <DialogContent
        title={mode === "menu" ? "Create Activity" : OPTIONS.find((o) => o.mode === mode)!.title}
        className={mode === "event" || mode === "recruitment" ? "max-w-xl" : undefined}
      >
        {mode !== "menu" && (
          <button
            onClick={() => setMode("menu")}
            className="mb-4 -mt-2 inline-flex items-center gap-1 text-xs font-medium text-muted hover:text-foreground"
          >
            <ChevronLeft className="h-3.5 w-3.5" /> Back
          </button>
        )}

        {mode === "menu" && (
          <div className="grid gap-3 sm:grid-cols-2">
            {OPTIONS.map((o) => (
              <button
                key={o.mode}
                onClick={() => setMode(o.mode)}
                className="flex flex-col items-start gap-2 rounded-xl border border-border p-4 text-left transition hover:border-brand/50 hover:bg-brand-soft/40"
              >
                <o.icon className="h-5 w-5 text-brand" />
                <span className="text-sm font-semibold">{o.title}</span>
                <span className="text-xs text-muted">{o.desc}</span>
              </button>
            ))}
          </div>
        )}

        {mode === "announcement" && (
          <AnnouncementForm clubId={clubId} onDone={close} type="announcement" />
        )}
        {mode === "post" && <AnnouncementForm clubId={clubId} onDone={close} type="general" />}
        {mode === "event" && <EventForm clubId={clubId} onDone={close} />}
        {mode === "recruitment" && <RecruitmentForm clubId={clubId} onDone={close} />}
      </DialogContent>
    </Dialog>
  );
}

function AnnouncementForm({
  clubId,
  onDone,
  type,
}: {
  clubId: string;
  onDone: (created: boolean) => void;
  type: "announcement" | "general";
}) {
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [imageUrl, setImageUrl] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  async function publish() {
    if (type === "announcement" && !title) {
      toast.error("Give your announcement a title.");
      return;
    }
    if (!content) {
      toast.error("Add a description.");
      return;
    }
    setSaving(true);
    const { error } = await PostService.create({
      club_id: clubId,
      type,
      title: title || null,
      content,
      image_url: imageUrl,
    });
    setSaving(false);
    if (error) {
      toast.error(error);
      return;
    }
    toast.success(type === "announcement" ? "Announcement published." : "Post published.");
    onDone(true);
  }

  return (
    <div className="space-y-4">
      {type === "announcement" && (
        <div>
          <Label htmlFor="title">Title</Label>
          <Input id="title" value={title} onChange={(e) => setTitle(e.target.value)} />
        </div>
      )}
      <div>
        <Label htmlFor="content">Description</Label>
        <Textarea id="content" rows={4} value={content} onChange={(e) => setContent(e.target.value)} />
      </div>
      <div>
        <Label>Image (optional)</Label>
        <ImageUpload value={imageUrl} onChange={setImageUrl} folder="posts" ownerId={clubId} />
      </div>
      <div className="flex justify-end gap-2 pt-1">
        <Button variant="secondary" onClick={() => onDone(false)}>
          Cancel
        </Button>
        <Button loading={saving} onClick={publish}>
          Publish
        </Button>
      </div>
    </div>
  );
}

function EventForm({ clubId, onDone }: { clubId: string; onDone: (created: boolean) => void }) {
  const [form, setForm] = useState({
    title: "",
    description: "",
    banner_url: null as string | null,
    date: "",
    start_time: "",
    end_time: "",
    location: "",
    is_online: false,
    capacity: "",
    registration_deadline: "",
    category: EVENT_CATEGORIES[0] as string,
  });
  const [saving, setSaving] = useState(false);

  function set<K extends keyof typeof form>(key: K, value: (typeof form)[K]) {
    setForm((f) => ({ ...f, [key]: value }));
  }

  async function submit() {
    if (!form.title || !form.date || !form.start_time) {
      toast.error("Add a title, date, and start time.");
      return;
    }
    setSaving(true);
    const { data: event, error } = await EventService.create({
      club_id: clubId,
      title: form.title,
      description: form.description || null,
      banner_url: form.banner_url,
      date: form.date,
      start_time: form.start_time,
      end_time: form.end_time || null,
      location: form.location || null,
      is_online: form.is_online,
      capacity: form.capacity ? Number(form.capacity) : null,
      registration_deadline: form.registration_deadline
        ? new Date(form.registration_deadline).toISOString()
        : null,
      category: form.category as "Technical" | "Cultural" | "Sports" | "Workshop" | "Competition" | "Seminar" | "Social" | "Other",
      status: "published",
    });
    if (error || !event) {
      setSaving(false);
      toast.error(error ?? "Couldn't create the event.");
      return;
    }
    await PostService.create({
      club_id: clubId,
      type: "event",
      title: form.title,
      content: form.description || null,
      image_url: form.banner_url,
      event_id: event.id,
    });
    setSaving(false);
    toast.success("Event published to the campus calendar.");
    onDone(true);
  }

  return (
    <div className="space-y-4">
      <div>
        <Label htmlFor="ev_title">Event name</Label>
        <Input id="ev_title" value={form.title} onChange={(e) => set("title", e.target.value)} />
      </div>
      <div>
        <Label htmlFor="ev_desc">Description</Label>
        <Textarea id="ev_desc" rows={3} value={form.description} onChange={(e) => set("description", e.target.value)} />
      </div>
      <div>
        <Label>Event banner</Label>
        <ImageUpload value={form.banner_url} onChange={(v) => set("banner_url", v)} folder="events" ownerId={clubId} aspect="aspect-[3/1]" />
      </div>
      <div className="grid grid-cols-3 gap-3">
        <div>
          <Label htmlFor="ev_date">Date</Label>
          <Input id="ev_date" type="date" value={form.date} onChange={(e) => set("date", e.target.value)} />
        </div>
        <div>
          <Label htmlFor="ev_start">Start time</Label>
          <Input id="ev_start" type="time" value={form.start_time} onChange={(e) => set("start_time", e.target.value)} />
        </div>
        <div>
          <Label htmlFor="ev_end">End time</Label>
          <Input id="ev_end" type="time" value={form.end_time} onChange={(e) => set("end_time", e.target.value)} />
        </div>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <div>
          <Label htmlFor="ev_location">Location</Label>
          <Input id="ev_location" placeholder="Main Auditorium" value={form.location} onChange={(e) => set("location", e.target.value)} />
        </div>
        <div>
          <Label htmlFor="ev_category">Category</Label>
          <Select id="ev_category" value={form.category} onChange={(e) => set("category", e.target.value)}>
            {EVENT_CATEGORIES.map((c) => (
              <option key={c}>{c}</option>
            ))}
          </Select>
        </div>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <div>
          <Label htmlFor="ev_capacity">Max participants</Label>
          <Input id="ev_capacity" type="number" min={1} placeholder="No limit" value={form.capacity} onChange={(e) => set("capacity", e.target.value)} />
        </div>
        <div>
          <Label htmlFor="ev_deadline">Registration deadline</Label>
          <Input id="ev_deadline" type="datetime-local" value={form.registration_deadline} onChange={(e) => set("registration_deadline", e.target.value)} />
        </div>
      </div>
      <label className="flex items-center gap-2 text-sm">
        <input type="checkbox" checked={form.is_online} onChange={(e) => set("is_online", e.target.checked)} className="h-4 w-4 rounded border-border" />
        This event is online
      </label>
      <div className="flex justify-end gap-2 pt-1">
        <Button variant="secondary" onClick={() => onDone(false)}>
          Cancel
        </Button>
        <Button loading={saving} onClick={submit}>
          Publish event
        </Button>
      </div>
    </div>
  );
}

function RecruitmentForm({ clubId, onDone }: { clubId: string; onDone: (created: boolean) => void }) {
  const [form, setForm] = useState({
    title: "",
    description: "",
    positions: "",
    eligibility: "",
    skills: "",
    deadline: "",
    banner_url: null as string | null,
  });
  const [saving, setSaving] = useState(false);

  function set<K extends keyof typeof form>(key: K, value: (typeof form)[K]) {
    setForm((f) => ({ ...f, [key]: value }));
  }

  async function submit() {
    if (!form.title || !form.deadline) {
      toast.error("Add a title and application deadline.");
      return;
    }
    setSaving(true);
    const { data: drive, error } = await RecruitmentService.create({
      club_id: clubId,
      title: form.title,
      description: form.description || null,
      positions: form.positions.split(",").map((p) => p.trim()).filter(Boolean),
      eligibility: form.eligibility || null,
      skills_required: form.skills.split(",").map((s) => s.trim()).filter(Boolean),
      deadline: new Date(form.deadline).toISOString(),
      banner_url: form.banner_url,
      questions: [
        { id: "q1", question: "Why do you want to join?", required: true },
        { id: "q2", question: "Relevant experience", required: false },
      ],
    });
    if (error || !drive) {
      setSaving(false);
      toast.error(error ?? "Couldn't open recruitment.");
      return;
    }
    await PostService.create({
      club_id: clubId,
      type: "recruitment",
      title: form.title,
      content: form.description || null,
      image_url: form.banner_url,
      recruitment_id: drive.id,
    });
    setSaving(false);
    toast.success("Recruitment drive opened.");
    onDone(true);
  }

  return (
    <div className="space-y-4">
      <div>
        <Label htmlFor="rc_title">Recruitment title</Label>
        <Input id="rc_title" placeholder="Core Team Recruitment 2026" value={form.title} onChange={(e) => set("title", e.target.value)} />
      </div>
      <div>
        <Label htmlFor="rc_desc">Description</Label>
        <Textarea id="rc_desc" rows={3} value={form.description} onChange={(e) => set("description", e.target.value)} />
      </div>
      <div>
        <Label>Banner (optional)</Label>
        <ImageUpload value={form.banner_url} onChange={(v) => set("banner_url", v)} folder="recruitment" ownerId={clubId} aspect="aspect-[3/1]" />
      </div>
      <div>
        <Label htmlFor="rc_positions">Open positions (comma separated)</Label>
        <Input id="rc_positions" placeholder="Design Lead, Web Developer, Content Writer" value={form.positions} onChange={(e) => set("positions", e.target.value)} />
      </div>
      <div>
        <Label htmlFor="rc_eligibility">Eligibility</Label>
        <Input id="rc_eligibility" placeholder="Open to all years" value={form.eligibility} onChange={(e) => set("eligibility", e.target.value)} />
      </div>
      <div className="grid grid-cols-2 gap-3">
        <div>
          <Label htmlFor="rc_skills">Skills required (comma separated)</Label>
          <Input id="rc_skills" placeholder="Figma, React" value={form.skills} onChange={(e) => set("skills", e.target.value)} />
        </div>
        <div>
          <Label htmlFor="rc_deadline">Application deadline</Label>
          <Input id="rc_deadline" type="datetime-local" value={form.deadline} onChange={(e) => set("deadline", e.target.value)} />
        </div>
      </div>
      <div className="flex justify-end gap-2 pt-1">
        <Button variant="secondary" onClick={() => onDone(false)}>
          Cancel
        </Button>
        <Button loading={saving} onClick={submit}>
          Open recruitment
        </Button>
      </div>
    </div>
  );
}
