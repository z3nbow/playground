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

CREATE TABLE tasks(
    id          INTEGER PRIMARY KEY,
    parent      INTEGER DEFAULT NULL,
    date        TEXT DEFAULT NULL,
    title       TEXT,
    text        TEXT DEFAULT NULL,
    state       INTEGER DEFAULT 0,
    type        INTEGER DEFAULT 0
);
-- type 0:      without date
-- type 1:      year
-- type 2:      month
-- type 3:      day






