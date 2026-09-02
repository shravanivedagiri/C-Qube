import { Router } from "express";
import { supabaseAdmin } from "../config/supabase";
import { requireAuth } from "../middleware/auth";
import { asyncHandler, ApiError } from "../middleware/errorHandler";
import { friendRequestSchema, friendRespondSchema } from "../validation/schemas";

export const friendsRouter = Router();

friendsRouter.use(requireAuth);

friendsRouter.get(
  "/",
  asyncHandler(async (req, res) => {
    const { data, error } = await supabaseAdmin
      .from("friendships")
      .select(
        "*, sender:profiles!friendships_sender_id_fkey(*), receiver:profiles!friendships_receiver_id_fkey(*)"
      )
      .or(`sender_id.eq.${req.auth!.userId},receiver_id.eq.${req.auth!.userId}`);
    if (error) throw error;
    res.json(data ?? []);
  })
);

friendsRouter.post(
  "/request",
  asyncHandler(async (req, res) => {
    const { receiver_id } = friendRequestSchema.parse(req.body);
    if (receiver_id === req.auth!.userId) {
      throw new ApiError(400, "You can't send a friend request to yourself.");
    }
    const { data, error } = await supabaseAdmin
      .from("friendships")
      .insert({ sender_id: req.auth!.userId, receiver_id })
      .select()
      .single();
    if (error) {
      if (error.code === "23505") throw new ApiError(409, "Request already sent.");
      throw error;
    }
    res.status(201).json(data);
  })
);

friendsRouter.patch(
  "/:id/respond",
  asyncHandler(async (req, res) => {
    const { status } = friendRespondSchema.parse(req.body);
    const { data: friendship, error: fetchErr } = await supabaseAdmin
      .from("friendships")
      .select("*")
      .eq("id", req.params.id)
      .maybeSingle();
    if (fetchErr) throw fetchErr;
    if (!friendship) throw new ApiError(404, "Request not found.");
    if (friendship.receiver_id !== req.auth!.userId) {
      throw new ApiError(403, "Only the recipient can respond to this request.");
    }
    const { data, error } = await supabaseAdmin
      .from("friendships")
      .update({ status })
      .eq("id", req.params.id)
      .select()
      .single();
    if (error) throw error;
    res.json(data);
  })
);
