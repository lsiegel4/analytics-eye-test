ALTER TABLE "pipeline_runs" ALTER COLUMN "started_at" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "pipeline_runs" ALTER COLUMN "status" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "pipeline_runs" ALTER COLUMN "players_updated" SET NOT NULL;