/**
 * Hand-maintained mirror of `supabase/migrations/*.sql`.
 * If the schema changes, update this file (or regenerate with
 * `npx supabase gen types typescript --project-id <ref>`).
 */

export type UserRole = "student" | "club" | "admin";
export type ReportReason =
  | "inappropriate_content"
  | "spam"
  | "misleading_information"
  | "harassment"
  | "policy_violation"
  | "other";
export type ReportStatus = "open" | "under_review" | "resolved" | "dismissed";
export type PostType =
  | "announcement"
  | "general"
  | "achievement"
  | "recruitment"
  | "event";
export type EventCategory =
  | "Technical"
  | "Cultural"
  | "Sports"
  | "Workshop"
  | "Competition"
  | "Seminar"
  | "Social"
  | "Other";
export type EventStatus = "draft" | "published" | "cancelled";
export type RegistrationStatus = "registered" | "attended" | "cancelled" | "no_show";
export type FriendshipStatus = "pending" | "accepted" | "rejected" | "blocked";
export type NotificationType =
  | "friend"
  | "event"
  | "club"
  | "friend_activity"
  | "recruitment"
  | "system";
export type MediaType = "image" | "video";
export type ApplicationStatus =
  | "applied"
  | "under_review"
  | "shortlisted"
  | "selected"
  | "rejected";
export type ClubRequestStatus = "pending" | "approved" | "rejected";
export type ClubMemberRole = "member" | "coordinator" | "lead";

interface Table<Row, Insert, Update> {
  Row: Row;
  Insert: Insert;
  Update: Update;
  Relationships: [];
}

export interface Database {
  public: {
    Tables: {
      profiles: Table<
        {
          id: string;
          name: string;
          email: string;
          avatar_url: string | null;
          department: string | null;
          year: string | null;
          bio: string | null;
          role: UserRole;
          created_at: string;
          updated_at: string;
        },
        {
          id: string;
          name: string;
          email: string;
          avatar_url?: string | null;
          department?: string | null;
          year?: string | null;
          bio?: string | null;
          role: UserRole;
        },
        Partial<{
          name: string;
          avatar_url: string | null;
          department: string | null;
          year: string | null;
          bio: string | null;
        }>
      >;
      student_profiles: Table<
        {
          user_id: string;
          interests: string[];
          skills: string[];
          goals: string | null;
          points: number;
          privacy: { show_email: boolean; show_activity_to_friends: boolean; show_points: boolean };
          created_at: string;
          updated_at: string;
        },
        {
          user_id: string;
          interests?: string[];
          skills?: string[];
          goals?: string | null;
        },
        Partial<{
          interests: string[];
          skills: string[];
          goals: string | null;
          privacy: { show_email: boolean; show_activity_to_friends: boolean; show_points: boolean };
        }>
      >;
      clubs: Table<
        {
          id: string;
          owner_id: string | null;
          name: string;
          email: string;
          logo_url: string | null;
          banner_url: string | null;
          about: string | null;
          category: string | null;
          department: string | null;
          contact_info: Record<string, string>;
          social_links: Record<string, string>;
          coordinator_name: string | null;
          coordinator_email: string | null;
          is_approved: boolean;
          profile_complete: boolean;
          account_activated: boolean;
          member_count: number;
          profile_view_count: number;
          created_at: string;
          updated_at: string;
        },
        {
          name: string;
          email: string;
          coordinator_name?: string | null;
          coordinator_email?: string | null;
          department?: string | null;
          is_approved?: boolean;
        },
        Partial<{
          owner_id: string | null;
          logo_url: string | null;
          banner_url: string | null;
          about: string | null;
          category: string | null;
          department: string | null;
          contact_info: Record<string, string>;
          social_links: Record<string, string>;
          profile_complete: boolean;
          account_activated: boolean;
        }>
      >;
      club_registration_requests: Table<
        {
          id: string;
          club_name: string;
          club_email: string;
          coordinator_name: string;
          coordinator_email: string;
          department: string | null;
          description: string | null;
          reason: string | null;
          status: ClubRequestStatus;
          reviewed_by: string | null;
          reviewed_at: string | null;
          rejection_reason: string | null;
          created_at: string;
        },
        {
          club_name: string;
          club_email: string;
          coordinator_name: string;
          coordinator_email: string;
          department?: string | null;
          description?: string | null;
          reason?: string | null;
        },
        Partial<{
          status: ClubRequestStatus;
          reviewed_by: string | null;
          reviewed_at: string | null;
          rejection_reason: string | null;
        }>
      >;
      club_members: Table<
        {
          id: string;
          club_id: string;
          student_id: string;
          role: ClubMemberRole;
          joined_at: string;
        },
        { club_id: string; student_id: string; role?: ClubMemberRole },
        Partial<{ role: ClubMemberRole }>
      >;
      club_follows: Table<
        { id: string; club_id: string; student_id: string; created_at: string },
        { club_id: string; student_id: string },
        Record<string, never>
      >;
      club_profile_views: Table<
        { id: string; club_id: string; student_id: string; viewed_at: string },
        { club_id: string; student_id: string },
        Record<string, never>
      >;
      club_membership_requests: Table<
        {
          id: string;
          club_id: string;
          student_id: string;
          status: "pending" | "accepted" | "rejected";
          created_at: string;
          reviewed_at: string | null;
          reviewed_by: string | null;
        },
        { club_id: string; student_id: string },
        Partial<{ status: "pending" | "accepted" | "rejected"; reviewed_at: string | null; reviewed_by: string | null }>
      >;
      posts: Table<
        {
          id: string;
          club_id: string;
          type: PostType;
          title: string | null;
          content: string | null;
          image_url: string | null;
          event_id: string | null;
          recruitment_id: string | null;
          created_at: string;
          updated_at: string;
        },
        {
          club_id: string;
          type: PostType;
          title?: string | null;
          content?: string | null;
          image_url?: string | null;
          event_id?: string | null;
          recruitment_id?: string | null;
        },
        Partial<{ title: string | null; content: string | null; image_url: string | null }>
      >;
      post_likes: Table<
        { id: string; post_id: string; student_id: string; created_at: string },
        { post_id: string; student_id: string },
        Record<string, never>
      >;
      post_comments: Table<
        { id: string; post_id: string; student_id: string; content: string; created_at: string },
        { post_id: string; student_id: string; content: string },
        Record<string, never>
      >;
      events: Table<
        {
          id: string;
          club_id: string;
          title: string;
          description: string | null;
          banner_url: string | null;
          date: string;
          start_time: string;
          end_time: string | null;
          location: string | null;
          is_online: boolean;
          capacity: number | null;
          registration_deadline: string | null;
          category: EventCategory;
          status: EventStatus;
          created_at: string;
          updated_at: string;
        },
        {
          club_id: string;
          title: string;
          description?: string | null;
          banner_url?: string | null;
          date: string;
          start_time: string;
          end_time?: string | null;
          location?: string | null;
          is_online?: boolean;
          capacity?: number | null;
          registration_deadline?: string | null;
          category: EventCategory;
          status?: EventStatus;
        },
        Partial<{
          title: string;
          description: string | null;
          banner_url: string | null;
          date: string;
          start_time: string;
          end_time: string | null;
          location: string | null;
          is_online: boolean;
          capacity: number | null;
          registration_deadline: string | null;
          category: EventCategory;
          status: EventStatus;
        }>
      >;
      event_registrations: Table<
        {
          id: string;
          event_id: string;
          student_id: string;
          registered_at: string;
          status: RegistrationStatus;
        },
        { event_id: string; student_id: string; status?: RegistrationStatus },
        Partial<{ status: RegistrationStatus }>
      >;
      friendships: Table<
        {
          id: string;
          sender_id: string;
          receiver_id: string;
          status: FriendshipStatus;
          created_at: string;
          updated_at: string;
        },
        { sender_id: string; receiver_id: string; status?: FriendshipStatus },
        Partial<{ status: FriendshipStatus }>
      >;
      notifications: Table<
        {
          id: string;
          user_id: string;
          type: NotificationType;
          title: string;
          body: string | null;
          reference_id: string | null;
          reference_type: string | null;
          is_read: boolean;
          created_at: string;
        },
        {
          user_id: string;
          type: NotificationType;
          title: string;
          body?: string | null;
          reference_id?: string | null;
          reference_type?: string | null;
        },
        Partial<{ is_read: boolean }>
      >;
      gallery: Table<
        {
          id: string;
          club_id: string;
          media_url: string;
          media_type: MediaType;
          thumbnail_url: string | null;
          caption: string | null;
          created_at: string;
        },
        {
          club_id: string;
          media_url: string;
          media_type: MediaType;
          thumbnail_url?: string | null;
          caption?: string | null;
        },
        Record<string, never>
      >;
      recruitment_drives: Table<
        {
          id: string;
          club_id: string;
          title: string;
          description: string | null;
          positions: string[];
          eligibility: string | null;
          skills_required: string[];
          deadline: string;
          questions: { id: string; question: string; required: boolean }[];
          banner_url: string | null;
          status: "open" | "closed";
          created_at: string;
          updated_at: string;
        },
        {
          club_id: string;
          title: string;
          description?: string | null;
          positions?: string[];
          eligibility?: string | null;
          skills_required?: string[];
          deadline: string;
          questions?: { id: string; question: string; required: boolean }[];
          banner_url?: string | null;
        },
        Partial<{ status: "open" | "closed"; title: string; description: string | null }>
      >;
      recruitment_applications: Table<
        {
          id: string;
          recruitment_id: string;
          student_id: string;
          answers: Record<string, string>;
          status: ApplicationStatus;
          created_at: string;
          updated_at: string;
        },
        { recruitment_id: string; student_id: string; answers: Record<string, string> },
        Partial<{ status: ApplicationStatus }>
      >;
      content_reports: Table<
        {
          id: string;
          reporter_id: string;
          club_id: string | null;
          post_id: string | null;
          reason: ReportReason;
          description: string | null;
          status: ReportStatus;
          admin_note: string | null;
          reviewed_by: string | null;
          created_at: string;
          updated_at: string;
          resolved_at: string | null;
        },
        {
          reporter_id: string;
          club_id?: string | null;
          post_id?: string | null;
          reason: ReportReason;
          description?: string | null;
        },
        Partial<{
          status: ReportStatus;
          admin_note: string | null;
          reviewed_by: string | null;
          resolved_at: string | null;
        }>
      >;
      activity_points: Table<
        {
          id: string;
          student_id: string;
          activity_type: string;
          points: number;
          reference_id: string | null;
          reference_type: string | null;
          created_at: string;
        },
        {
          student_id: string;
          activity_type: string;
          points: number;
          reference_id?: string | null;
          reference_type?: string | null;
        },
        Record<string, never>
      >;
    };
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: Record<string, never>;
    CompositeTypes: Record<string, never>;
  };
}
