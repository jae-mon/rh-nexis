-- 1. All participants with submission count
CREATE VIEW participant_overview AS
SELECT p.full_name, p.email, COUNT(s.id) as submissions, AVG(e.score) as avg_score
FROM participants p
LEFT JOIN submissions s ON p.id = s.participant_id
LEFT JOIN evaluations e ON s.id = e.submission_id
GROUP BY p.id, p.full_name, p.email;


-- 2. Pending submissions for judges
CREATE VIEW pending_submissions AS
SELECT * FROM submissions WHERE status = 'pending' ORDER BY submitted_at DESC;


-- View 3: Top scorers (participants ranked by average score)
CREATE OR REPLACE VIEW top_scorers AS
SELECT 
    p.id AS participant_id,
    p.full_name,
    p.email,
    COUNT(e.id) AS evaluations_received,
    ROUND(AVG(e.score)::numeric, 1) AS average_score,
    MAX(e.score) AS best_score,
    MIN(e.score) AS worst_score
FROM participants p
LEFT JOIN submissions s ON p.id = s.participant_id
LEFT JOIN evaluations e ON s.id = e.submission_id
WHERE e.score IS NOT NULL
GROUP BY p.id, p.full_name, p.email
HAVING COUNT(e.id) > 0
ORDER BY average_score DESC
LIMIT 10;


-- View 4: Stage progress summary (how many participants per stage + status distribution)
CREATE OR REPLACE VIEW stage_progress_summary AS
SELECT 
    st.stage_name,
    st.status AS stage_status,
    COUNT(pp.id) AS total_participants_in_stage,
    COUNT(CASE WHEN pp.progress_status = 'completed' THEN 1 END) AS completed,
    COUNT(CASE WHEN pp.progress_status = 'in_progress' THEN 1 END) AS in_progress,
    COUNT(CASE WHEN pp.progress_status = 'not_started' THEN 1 END) AS not_started
FROM stages st
LEFT JOIN participant_progress pp ON st.id = pp.stage_id
GROUP BY st.id, st.stage_name, st.status
ORDER BY st.id;


-- View 5: Judge workload (number of evaluations done + average score given)
CREATE OR REPLACE VIEW judge_workload AS
SELECT 
    j.id AS judge_id,
    j.full_name,
    j.expertise,
    COUNT(e.id) AS evaluations_completed,
    ROUND(AVG(e.score)::numeric, 1) AS average_score_given,
    MIN(e.evaluated_at) AS first_evaluation,
    MAX(e.evaluated_at) AS last_evaluation
FROM judges j
LEFT JOIN evaluations e ON j.id = e.judge_id
GROUP BY j.id, j.full_name, j.expertise
ORDER BY evaluations_completed DESC;


-- View 6: Recent audit logs (last 20 actions – good for integrity checking)
CREATE OR REPLACE VIEW recent_audit_logs AS
SELECT 
    performed_at,
    action,
    table_name,
    record_id,
    performed_by,
    details
FROM audit_logs
ORDER BY performed_at DESC
LIMIT 20;


-- View 7: Participant full profile (one row per participant with key stats)
CREATE OR REPLACE VIEW participant_full_profile AS
SELECT 
    p.id,
    p.full_name,
    p.email,
    p.phone,
    p.country,
    p.registration_date,
    p.status,
    COUNT(DISTINCT s.id) AS total_submissions,
    COUNT(DISTINCT e.id) AS total_evaluations_received,
    ROUND(AVG(e.score)::numeric, 1) AS overall_average_score,
    STRING_AGG(DISTINCT st.stage_name, ', ') AS stages_participated
FROM participants p
LEFT JOIN submissions s ON p.id = s.participant_id
LEFT JOIN evaluations e ON s.id = e.submission_id
LEFT JOIN stages st ON s.stage_id = st.id
GROUP BY p.id, p.full_name, p.email, p.phone, p.country, p.registration_date, p.status;


-- View 8: Unread notifications per participant (useful for support/admin dashboard)
CREATE OR REPLACE VIEW unread_notifications AS
SELECT 
    n.id AS notification_id,
    p.full_name AS participant_name,
    p.email,
    n.message,
    n.sent_at,
    n.is_read
FROM notifications n
JOIN participants p ON n.participant_id = p.id
WHERE n.is_read = FALSE
ORDER BY n.sent_at DESC;


-- Query 9: Simple SELECT – Latest 10 submissions (chronological)
SELECT 
    s.id,
    s.submission_url,
    s.submitted_at,
    s.status,
    p.full_name AS participant,
    st.stage_name
FROM submissions s
JOIN participants p ON s.participant_id = p.id
JOIN stages st ON s.stage_id = st.id
ORDER BY s.submitted_at DESC
LIMIT 10;


-- Query 10: Simple SELECT – Evaluations waiting for feedback (no feedback yet)
SELECT 
    e.id AS evaluation_id,
    s.submission_url,
    j.full_name AS judge_name,
    e.score,
    e.feedback IS NULL AS needs_feedback,
    e.evaluated_at
FROM evaluations e
JOIN submissions s ON e.submission_id = s.id
JOIN judges j ON e.judge_id = j.id
WHERE e.feedback IS NULL OR TRIM(e.feedback) = ''
ORDER BY e.evaluated_at DESC
LIMIT 15;
