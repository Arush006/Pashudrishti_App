-- 🐄 PashuDrishti AI Database Schema
-- Tables for storing AI predictions and model information

-- ==========================================
-- AI PREDICTIONS TABLE
-- ==========================================
CREATE TABLE IF NOT EXISTS ai_predictions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    case_id INT,
    animal_type VARCHAR(50),
    primary_disease VARCHAR(100) NOT NULL,
    confidence DECIMAL(5, 2) NOT NULL,
    all_predictions JSON,
    symptoms JSON,
    image_path VARCHAR(255),
    image_url VARCHAR(500),
    veterinarian_notes TEXT,
    confirmed_diagnosis VARCHAR(100),
    confirmed_by INT,
    is_verified BOOLEAN DEFAULT FALSE,
    treatment_status ENUM('pending', 'in_progress', 'completed', 'failed') DEFAULT 'pending',
    treatment_details JSON,
    outcome VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (case_id) REFERENCES cases(id) ON DELETE SET NULL,
    FOREIGN KEY (confirmed_by) REFERENCES users(id) ON DELETE SET NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_disease (primary_disease),
    INDEX idx_created_at (created_at),
    INDEX idx_verified (is_verified),
    FULLTEXT INDEX ft_disease (primary_disease)
);

-- ==========================================
-- MODEL PERFORMANCE TRACKING
-- ==========================================
CREATE TABLE IF NOT EXISTS model_performance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    model_version VARCHAR(50),
    total_predictions INT DEFAULT 0,
    correct_predictions INT DEFAULT 0,
    accuracy DECIMAL(5, 2),
    precision JSON,
    recall JSON,
    f1_score JSON,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_model_version (model_version)
);

-- ==========================================
-- DISEASE INFORMATION
-- ==========================================
CREATE TABLE IF NOT EXISTS disease_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    disease_name VARCHAR(100) UNIQUE NOT NULL,
    hindi_name VARCHAR(100),
    urdu_name VARCHAR(100),
    description TEXT,
    symptoms JSON,
    causes JSON,
    treatment_options JSON,
    prevention_measures JSON,
    estimated_duration VARCHAR(50),
    severity ENUM('mild', 'moderate', 'severe', 'critical') DEFAULT 'moderate',
    contagious BOOLEAN DEFAULT FALSE,
    mortality_rate DECIMAL(5, 2),
    vaccination_available BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_severity (severity),
    FULLTEXT INDEX ft_disease_name (disease_name)
);

-- ==========================================
-- PREDICTION FEEDBACK
-- ==========================================
CREATE TABLE IF NOT EXISTS prediction_feedback (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prediction_id INT NOT NULL,
    user_id INT NOT NULL,
    actual_disease VARCHAR(100),
    was_correct BOOLEAN,
    feedback_text TEXT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (prediction_id) REFERENCES ai_predictions(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    INDEX idx_prediction_id (prediction_id),
    INDEX idx_was_correct (was_correct)
);

-- ==========================================
-- IMAGE CLASSIFICATION LOGS
-- ==========================================
CREATE TABLE IF NOT EXISTS ai_image_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    image_name VARCHAR(255),
    image_size INT,
    image_dimensions VARCHAR(20),
    file_format VARCHAR(10),
    processing_time_ms INT,
    memory_used_mb DECIMAL(8, 2),
    model_version VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_model_version (model_version),
    INDEX idx_created_at (created_at)
);



-- ==========================================
-- INDEXES FOR PERFORMANCE
-- ==========================================

CREATE INDEX idx_ai_pred_disease_confidence 
ON ai_predictions(primary_disease, confidence DESC);

CREATE INDEX idx_ai_pred_user_date 
ON ai_predictions(user_id, created_at DESC);

CREATE INDEX idx_ai_pred_verified_outcome 
ON ai_predictions(is_verified, outcome);
