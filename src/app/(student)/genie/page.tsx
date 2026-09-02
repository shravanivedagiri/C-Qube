"use client";

import { Loader2, Send, Sparkles } from "lucide-react";
import { useEffect, useRef, useState } from "react";
import { PageHeader } from "@/components/layout/page-header";
import { cn } from "@/lib/utils";
import { GenieService } from "@/services/genie-service";

type Message = { role: "user" | "genie"; text: string; error?: boolean };

const SUGGESTIONS = [
  "Which clubs are beginner friendly?",
  "What events are happening this weekend?",
  "Which technical clubs are related to AI?",
  "What clubs can I join if I like design and photography?",
];

export default function AskGeniePage() {
  const [messages, setMessages] = useState<Message[]>([
    {
      role: "genie",
      text: "Hey! I'm Genie — ask me about clubs, events, recruitment, or what your friends are up to on campus.",
    },
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [conversationId, setConversationId] = useState<string | undefined>();
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: "smooth" });
  }, [messages, loading]);

  async function send(text: string) {
    if (!text.trim() || loading) return;
    setMessages((m) => [...m, { role: "user", text }]);
    setInput("");
    setLoading(true);
    try {
      const reply = await GenieService.ask(text, conversationId);
      setConversationId(reply.conversationId);
      setMessages((m) => [...m, { role: "genie", text: reply.text }]);
    } catch (err) {
      setMessages((m) => [
        ...m,
        {
          role: "genie",
          text: err instanceof Error ? err.message : "Something went wrong. Try again.",
          error: true,
        },
      ]);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="mx-auto flex h-[calc(100vh-8rem)] max-w-2xl flex-col sm:h-[calc(100vh-6rem)]">
      <PageHeader title="Ask Genie" description="Your AI assistant for everything on campus." />

      <div ref={scrollRef} className="flex-1 space-y-4 overflow-y-auto pb-4">
        {messages.map((m, i) => (
          <div key={i} className={cn("flex", m.role === "user" ? "justify-end" : "justify-start")}>
            {m.role === "genie" && (
              <div className="mr-2 flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-brand-soft">
                <Sparkles className="h-4 w-4 text-brand" />
              </div>
            )}
            <div
              className={cn(
                "max-w-[80%] rounded-2xl px-4 py-2.5 text-sm leading-relaxed",
                m.role === "user"
                  ? "bg-brand text-brand-foreground"
                  : m.error
                    ? "bg-danger-soft text-danger"
                    : "bg-surface border border-border text-foreground"
              )}
            >
              {m.text}
            </div>
          </div>
        ))}
        {loading && (
          <div className="flex justify-start">
            <div className="mr-2 flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-brand-soft">
              <Sparkles className="h-4 w-4 text-brand" />
            </div>
            <div className="flex items-center gap-1.5 rounded-2xl border border-border bg-surface px-4 py-3">
              <span className="h-1.5 w-1.5 animate-bounce rounded-full bg-muted [animation-delay:-0.3s]" />
              <span className="h-1.5 w-1.5 animate-bounce rounded-full bg-muted [animation-delay:-0.15s]" />
              <span className="h-1.5 w-1.5 animate-bounce rounded-full bg-muted" />
            </div>
          </div>
        )}
      </div>

      {messages.length <= 1 && (
        <div className="mb-3 flex flex-wrap gap-2">
          {SUGGESTIONS.map((s) => (
            <button
              key={s}
              onClick={() => send(s)}
              className="rounded-full border border-border bg-surface px-3 py-1.5 text-xs font-medium text-muted transition hover:border-brand/50 hover:text-brand"
            >
              {s}
            </button>
          ))}
        </div>
      )}

      <form
        onSubmit={(e) => {
          e.preventDefault();
          send(input);
        }}
        className="flex items-center gap-2 rounded-2xl border border-border bg-surface p-2 shadow-sm"
      >
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Ask Genie anything about campus..."
          className="flex-1 bg-transparent px-2 text-sm outline-none placeholder:text-muted"
        />
        <button
          type="submit"
          disabled={loading || !input.trim()}
          className="flex h-9 w-9 items-center justify-center rounded-xl bg-brand text-brand-foreground transition disabled:opacity-40"
        >
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4" />}
        </button>
      </form>
    </div>
  );
}
