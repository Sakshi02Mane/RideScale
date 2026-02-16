CREATE INDEX idx_time ON rides(time_stamp);

CLUSTER rides USING idx_time;
