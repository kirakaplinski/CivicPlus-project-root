SELECT
  user_id,
  event_type,
  event_time,
  ROUND(
    (UNIX_TIMESTAMP(event_time) -
     UNIX_TIMESTAMP(LAG(event_time) OVER (PARTITION BY user_id ORDER BY event_time))
    ) / 60.0, 2
  ) AS lag_time_minutes
FROM user_events
WHERE
  user_id IS NOT NULL
  AND event_type IS NOT NULL
  AND event_time IS NOT NULL
  AND event_type IN ('login', 'click', 'logout')
