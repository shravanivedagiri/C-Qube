"use client";

import { Award, Calendar, Pencil, Trophy, Users } from "lucide-react";
import { useEffect, useState } from "react";
import { toast } from "sonner";
import { ChipSelect } from "@/components/shared/chip-select";
import { ImageUpload } from "@/components/shared/image-upload";
import { PageHeader } from "@/components/layout/page-header";
import { Avatar } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTrigger } from "@/components/ui/dialog";
import { Input, Label, Select, Textarea } from "@/components/ui/input";
import { CardSkeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { DEPARTMENTS, INTERESTS, YEARS } from "@/lib/constants";
import { createClient } from "@/lib/supabase/client";
import { relativeTime } from "@/lib/utils";
import { PointsService } from "@/services/points-service";
import type { Database } from "@/types/database";

type StudentProfile = Database["public"]["Tables"]["student_profiles"]["Row"];
type ActivityPoint = Database["public"]["Tables"]["activity_points"]["Row"];

export default function ProfilePage() {
  const { user, profile } = useCurrentProfile();
  const [studentProfile, setStudentProfile] = useState<StudentProfile | null>(null);
  const [timeline, setTimeline] = useState<ActivityPoint[]>([]);
  const [clubsJoined, setClubsJoined] = useState(0);
  const [eventsRegistered, setEventsRegistered] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;
    Promise.all([
      PointsService.getStudentProfile(user.id),
      PointsService.timeline(user.id),
      PointsService.clubsJoinedCount(user.id),
      PointsService.eventsAttendedCount(user.id),
    ]).then(([sp, tl, cj, er]) => {
      setStudentProfile(sp.data);
      setTimeline(tl.data ?? []);
      setClubsJoined(cj);
      setEventsRegistered(er);
      setLoading(false);
    });
  }, [user]);

  if (loading || !profile) return <CardSkeleton />;

  return (
    <div>
      <PageHeader
        title="Profile"
        actions={
          user &&
          studentProfile && (
            <EditProfileDialog userId={user.id} profile={profile} studentProfile={studentProfile} />
          )
        }
      />

      <div className="flex flex-wrap items-center gap-4 rounded-2xl border border-border bg-surface p-6 shadow-sm">
        <Avatar src={profile.avatar_url} name={profile.name} size={72} />
        <div className="flex-1">
          <h2 className="text-lg font-semibold">{profile.name}</h2>
          <p className="text-sm text-muted">
            {profile.department} {profile.year && `· ${profile.year}`}
          </p>
          {profile.bio && <p className="mt-2 max-w-xl text-sm text-foreground/90">{profile.bio}</p>}
          {studentProfile && studentProfile.interests.length > 0 && (
            <div className="mt-3 flex flex-wrap gap-1.5">
              {studentProfile.interests.map((i) => (
                <Badge key={i} variant="brand">
                  {i}
                </Badge>
              ))}
            </div>
          )}
        </div>
      </div>

      <div className="mt-4 grid gap-4 sm:grid-cols-3">
        <Stat icon={Trophy} label="Points" value={studentProfile?.points ?? 0} />
        <Stat icon={Users} label="Clubs joined" value={clubsJoined} />
        <Stat icon={Calendar} label="Events registered" value={eventsRegistered} />
      </div>

      <h2 className="mb-3 mt-8 text-sm font-semibold uppercase tracking-wide text-muted">Activity timeline</h2>
      {timeline.length === 0 ? (
        <p className="text-sm text-muted">No activity yet — join a club or register for an event to get started.</p>
      ) : (
        <div className="space-y-3">
          {timeline.map((t) => (
            <div key={t.id} className="flex items-center gap-3 rounded-xl border border-border bg-surface p-3.5">
              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-accent-soft">
                <Award className="h-4 w-4 text-accent" />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-sm capitalize">{t.activity_type.replace(/_/g, " ")}</p>
                <p className="text-xs text-muted">{relativeTime(t.created_at)}</p>
              </div>
              <span className="text-sm font-semibold text-accent">+{t.points}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function Stat({ icon: Icon, label, value }: { icon: typeof Trophy; label: string; value: number }) {
  return (
    <div className="flex items-center gap-4 rounded-2xl border border-border bg-surface p-5 shadow-sm">
      <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-brand-soft">
        <Icon className="h-5 w-5 text-brand" />
      </div>
      <div>
        <p className="text-2xl font-semibold tracking-tight">{value}</p>
        <p className="text-xs text-muted">{label}</p>
      </div>
    </div>
  );
}

function EditProfileDialog({
  userId,
  profile,
  studentProfile,
}: {
  userId: string;
  profile: Database["public"]["Tables"]["profiles"]["Row"];
  studentProfile: StudentProfile;
}) {
  const [open, setOpen] = useState(false);
  const [avatarUrl, setAvatarUrl] = useState(profile.avatar_url);
  const [name, setName] = useState(profile.name);
  const [bio, setBio] = useState(profile.bio ?? "");
  const [department, setDepartment] = useState(profile.department ?? DEPARTMENTS[0]);
  const [year, setYear] = useState(profile.year ?? YEARS[0]);
  const [interests, setInterests] = useState<string[]>(studentProfile.interests);
  const [skills, setSkills] = useState(studentProfile.skills.join(", "));
  const [goals, setGoals] = useState(studentProfile.goals ?? "");
  const [showEmail, setShowEmail] = useState(studentProfile.privacy.show_email);
  const [saving, setSaving] = useState(false);

  async function save() {
    setSaving(true);
    const supabase = createClient();
    const [{ error: e1 }, { error: e2 }] = await Promise.all([
      supabase.from("profiles").update({ name, avatar_url: avatarUrl, bio, department, year }).eq("id", userId),
      PointsService.updateStudentProfile(userId, {
        interests,
        skills: skills.split(",").map((s) => s.trim()).filter(Boolean),
        goals,
        privacy: { ...studentProfile.privacy, show_email: showEmail },
      }),
    ]);
    setSaving(false);
    if (e1 || e2) {
      toast.error(e1?.message ?? e2 ?? "Couldn't save changes.");
      return;
    }
    toast.success("Profile updated.");
    setOpen(false);
    window.location.reload();
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="secondary" icon={<Pencil className="h-4 w-4" />}>
          Edit profile
        </Button>
      </DialogTrigger>
      <DialogContent title="Edit profile" className="max-h-[85vh] overflow-y-auto">
        <div className="space-y-4">
          <ImageUpload value={avatarUrl} onChange={setAvatarUrl} folder="avatars" ownerId={userId} label="Photo" aspect="h-20 w-20" shape="circle" />
          <div>
            <Label htmlFor="name">Name</Label>
            <Input id="name" value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <Label htmlFor="department">Department</Label>
              <Select id="department" value={department} onChange={(e) => setDepartment(e.target.value)}>
                {DEPARTMENTS.map((d) => (
                  <option key={d}>{d}</option>
                ))}
              </Select>
            </div>
            <div>
              <Label htmlFor="year">Year</Label>
              <Select id="year" value={year} onChange={(e) => setYear(e.target.value)}>
                {YEARS.map((y) => (
                  <option key={y}>{y}</option>
                ))}
              </Select>
            </div>
          </div>
          <div>
            <Label htmlFor="bio">Bio</Label>
            <Textarea id="bio" rows={2} value={bio} onChange={(e) => setBio(e.target.value)} />
          </div>
          <div>
            <Label>Interests</Label>
            <ChipSelect options={INTERESTS} value={interests} onChange={setInterests} />
          </div>
          <div>
            <Label htmlFor="skills">Skills</Label>
            <Input id="skills" value={skills} onChange={(e) => setSkills(e.target.value)} />
          </div>
          <div>
            <Label htmlFor="goals">Goals</Label>
            <Textarea id="goals" rows={2} value={goals} onChange={(e) => setGoals(e.target.value)} />
          </div>
          <label className="flex items-center gap-2 text-sm">
            <input type="checkbox" checked={showEmail} onChange={(e) => setShowEmail(e.target.checked)} className="h-4 w-4 rounded border-border" />
            Show my email to friends
          </label>
          <Button fullWidth loading={saving} onClick={save}>
            Save changes
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
