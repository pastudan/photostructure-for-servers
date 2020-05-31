-- remove the rightHash and searchHash (which didn't improve asset aggregations):
CREATE TABLE "new_AssetFile" (
  id integer NOT NULL PRIMARY KEY,
  assetId integer NOT NULL,
  shown integer NOT NULL DEFAULT 0,
  uri varchar (2048) NOT NULL,
  mountpoint varchar (1024),
  mtime integer NOT NULL,
  fileSize integer NOT NULL,
  mimetype varchar (64) NOT NULL,
  sha varchar (64) NOT NULL,
  capturedAtLocal bigint NOT NULL,
  capturedAtOffset integer NULL,
  capturedAtPrecisionMs integer NULL,
  capturedAtSrc varchar (8) NOT NULL,
  focalLength varchar (16),
  aperture float,
  shutterSpeed varchar (16),
  iso integer,
  width integer,
  height integer,
  rotation integer,
  make varchar (16),
  model varchar (16),
  cameraId varchar (64),
  imageId varchar (64),
  lensId varchar (64),
  durationMs bigint,
  fps integer,
  geohash integer,
  meanHash varchar (64),
  mode0 integer,
  mode1 integer,
  mode2 integer,
  mode3 integer,
  mode4 integer,
  mode5 integer,
  mode6 integer,
  version integer NOT NULL DEFAULT 0,
  createdAt bigint NOT NULL,
  updatedAt bigint NOT NULL,
  updateCount integer NOT NULL DEFAULT 0,
  FOREIGN KEY(assetId) REFERENCES Asset(id)
);

INSERT INTO
  new_AssetFile
SELECT
  id,
  assetId,
  shown,
  uri,
  mountpoint,
  mtime,
  fileSize,
  mimetype,
  sha,
  capturedAtLocal,
  capturedAtOffset,
  capturedAtPrecisionMs,
  capturedAtSrc,
  focalLength,
  aperture,
  shutterSpeed,
  iso,
  width,
  height,
  rotation,
  make,
  model,
  cameraId,
  imageId,
  lensId,
  durationMs,
  fps,
  geohash,
  meanHash,
  mode0,
  mode1,
  mode2,
  mode3,
  mode4,
  mode5,
  mode6,
  version,
  createdAt,
  updatedAt,
  updateCount
FROM
  AssetFile;

-- Drop prior indexes:
DROP INDEX IF EXISTS assetfile_capturedAtLocal_idx;

DROP INDEX IF EXISTS assetfile_meanHash_idx;

DROP INDEX IF EXISTS assetfile_rightHash_idx;

DROP INDEX IF EXISTS assetfile_recent_idx;

DROP INDEX IF EXISTS assetfile_sha_idx;

DROP INDEX IF EXISTS assetfile_shown_udx;

DROP INDEX IF EXISTS assetfile_uri_udx;

DROP INDEX IF EXISTS assetfile_mode0_idx;

DROP INDEX IF EXISTS assetfile_mode1_idx;

DROP INDEX IF EXISTS assetfile_mode2_idx;

DROP INDEX IF EXISTS assetfile_mode3_idx;

-- Replace the old with the new:
ALTER TABLE
  AssetFile RENAME TO AssetFile_20200512;

ALTER TABLE
  new_AssetFile RENAME TO AssetFile;

-- Rebuild the indexes:
CREATE INDEX assetfile_capturedAtLocal_idx ON AssetFile (capturedAtLocal, capturedAtPrecisionMs);

CREATE INDEX assetfile_meanHash_idx ON AssetFile (meanHash)
WHERE
  meanHash <> NULL;

CREATE INDEX assetfile_recent_idx ON AssetFile (updatedAt, mountpoint);

CREATE INDEX assetfile_sha_idx ON AssetFile (sha);

CREATE UNIQUE INDEX assetfile_shown_udx ON AssetFile (assetId, shown)
WHERE
  shown = 1;

CREATE UNIQUE INDEX assetfile_uri_udx ON AssetFile (uri);

CREATE INDEX assetfile_mode0_idx ON AssetFile (mode0);

CREATE INDEX assetfile_mode1_idx ON AssetFile (mode1);

CREATE INDEX assetfile_mode2_idx ON AssetFile (mode2);

-- yay, everything worked. drop the old table:
DROP TABLE IF EXISTS AssetFile_20200512;