-- Seed 4 stages first
INSERT INTO stages (stage_name, description, start_date, end_date, status) VALUES
('Stage 1: Onboarding', '...', '2026-03-01', '2026-03-07', 'ongoing'),
('Stage 2: Idea Submission', '...', '2026-03-08', '2026-03-14', 'upcoming'),
('Stage 3: MVP Build', '...', '2026-03-15', '2026-03-21', 'upcoming'),
('Stage 4: Final Pitch', '...', '2026-03-22', '2026-03-28', 'upcoming');

-- Seed 5 judges
INSERT INTO judges (full_name, email, expertise) VALUES
('Ada Obi', 'ada@remotehustle.com', 'UI/UX'),
('Chinedu Eze', 'chinedu@remotehustle.com', 'Backend'),
('Fatima Yusuf', 'fatima@remotehustle.com', 'Product'),
('Emeka Okoro', 'emeka@remotehustle.com', 'Marketing'),
('Aisha Bello', 'aisha@remotehustle.com', 'Growth');

-- 50 submissions (random participants + stages)
INSERT INTO submissions (participant_id, stage_id, submission_url, status)
SELECT 
  (SELECT id FROM participants ORDER BY RANDOM() LIMIT 1),
  (SELECT id FROM stages ORDER BY RANDOM() LIMIT 1),
  'https://example.com/submission/' || gs,
  'pending'
FROM generate_series(1,50) gs;

-- 20 evaluations
INSERT INTO evaluations (submission_id, judge_id, score, feedback)
SELECT 
  (SELECT id FROM submissions ORDER BY RANDOM() LIMIT 1),
  (SELECT id FROM judges ORDER BY RANDOM() LIMIT 1),
  FLOOR(RANDOM()*91)+10,   -- 10-100
  'Good work, needs more detail'
FROM generate_series(1,20) gs;

-- Fill progress and notifications (simple)
INSERT INTO participant_progress (participant_id, stage_id, progress_status)
SELECT id, 1, 'in_progress' FROM participants LIMIT 100;
