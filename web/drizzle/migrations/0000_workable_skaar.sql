CREATE TABLE "pipeline_runs" (
	"id" serial PRIMARY KEY NOT NULL,
	"started_at" timestamp with time zone,
	"completed_at" timestamp with time zone,
	"status" text,
	"players_updated" integer,
	"errors_json" jsonb
);
--> statement-breakpoint
CREATE TABLE "player_clips" (
	"id" serial PRIMARY KEY NOT NULL,
	"player_id" integer NOT NULL,
	"skill_category" text NOT NULL,
	"video_id" text,
	"is_playable" boolean,
	"verified_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "player_stats" (
	"id" serial PRIMARY KEY NOT NULL,
	"player_id" integer NOT NULL,
	"stat_key" text NOT NULL,
	"stat_value" numeric,
	"percentile" numeric,
	"updated_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "players" (
	"id" serial PRIMARY KEY NOT NULL,
	"slug" text NOT NULL,
	"name" text,
	"school" text,
	"position" text,
	"big_board_rank" integer,
	"is_active" boolean DEFAULT true,
	CONSTRAINT "players_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
ALTER TABLE "player_clips" ADD CONSTRAINT "player_clips_player_id_players_id_fk" FOREIGN KEY ("player_id") REFERENCES "public"."players"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "player_stats" ADD CONSTRAINT "player_stats_player_id_players_id_fk" FOREIGN KEY ("player_id") REFERENCES "public"."players"("id") ON DELETE no action ON UPDATE no action;