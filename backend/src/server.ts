import cors from "cors";
import express from "express";
import helmet from "helmet";
import morgan from "morgan";
import { env } from "./config/env";
import { errorHandler } from "./middleware/errorHandler";

import { authRouter } from "./routes/auth.routes";
import { studentsRouter } from "./routes/students.routes";
import { clubsRouter } from "./routes/clubs.routes";
import { eventsRouter } from "./routes/events.routes";
import { friendsRouter } from "./routes/friends.routes";
import { notificationsRouter } from "./routes/notifications.routes";
import { recruitmentRouter } from "./routes/recruitment.routes";
import { galleryRouter } from "./routes/gallery.routes";
import { adminRouter } from "./routes/admin.routes";
import { reportsRouter } from "./routes/reports.routes";
import { analyticsRouter } from "./routes/analytics.routes";
import { genieRouter } from "./routes/genie.routes";

const app = express();

app.use(helmet());
app.use(cors({ origin: env.corsOrigins, credentials: true }));
app.use(express.json({ limit: "1mb" }));
app.use(morgan("dev"));

app.get("/health", (_req, res) => res.json({ ok: true, service: "cqube-backend" }));

app.use("/auth", authRouter);
app.use("/students", studentsRouter);
app.use("/clubs", clubsRouter);
app.use("/events", eventsRouter);
app.use("/friends", friendsRouter);
app.use("/notifications", notificationsRouter);
app.use("/recruitment", recruitmentRouter);
app.use("/gallery", galleryRouter);
app.use("/admin", adminRouter);
app.use("/reports", reportsRouter);
app.use("/analytics", analyticsRouter);
app.use("/genie", genieRouter);

app.use((_req, res) => res.status(404).json({ error: "Not found." }));
app.use(errorHandler);

app.listen(env.port, () => {
  console.log(`[cqube-backend] listening on http://localhost:${env.port}`);
});
