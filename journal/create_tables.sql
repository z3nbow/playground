--
--  Table for events
--
CREATE TABLE events(
    id          INTEGER PRIMARY KEY,
    date        TEXT,
    title       TEXT,
    time        TEXT DEFAULT NULL,
    text        TEXT DEFAULT NULL,
    end_date    TEXT DEFAULT NULL,
    end_time    TEXT DEFAULT NULL,
    type        INTEGER DEFAULT 0
);

--
--  Table for tasks
--
CREATE TABLE tasks(
    id          INTEGER PRIMARY KEY,
    parent_id   INTEGER DEFAULT NULL,
    title       TEXT,
    text        TEXT DEFAULT NULL,
    period      INTEGER DEFAULT 0,
    date        TEXT DEFAULT NULL,
    state       INTEGER DEFAULT 0
    type        INTEGER DEFAULT 0,
);
--  period
--  ------
--      0:      time-independent
--      1:      year
--      2:      month
--      3:      day
--      (more possible)
--  type
--  ----
--      0:      open
--      1:      done
--      (more possible, e.g. migrated, cancelled, etc.)
