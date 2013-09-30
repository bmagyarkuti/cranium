CREATE RESOURCE QUEUE smart_insight WITH (ACTIVE_STATEMENTS=10, PRIORITY=MEDIUM);

CREATE ROLE cranium WITH RESOURCE QUEUE smart_insight LOGIN PASSWORD 'cranium';
COMMENT ON ROLE cranium IS 'Cranium test user';

CREATE DATABASE cranium WITH OWNER=cranium;
