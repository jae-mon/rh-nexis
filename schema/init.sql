-- 1. Participants
CREATE TABLE participants (
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(50),
  country VARCHAR(100) DEFAULT 'Nigeria',
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) DEFAULT 'active'
);

-- 2. Judges
CREATE TABLE judges (
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  expertise TEXT,
  joined_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Stages
CREATE TABLE stages (
  id SERIAL PRIMARY KEY,
  stage_name VARCHAR(100) NOT NULL,
  description TEXT,
  start_date DATE,
  end_date DATE,
  status VARCHAR(20) DEFAULT 'upcoming'
);

-- 4. Submissions
CREATE TABLE submissions (
  id SERIAL PRIMARY KEY,
  participant_id INTEGER REFERENCES participants(id) ON DELETE CASCADE,
  stage_id INTEGER REFERENCES stages(id) ON DELETE SET NULL,
  submission_url TEXT NOT NULL,
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) DEFAULT 'pending'
);

-- 5. Evaluations
CREATE TABLE evaluations (
  id SERIAL PRIMARY KEY,
  submission_id INTEGER REFERENCES submissions(id) ON DELETE CASCADE,
  judge_id INTEGER REFERENCES judges(id) ON DELETE SET NULL,
  score INTEGER CHECK (score >= 0 AND score <= 100),
  feedback TEXT,
  evaluated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Participant Progress (tracks stage-by-stage)
CREATE TABLE participant_progress (
  id SERIAL PRIMARY KEY,
  participant_id INTEGER REFERENCES participants(id) ON DELETE CASCADE,
  stage_id INTEGER REFERENCES stages(id) ON DELETE CASCADE,
  progress_status VARCHAR(20) DEFAULT 'not_started',
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(participant_id, stage_id)
);

-- 7. Audit Logs (for integrity)
CREATE TABLE audit_logs (
  id SERIAL PRIMARY KEY,
  table_name VARCHAR(50) NOT NULL,
  record_id INTEGER NOT NULL,
  action VARCHAR(10) NOT NULL,
  performed_by VARCHAR(255),
  performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  details JSONB
);

-- 8. Notifications (realistic for Remote Hustle)
CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  participant_id INTEGER REFERENCES participants(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_read BOOLEAN DEFAULT FALSE
);
