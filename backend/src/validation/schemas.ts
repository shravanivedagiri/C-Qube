import { z } from "zod";

export const clubRequestSchema = z.object({
  club_name: z.string().min(2),
  club_email: z.string().email(),
  coordinator_name: z.string().min(2),
  coordinator_email: z.string().email(),
  department: z.string().optional(),
  description: z.string().optional(),
  reason: z.string().optional(),
});

export const activateClubSchema = z.object({
  club_email: z.string().email(),
  coordinator_email: z.string().email(),
  password: z.string().min(8, "Password must be at least 8 characters."),
});

export const rejectRequestSchema = z.object({
  rejection_reason: z.string().optional(),
});

export const reportSchema = z.object({
  club_id: z.string().uuid().optional(),
  post_id: z.string().uuid().optional(),
  reason: z.enum([
    "inappropriate_content",
    "spam",
    "misleading_information",
    "harassment",
    "policy_violation",
    "other",
  ]),
  description: z.string().max(2000).optional(),
});

export const updateReportSchema = z.object({
  status: z.enum(["open", "under_review", "resolved", "dismissed"]).optional(),
  admin_note: z.string().max(2000).optional(),
});

export const genieMessageSchema = z.object({
  message: z.string().min(1).max(2000),
  conversationId: z.string().optional(),
});

export const eventRegistrationSchema = z.object({
  event_id: z.string().uuid(),
});

export const emailDomainSchema = z.object({
  email: z.string().email(),
});

export const updateStudentProfileSchema = z.object({
  name: z.string().min(2).optional(),
  bio: z.string().max(1000).optional(),
  department: z.string().optional(),
  year: z.string().optional(),
  avatar_url: z.string().url().nullish(),
  interests: z.array(z.string()).optional(),
  skills: z.array(z.string()).optional(),
  goals: z.string().optional(),
});

export const friendRequestSchema = z.object({
  receiver_id: z.string().uuid(),
});

export const friendRespondSchema = z.object({
  status: z.enum(["accepted", "rejected"]),
});

export const recruitmentDriveSchema = z.object({
  title: z.string().min(2),
  description: z.string().optional(),
  positions: z.array(z.string()).default([]),
  eligibility: z.string().optional(),
  skills_required: z.array(z.string()).default([]),
  deadline: z.string(),
  banner_url: z.string().url().nullish(),
  questions: z
    .array(z.object({ id: z.string(), question: z.string(), required: z.boolean() }))
    .default([]),
});

export const recruitmentApplySchema = z.object({
  answers: z.record(z.string(), z.string()),
});

export const recruitmentStatusSchema = z.object({
  status: z.enum(["applied", "under_review", "shortlisted", "selected", "rejected"]),
});

export const gallerySchema = z.object({
  media_url: z.string().url(),
  media_type: z.enum(["image", "video"]),
  caption: z.string().optional(),
});
