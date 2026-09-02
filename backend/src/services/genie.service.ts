import { env, isGenieConfigured } from "../config/env";
import { getDatabricksToken } from "../config/databricks-auth";

/**
 * Databricks Genie Conversation API client.
 * Frontend -> this backend -> Databricks Genie -> Databricks data.
 * The Databricks token never leaves this process.
 */

type GenieAttachment = {
  attachment_id?: string;
  text?: { content: string; purpose?: string };
  query?: { query: string; statement_id?: string };
};

type GenieMessage = {
  conversation_id: string;
  message_id: string;
  status:
    | "SUBMITTED"
    | "FETCHING_METADATA"
    | "FILTERING_CONTEXT"
    | "ASKING_AI"
    | "PENDING_WAREHOUSE"
    | "EXECUTING_QUERY"
    | "COMPLETED"
    | "FAILED"
    | "QUERY_RESULT_EXPIRED"
    | "CANCELLED";
  attachments?: GenieAttachment[];
};

function baseUrl() {
  const host = env.databricks.host.replace(/^https?:\/\//, "").replace(/\/$/, "");
  return `https://${host}`;
}

async function databricksFetch(path: string, init?: RequestInit): Promise<GenieMessage> {
  const token = await getDatabricksToken();
  const res = await fetch(`${baseUrl()}${path}`, {
    ...init,
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      ...init?.headers,
    },
    signal: AbortSignal.timeout(25000),
  });
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    throw new Error(`Databricks Genie API ${res.status}: ${body.slice(0, 300)}`);
  }
  return (await res.json()) as GenieMessage;
}

async function pollUntilDone(conversationId: string, messageId: string): Promise<GenieMessage> {
  const terminal = new Set(["COMPLETED", "FAILED", "QUERY_RESULT_EXPIRED", "CANCELLED"]);
  let last: GenieMessage | null = null;
  for (let attempt = 0; attempt < 14; attempt++) {
    last = await databricksFetch(
      `/api/2.0/genie/spaces/${env.databricks.genieSpaceId}/conversations/${conversationId}/messages/${messageId}`
    );
    if (terminal.has(last.status)) return last;
    await new Promise((r) => setTimeout(r, 1500));
  }
  return last!;
}

function extractAnswer(message: GenieMessage): string {
  const attachments = message.attachments ?? [];
  const answer = attachments.find((a) => a.text?.purpose === "TEXT_ATTACHMENT_PURPOSE_ANSWER");
  if (answer?.text?.content) return answer.text.content;
  const anyText = attachments.find((a) => a.text?.content);
  if (anyText?.text?.content) return anyText.text.content;
  if (attachments.some((a) => a.query)) {
    return "I ran a query for that, but couldn't summarize the result as text.";
  }
  if (message.status === "FAILED") return "Genie couldn't answer that one — try rephrasing.";
  return "I didn't find anything for that.";
}

export async function askGenie(
  question: string,
  conversationId?: string
): Promise<{ conversationId: string; messageId: string; text: string }> {
  if (!isGenieConfigured) {
    throw new Error("Databricks Genie is not configured.");
  }

  const started = conversationId
    ? await databricksFetch(
        `/api/2.0/genie/spaces/${env.databricks.genieSpaceId}/conversations/${conversationId}/messages`,
        { method: "POST", body: JSON.stringify({ content: question }) }
      )
    : await databricksFetch(`/api/2.0/genie/spaces/${env.databricks.genieSpaceId}/start-conversation`, {
        method: "POST",
        body: JSON.stringify({ content: question }),
      });

  const final =
    started.status === "COMPLETED" || started.status === "FAILED"
      ? started
      : await pollUntilDone(started.conversation_id, started.message_id);

  return {
    conversationId: final.conversation_id ?? started.conversation_id,
    messageId: final.message_id ?? started.message_id,
    text: extractAnswer(final),
  };
}

export function mockGenieAnswer(question: string): string {
  const q = question.toLowerCase();
  if (q.includes("beginner")) {
    return "Beginner-friendly clubs on campus right now: Photography Club, Dance Club, and Entrepreneurship Club.";
  }
  if (q.includes("weekend") || q.includes("this week")) {
    return "Check the Calendar tab for this week's events — I couldn't reach live campus data just now.";
  }
  return "Here's what I found on campus for that — try asking about clubs, events, recruitment drives, or friends' activity.";
}
