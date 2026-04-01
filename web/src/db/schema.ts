import {
  pgTable,
  serial,
  text,
  integer,
  boolean,
  numeric,
  timestamp,
  jsonb,
} from 'drizzle-orm/pg-core';

export const players = pgTable('players', {
  id: serial('id').primaryKey(),
  slug: text('slug').unique().notNull(),
  name: text('name'),
  school: text('school'),
  position: text('position'),
  bigBoardRank: integer('big_board_rank'),
  isActive: boolean('is_active').default(true),
});

export const playerStats = pgTable('player_stats', {
  id: serial('id').primaryKey(),
  playerId: integer('player_id')
    .references(() => players.id)
    .notNull(),
  statKey: text('stat_key').notNull(),
  statValue: numeric('stat_value'),
  percentile: numeric('percentile'),
  updatedAt: timestamp('updated_at', { withTimezone: true }),
});

export const playerClips = pgTable('player_clips', {
  id: serial('id').primaryKey(),
  playerId: integer('player_id')
    .references(() => players.id)
    .notNull(),
  skillCategory: text('skill_category').notNull(),
  videoId: text('video_id'),
  // isPlayable tri-state: null = not yet verified, false = verified not playable, true = verified playable
  isPlayable: boolean('is_playable'),
  verifiedAt: timestamp('verified_at', { withTimezone: true }),
});

export const pipelineRuns = pgTable('pipeline_runs', {
  id: serial('id').primaryKey(),
  startedAt: timestamp('started_at', { withTimezone: true }).notNull(),
  completedAt: timestamp('completed_at', { withTimezone: true }),
  status: text('status').notNull(),
  playersUpdated: integer('players_updated').notNull(),
  errorsJson: jsonb('errors_json'),
});
