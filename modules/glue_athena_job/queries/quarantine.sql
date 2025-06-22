SELECT *
FROM user_events
WHERE
  user_id IS NULL
  OR event_type IS NULL
  OR event_time IS NULL
  OR event_type NOT IN ('login', 'click', 'logout')
