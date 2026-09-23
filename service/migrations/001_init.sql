BEGIN;

CREATE TABLE IF NOT EXISTS community_levels (
  public_id TEXT PRIMARY KEY,
  creator_id TEXT NOT NULL,
  client_level_id TEXT NOT NULL,
  latest_revision INTEGER NOT NULL DEFAULT 0 CHECK (latest_revision >= 0),
  UNIQUE (creator_id, client_level_id)
);

CREATE TABLE IF NOT EXISTS community_level_revisions (
  public_id TEXT NOT NULL REFERENCES community_levels(public_id) ON DELETE CASCADE,
  revision INTEGER NOT NULL CHECK (revision > 0),
  published_at BIGINT NOT NULL,
  level JSONB NOT NULL,
  PRIMARY KEY (public_id, revision)
);

CREATE TABLE IF NOT EXISTS community_level_stats (
  public_id TEXT PRIMARY KEY REFERENCES community_levels(public_id) ON DELETE CASCADE,
  plays BIGINT NOT NULL DEFAULT 0 CHECK (plays >= 0),
  likes BIGINT NOT NULL DEFAULT 0 CHECK (likes >= 0),
  curated BOOLEAN NOT NULL DEFAULT FALSE,
  takedown BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS community_level_revisions_published_idx
  ON community_level_revisions (published_at DESC);
CREATE INDEX IF NOT EXISTS community_level_stats_feed_idx
  ON community_level_stats (takedown, curated, likes DESC, plays DESC);


CREATE TABLE IF NOT EXISTS community_level_likes (
  public_id TEXT NOT NULL REFERENCES community_levels(public_id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  created_at BIGINT NOT NULL,
  PRIMARY KEY (public_id, user_id)
);

CREATE TABLE IF NOT EXISTS community_level_reports (
  public_id TEXT NOT NULL REFERENCES community_levels(public_id) ON DELETE CASCADE,
  reporter_id TEXT NOT NULL,
  reason TEXT NOT NULL CHECK (char_length(reason) BETWEEN 1 AND 64),
  reported_at BIGINT NOT NULL,
  PRIMARY KEY (public_id, reporter_id)
);

CREATE INDEX IF NOT EXISTS community_level_reports_queue_idx
  ON community_level_reports (reported_at ASC, public_id);

COMMIT;
