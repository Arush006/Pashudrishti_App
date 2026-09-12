-- =============================================
-- 🔹 CREATE DISEASES TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS diseases (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  symptoms JSON,
  treatment TEXT,
  duration VARCHAR(50),
  cost VARCHAR(50),
  severity ENUM('low', 'medium', 'high') DEFAULT 'medium',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX(name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 🔹 CREATE PREDICTIONS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS predictions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  disease_id INT NOT NULL,
  confidence DECIMAL(5, 2) NOT NULL,
  image_url VARCHAR(255),
  treatment JSON,
  symptoms JSON,
  veterinarian_notes TEXT,
  follow_up_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (disease_id) REFERENCES diseases(id) ON DELETE CASCADE,
  INDEX(user_id),
  INDEX(disease_id),
  INDEX(created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 🔹 INSERT SAMPLE DISEASES DATA
-- =============================================
INSERT INTO diseases (name, description, symptoms, treatment, duration, cost, severity) VALUES
('Mastitis', 'Inflammation of udder/mammary gland', 
  JSON_ARRAY('Udder swelling', 'Milk discoloration', 'Fever', 'Reduced milk production'),
  'Antibiotics (Amoxicillin, Ampicillin), Supportive care',
  '7-14 days', '₹800-1500', 'high'),

('FMD', 'Foot and Mouth Disease - highly contagious',
  JSON_ARRAY('Blisters in mouth', 'Lameness', 'Fever', 'Drooling'),
  'Supportive care, Anti-inflammatory, Antiseptic dressing',
  '10-14 days', '₹1000-2000', 'high'),

('LSD', 'Lumpy Skin Disease - viral infection',
  JSON_ARRAY('Skin lesions', 'Lymph node enlargement', 'Fever', 'Reduced milk production'),
  'Supportive care, Antibiotics, Vaccinesecondary infections',
  '14-21 days', '₹1500-2500', 'high'),

('Lumpy', 'Lumpy Skin Disease (Alternate name)',
  JSON_ARRAY('Skin nodules', 'Fever', 'Lymph node swelling', 'Weight loss'),
  'Supportive care, Vaccination, Stress management',
  '21-30 days', '₹2000-3000', 'medium'),

('Pneumonia', 'Respiratory infection',
  JSON_ARRAY('Cough', 'Fever', 'Nasal discharge', 'Difficult breathing'),
  'Respiratory antibiotics, Rest, Nutritious feed',
  '5-7 days', '₹400-800', 'high'),

('Diarrhea', 'Gastrointestinal disorder',
  JSON_ARRAY('Loose stool', 'Weight loss', 'Dehydration', 'Reduced appetite'),
  'ORS (Oral Rehydration Solution), Probiotics, Dietary adjustment',
  '3-5 days', '₹300-500', 'medium'),

('Foot Rot', 'Bacterial foot infection',
  JSON_ARRAY('Limping', 'Foot odor', 'Swelling', 'Difficulty walking'),
  'Foot trimming, Antiseptic wash, Antibiotics',
  '7-10 days', '₹500-1000', 'medium'),

('Anemia', 'Low red blood cell count',
  JSON_ARRAY('Pale mucous membranes', 'Weakness', 'Poor appetite', 'Weight loss'),
  'Iron supplements, Nutritious feed, Blood transfusion if severe',
  '14-21 days', '₹1000-2000', 'medium');

-- =============================================
-- 🔹 CREATE DISEASE_TREATMENTS TABLE (Optional)
-- =============================================
CREATE TABLE IF NOT EXISTS disease_treatments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  disease_id INT NOT NULL,
  treatment_name VARCHAR(100),
  dosage VARCHAR(100),
  frequency VARCHAR(50),
  duration VARCHAR(50),
  cost_estimate VARCHAR(50),
  language ENUM('en', 'hi') DEFAULT 'en',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (disease_id) REFERENCES diseases(id) ON DELETE CASCADE,
  INDEX(disease_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 🔹 CREATE PREDICTION_HISTORY VIEW
-- =============================================
CREATE VIEW prediction_history_view AS
SELECT 
  p.id,
  p.user_id,
  u.email as user_email,
  d.name as disease_name,
  d.severity,
  p.confidence,
  p.image_url,
  p.created_at,
  DATEDIFF(NOW(), p.created_at) as days_ago
FROM predictions p
JOIN users u ON p.user_id = u.id
JOIN diseases d ON p.disease_id = d.id
ORDER BY p.created_at DESC;
