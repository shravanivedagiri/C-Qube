"use client";

import { Flag, Heart, MessageCircle, Share2, Trash2 } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useState } from "react";
import { toast } from "sonner";
import { Avatar } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTrigger } from "@/components/ui/dialog";
import { Label, Select, Textarea } from "@/components/ui/input";
import { relativeTime } from "@/lib/utils";
import { PostService, type PostWithClub } from "@/services/post-service";
import { REPORT_REASONS, ReportService, type ReportReason } from "@/services/report-service";

const TYPE_LABEL: Record<string, { label: string; variant: "brand" | "accent" | "success" | "warning" }> = {
  announcement: { label: "Announcement", variant: "brand" },
  general: { label: "Update", variant: "brand" },
  achievement: { label: "Achievement", variant: "success" },
  recruitment: { label: "Recruitment", variant: "accent" },
  event: { label: "Event", variant: "warning" },
};

export function PostCard({
  post,
  currentStudentId,
  canDelete,
  onDeleted,
}: {
  post: PostWithClub;
  currentStudentId?: string;
  canDelete?: boolean;
  onDeleted?: () => void;
}) {
  const [liked, setLiked] = useState(post.liked_by_me);
  const [likeCount, setLikeCount] = useState(post.like_count);
  const meta = TYPE_LABEL[post.type] ?? TYPE_LABEL.general;

  async function toggleLike() {
    if (!currentStudentId) {
      toast.info("Log in as a student to like posts.");
      return;
    }
    if (liked) {
      setLiked(false);
      setLikeCount((c) => c - 1);
      await PostService.unlike(post.id, currentStudentId);
    } else {
      setLiked(true);
      setLikeCount((c) => c + 1);
      await PostService.like(post.id, currentStudentId);
    }
  }

  async function share() {
    const url = `${window.location.origin}/discover?club=${post.club_id}`;
    await navigator.clipboard.writeText(url).catch(() => {});
    toast.success("Link copied.");
  }

  async function remove() {
    const { error } = await PostService.delete(post.id);
    if (error) {
      toast.error(error);
      return;
    }
    toast.success("Post removed.");
    onDeleted?.();
  }

  return (
    <article className="rounded-2xl border border-border bg-surface p-5 shadow-sm">
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-center gap-3">
          <Avatar src={post.clubs?.logo_url} name={post.clubs?.name ?? "Club"} size={38} />
          <div>
            <Link
              href={`/discover?club=${post.club_id}`}
              className="text-sm font-semibold hover:underline"
            >
              {post.clubs?.name ?? "Club"}
            </Link>
            <p className="text-xs text-muted">{relativeTime(post.created_at)}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Badge variant={meta.variant}>{meta.label}</Badge>
          {canDelete && (
            <button
              onClick={remove}
              aria-label="Delete post"
              className="rounded-lg p-1.5 text-muted transition hover:bg-danger-soft hover:text-danger"
            >
              <Trash2 className="h-3.5 w-3.5" />
            </button>
          )}
        </div>
      </div>

      {post.title && <h3 className="mt-3 text-base font-semibold">{post.title}</h3>}
      {post.content && (
        <p className="mt-1.5 whitespace-pre-line text-sm leading-relaxed text-foreground/90">
          {post.content}
        </p>
      )}
      {post.image_url && (
        <div className="relative mt-3 aspect-video w-full overflow-hidden rounded-xl border border-border">
          <Image src={post.image_url} alt="" fill className="object-cover" />
        </div>
      )}

      <div className="mt-4 flex items-center gap-4 border-t border-border pt-3 text-sm text-muted">
        {/* Posts are view-only for students — no like/comment on this side. */}
        {!currentStudentId && (
          <>
            <button
              onClick={toggleLike}
              className={`flex items-center gap-1.5 transition hover:text-danger ${liked ? "text-danger" : ""}`}
            >
              <Heart className={`h-4 w-4 ${liked ? "fill-current" : ""}`} />
              {likeCount}
            </button>
            <span className="flex items-center gap-1.5">
              <MessageCircle className="h-4 w-4" />
              {post.comment_count}
            </span>
          </>
        )}
        <button onClick={share} className="flex items-center gap-1.5 transition hover:text-foreground">
          <Share2 className="h-4 w-4" />
          Share
        </button>
        {currentStudentId && <ReportDialog postId={post.id} clubId={post.club_id} className="ml-auto" />}
      </div>
    </article>
  );
}

function ReportDialog({
  postId,
  clubId,
  className,
}: {
  postId: string;
  clubId: string;
  className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [reason, setReason] = useState<ReportReason>("inappropriate_content");
  const [description, setDescription] = useState("");
  const [submitting, setSubmitting] = useState(false);

  async function submit() {
    setSubmitting(true);
    const { error } = await ReportService.file({ post_id: postId, club_id: clubId, reason, description });
    setSubmitting(false);
    if (error) {
      toast.error(error);
      return;
    }
    toast.success("Report submitted. Thanks for flagging this.");
    setOpen(false);
    setDescription("");
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <button className={`flex items-center gap-1.5 transition hover:text-danger ${className ?? ""}`}>
          <Flag className="h-4 w-4" />
        </button>
      </DialogTrigger>
      <DialogContent title="Report this post" description="Let us know what's wrong — a moderator will review it.">
        <div className="space-y-4">
          <div>
            <Label htmlFor="report-reason">Reason</Label>
            <Select id="report-reason" value={reason} onChange={(e) => setReason(e.target.value as ReportReason)}>
              {REPORT_REASONS.map((r) => (
                <option key={r.value} value={r.value}>
                  {r.label}
                </option>
              ))}
            </Select>
          </div>
          <div>
            <Label htmlFor="report-description">Details (optional)</Label>
            <Textarea
              id="report-description"
              rows={3}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
          </div>
          <div className="flex justify-end gap-2">
            <Button variant="secondary" onClick={() => setOpen(false)}>
              Cancel
            </Button>
            <Button variant="danger" loading={submitting} onClick={submit}>
              Submit report
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
