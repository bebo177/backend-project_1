-- ============================================================
-- BACKEND PROJECT - FULL MySQL SCHEMA
-- Run this file in your MySQL client to set up the database
-- ============================================================

CREATE DATABASE IF NOT EXISTS backend_project
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE backend_project;

-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  name        VARCHAR(100)     NOT NULL,
  email       VARCHAR(191)     NOT NULL,
  password    VARCHAR(255)     NULL COMMENT 'NULL for social-only accounts',
  provider    ENUM('local','google','facebook') NOT NULL DEFAULT 'local',
  provider_id VARCHAR(255)     NULL COMMENT 'OAuth provider user ID',
  avatar      VARCHAR(500)     NULL,
  is_active   TINYINT(1)       NOT NULL DEFAULT 1,
  created_at  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  INDEX idx_users_provider_id (provider, provider_id),
  INDEX idx_users_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLE: password_resets
-- ============================================================
CREATE TABLE IF NOT EXISTS password_resets (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  user_id     INT UNSIGNED  NOT NULL,
  token       VARCHAR(255)  NOT NULL,
  expires_at  TIMESTAMP     NOT NULL,
  used        TINYINT(1)    NOT NULL DEFAULT 0,
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_pr_token (token),
  INDEX idx_pr_user_id (user_id),
  INDEX idx_pr_expires_at (expires_at),

  CONSTRAINT fk_pr_user_id
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLE: chatbot_data
-- ============================================================
CREATE TABLE IF NOT EXISTS chatbot_data (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  question    TEXT          NOT NULL,
  answer      TEXT          NOT NULL,
  category    VARCHAR(100)  NULL,
  keywords    TEXT          NULL COMMENT 'Comma-separated keywords for matching',
  is_active   TINYINT(1)    NOT NULL DEFAULT 1,
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  FULLTEXT KEY ft_chatbot_question (question),
  FULLTEXT KEY ft_chatbot_answer (answer),
  FULLTEXT KEY ft_chatbot_keywords (keywords),
  INDEX idx_chatbot_category (category),
  INDEX idx_chatbot_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLE: chat_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS chat_logs (
  id           INT UNSIGNED       NOT NULL AUTO_INCREMENT,
  user_id      INT UNSIGNED       NULL COMMENT 'NULL for anonymous users',
  user_message TEXT               NOT NULL,
  bot_reply    TEXT               NOT NULL,
  confidence   DECIMAL(5,4)       NOT NULL DEFAULT 0.0000,
  matched_id   INT UNSIGNED       NULL COMMENT 'chatbot_data row that matched',
  ip_address   VARCHAR(45)        NULL,
  created_at   TIMESTAMP          NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_cl_user_id (user_id),
  INDEX idx_cl_created_at (created_at),
  INDEX idx_cl_confidence (confidence),

  CONSTRAINT fk_cl_user_id
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_cl_matched_id
    FOREIGN KEY (matched_id) REFERENCES chatbot_data (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- SAMPLE DATA: chatbot_data
-- Replace / extend with YOUR own dataset
-- ============================================================
INSERT INTO chatbot_data (question, answer, category, keywords) VALUES
[
  {
    "fault_id": "ABS_0001",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0002",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0003",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0004",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0005",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0006",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل",
      "RPM بيعوم"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0007",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي",
      "لمبة موتور"
    ],
    "ranking_score": 0.68,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.68,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0008",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل",
      "تأخير في الغيار"
    ],
    "ranking_score": 0.85,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.85,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0009",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس",
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.84,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.84,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0010",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية",
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0011",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0012",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه",
      "حرارة بتعلى"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0013",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور"
    ],
    "ranking_score": 0.91,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.91,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0014",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية",
      "العربية بتفصل"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0015",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0016",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0017",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.56,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.56,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0018",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش",
      "رعشة في الموتور"
    ],
    "ranking_score": 0.56,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.56,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0019",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف",
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0020",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0021",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.95,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.95,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0022",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل",
      "تأخير في الغيار"
    ],
    "ranking_score": 0.9,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.9,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0023",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0024",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0025",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0026",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى",
      "نقص مياه"
    ],
    "ranking_score": 0.85,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.85,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0027",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة",
      "العربية مش بتدور"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0028",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0029",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0030",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0031",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.64,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.64,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0032",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش"
    ],
    "ranking_score": 0.9,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.9,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0033",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية",
      "سحب ضعيف"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0034",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.55,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.55,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0035",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.55,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.55,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0036",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار",
      "نتشة في النقل"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0037",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش",
      "لمبة فتيس"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0038",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0039",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.9,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.9,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0040",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه",
      "حرارة بتعلى"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0041",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة",
      "العربية مش بتدور"
    ],
    "ranking_score": 0.9,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.9,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0042",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.71,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.71,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0043",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0044",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.67,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.67,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0045",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0046",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0047",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0048",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.64,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.64,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0049",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور",
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.64,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.64,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0050",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0051",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش",
      "لمبة فتيس"
    ],
    "ranking_score": 0.65,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.65,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0052",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0053",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.87,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.87,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0054",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى",
      "نقص مياه"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0055",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0056",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0057",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0058",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0059",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0060",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور",
      "العربية بتنتش"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0061",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0062",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0063",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0064",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار"
    ],
    "ranking_score": 0.81,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.81,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0065",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0066",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.71,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.71,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0067",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0068",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0069",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور",
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0070",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.81,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.81,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0071",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0072",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.87,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.87,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0073",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0074",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0075",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0076",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم",
      "العربية بتفصل"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0077",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0078",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0079",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.55,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.55,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0080",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0081",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0082",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0083",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0084",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0085",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.61,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.61,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0086",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0087",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0088",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور",
      "العربية بتنتش"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0089",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0090",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل",
      "RPM بيعوم"
    ],
    "ranking_score": 0.85,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.85,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0091",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي",
      "لمبة موتور"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0092",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل"
    ],
    "ranking_score": 0.71,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.71,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0093",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0094",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0095",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0096",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه",
      "حرارة بتعلى"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0097",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة",
      "العربية مش بتدور"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0098",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0099",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0100",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.64,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.64,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0101",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0102",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور",
      "العربية بتنتش"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0103",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0104",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل",
      "RPM بيعوم"
    ],
    "ranking_score": 0.67,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.67,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0105",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0106",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل",
      "تأخير في الغيار"
    ],
    "ranking_score": 0.68,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.68,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0107",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش",
      "لمبة فتيس"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0108",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0109",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0110",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0111",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة",
      "العربية مش بتدور"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0112",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0113",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0114",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.85,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.85,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0115",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.56,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.56,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0116",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش",
      "رعشة في الموتور"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0117",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف",
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0118",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0119",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0120",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار",
      "نتشة في النقل"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0121",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس",
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.87,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.87,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0122",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0123",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0124",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.65,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.65,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0125",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.56,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.56,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0126",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية",
      "العربية بتفصل"
    ],
    "ranking_score": 0.68,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.68,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0127",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0128",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الدواسة بترعش"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0129",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.68,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.68,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0130",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش",
      "رعشة في الموتور"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0131",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0132",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل",
      "RPM بيعوم"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0133",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي",
      "لمبة موتور"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0134",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار",
      "نتشة في النقل"
    ],
    "ranking_score": 0.55,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.55,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0135",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس",
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0136",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0137",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0138",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه",
      "حرارة بتعلى"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0139",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور",
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.64,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.64,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0140",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0141",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0142",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الدواسة بترعش"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0143",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.9,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.9,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0144",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور",
      "العربية بتنتش"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0145",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0146",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل",
      "RPM بيعوم"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0147",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور",
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0148",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار",
      "نتشة في النقل"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0149",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.61,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.61,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0150",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0151",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0152",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0153",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0154",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0155",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.61,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.61,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0156",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.84,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.84,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0157",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.78,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.78,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0158",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0159",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0160",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.56,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.56,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0161",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.64,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.64,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0162",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0163",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0164",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0165",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0166",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0167",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور",
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.65,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.65,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0168",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.9,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.9,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0169",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0170",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0171",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0172",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0173",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف",
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.61,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.61,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0174",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0175",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.55,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.55,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0176",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0177",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس"
    ],
    "ranking_score": 0.84,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.84,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0178",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.87,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.87,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0179",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0180",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0181",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور",
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0182",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0183",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0184",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الدواسة بترعش"
    ],
    "ranking_score": 0.84,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.84,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0185",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.71,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.71,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0186",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0187",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0188",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم",
      "العربية بتفصل"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0189",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور",
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0190",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0191",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0192",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0193",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0194",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0195",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة",
      "العربية مش بتدور"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0196",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0197",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0198",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0199",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0200",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0201",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف",
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0202",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم",
      "العربية بتفصل"
    ],
    "ranking_score": 0.87,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.87,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0203",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي",
      "لمبة موتور"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0204",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0205",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0206",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0207",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0208",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه",
      "حرارة بتعلى"
    ],
    "ranking_score": 0.65,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.65,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0209",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0210",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0211",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0212",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0213",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.91,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.91,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0214",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش",
      "رعشة في الموتور"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0215",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0216",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل",
      "RPM بيعوم"
    ],
    "ranking_score": 0.85,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.85,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0217",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0218",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار"
    ],
    "ranking_score": 0.71,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.71,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0219",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس",
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0220",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0221",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0222",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0223",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0224",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية",
      "العربية بتفصل"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0225",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0226",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0227",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0228",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش",
      "رعشة في الموتور"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0229",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف"
    ],
    "ranking_score": 0.91,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.91,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0230",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم",
      "العربية بتفصل"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0231",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور",
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0232",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل",
      "تأخير في الغيار"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0233",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0234",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.84,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.84,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0235",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.9,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.9,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0236",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى",
      "نقص مياه"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0237",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة",
      "العربية مش بتدور"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0238",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0239",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.68,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.68,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0240",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0241",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0242",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0243",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية",
      "سحب ضعيف"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0244",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم",
      "العربية بتفصل"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0245",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي",
      "لمبة موتور"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0246",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0247",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس",
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0248",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0249",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0250",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه"
    ],
    "ranking_score": 0.55,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.55,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0251",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0252",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية"
    ],
    "ranking_score": 0.71,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.71,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0253",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0254",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الدواسة بترعش"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0255",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0256",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور"
    ],
    "ranking_score": 0.78,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.78,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0257",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف",
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.64,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.64,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0258",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0259",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0260",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0261",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0262",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية",
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0263",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0264",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه",
      "حرارة بتعلى"
    ],
    "ranking_score": 0.84,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.84,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0265",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.68,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.68,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0266",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0267",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0268",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0269",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0270",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور",
      "العربية بتنتش"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0271",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف"
    ],
    "ranking_score": 0.65,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.65,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0272",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0273",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0274",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل",
      "تأخير في الغيار"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0275",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس",
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.82,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.82,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0276",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0277",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0278",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه",
      "حرارة بتعلى"
    ],
    "ranking_score": 0.84,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.84,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0279",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.82,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.82,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0280",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0281",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0282",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0283",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.87,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.87,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0284",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور",
      "العربية بتنتش"
    ],
    "ranking_score": 0.78,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.78,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0285",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0286",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل",
      "RPM بيعوم"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0287",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0288",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل",
      "تأخير في الغيار"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0289",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس",
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0290",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0291",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.64,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.64,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0292",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.82,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.82,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0293",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور",
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0294",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.61,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.61,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0295",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0296",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0297",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.91,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.91,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0298",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش",
      "رعشة في الموتور"
    ],
    "ranking_score": 0.55,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.55,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0299",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0300",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0301",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور",
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.81,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.81,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0302",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل",
      "تأخير في الغيار"
    ],
    "ranking_score": 0.68,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.68,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0303",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0304",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0305",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0306",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0307",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة",
      "العربية مش بتدور"
    ],
    "ranking_score": 0.67,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.67,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0308",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0309",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0310",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0311",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.68,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.68,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0312",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0313",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0314",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0315",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0316",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار",
      "نتشة في النقل"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0317",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس",
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0318",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0319",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0320",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى",
      "نقص مياه"
    ],
    "ranking_score": 0.82,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.82,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0321",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0322",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0323",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.78,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.78,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0324",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الدواسة بترعش"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0325",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0326",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور",
      "العربية بتنتش"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0327",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية",
      "سحب ضعيف"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0328",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.78,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.78,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0329",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0330",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار"
    ],
    "ranking_score": 0.61,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.61,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0331",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش",
      "لمبة فتيس"
    ],
    "ranking_score": 0.64,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.64,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0332",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0333",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0334",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0335",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور",
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0336",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية"
    ],
    "ranking_score": 0.71,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.71,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0337",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.78,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.78,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0338",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0339",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0340",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش",
      "رعشة في الموتور"
    ],
    "ranking_score": 0.81,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.81,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0341",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0342",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0343",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0344",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0345",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش",
      "لمبة فتيس"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0346",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0347",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0348",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه",
      "حرارة بتعلى"
    ],
    "ranking_score": 0.61,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.61,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0349",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة",
      "العربية مش بتدور"
    ],
    "ranking_score": 0.9,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.9,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0350",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0351",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.84,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.84,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0352",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.87,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.87,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0353",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0354",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور"
    ],
    "ranking_score": 0.58,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.58,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0355",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف"
    ],
    "ranking_score": 0.64,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.64,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0356",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم",
      "العربية بتفصل"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0357",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0358",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل",
      "تأخير في الغيار"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0359",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.82,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.82,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0360",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية"
    ],
    "ranking_score": 0.85,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.85,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0361",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0362",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.65,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.65,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0363",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0364",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية",
      "العربية بتفصل"
    ],
    "ranking_score": 0.9,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.9,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0365",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0366",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.67,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.67,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0367",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0368",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور",
      "العربية بتنتش"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0369",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0370",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0371",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0372",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0373",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش",
      "لمبة فتيس"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0374",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0375",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0376",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه",
      "حرارة بتعلى"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0377",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0378",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية",
      "العربية بتفصل"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0379",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.61,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.61,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0380",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الدواسة بترعش"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0381",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0382",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور"
    ],
    "ranking_score": 0.71,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.71,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0383",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0384",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0385",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.81,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.81,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0386",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0387",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش",
      "لمبة فتيس"
    ],
    "ranking_score": 0.67,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.67,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0388",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0389",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0390",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.85,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.85,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0391",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور",
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0392",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.78,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.78,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0393",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.57,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.57,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0394",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0395",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0396",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور",
      "العربية بتنتش"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0397",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف",
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0398",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.55,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.55,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0399",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي",
      "لمبة موتور"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0400",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل",
      "تأخير في الغيار"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0401",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0402",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0403",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.82,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.82,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0404",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى",
      "نقص مياه"
    ],
    "ranking_score": 0.65,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.65,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0405",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور",
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.85,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.85,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0406",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية",
      "العربية بتفصل"
    ],
    "ranking_score": 0.71,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.71,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0407",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0408",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0409",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0410",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور"
    ],
    "ranking_score": 0.56,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.56,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0411",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية",
      "سحب ضعيف"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0412",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.76,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.76,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0413",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0414",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "نتشة في النقل",
      "تأخير في الغيار"
    ],
    "ranking_score": 0.78,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.78,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0415",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش",
      "لمبة فتيس"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0416",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية",
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.84,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.84,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0417",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.61,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.61,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0418",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0419",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور",
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0420",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0421",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الفرامل بتفصل"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0422",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الدواسة بترعش"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0423",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0424",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش",
      "رعشة في الموتور"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0425",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية",
      "سحب ضعيف"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0426",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل",
      "RPM بيعوم"
    ],
    "ranking_score": 0.81,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.81,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0427",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.67,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.67,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0428",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار"
    ],
    "ranking_score": 0.67,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.67,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0429",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0430",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0431",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0432",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى",
      "نقص مياه"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0433",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0434",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.55,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.55,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0435",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0436",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0437",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0438",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور",
      "العربية بتنتش"
    ],
    "ranking_score": 0.78,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.78,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0439",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0440",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0441",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور",
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0442",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار",
      "نتشة في النقل"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0443",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش",
      "لمبة فتيس"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0444",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية",
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0445",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0446",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه",
      "حرارة بتعلى"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0447",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0448",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية",
      "العربية بتفصل"
    ],
    "ranking_score": 0.82,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.82,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0449",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0450",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0451",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0452",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور",
      "العربية بتنتش"
    ],
    "ranking_score": 0.68,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.68,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0453",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف",
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.67,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.67,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0454",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم",
      "العربية بتفصل"
    ],
    "ranking_score": 0.65,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.65,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0455",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي",
      "لمبة موتور"
    ],
    "ranking_score": 0.75,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.75,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0456",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار",
      "نتشة في النقل"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0457",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس",
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0458",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية"
    ],
    "ranking_score": 0.64,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.64,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0459",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0460",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.55,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.55,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0461",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة",
      "العربية مش بتدور"
    ],
    "ranking_score": 0.82,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.82,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0462",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية",
      "العربية بتفصل"
    ],
    "ranking_score": 0.7,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.7,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0463",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0464",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.59,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.59,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0465",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.81,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.81,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0466",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش",
      "رعشة في الموتور"
    ],
    "ranking_score": 0.67,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.67,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0467",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف",
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0468",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل",
      "RPM بيعوم"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0469",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور",
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0470",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار"
    ],
    "ranking_score": 0.77,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.77,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0471",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.66,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.66,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0472",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "حرارة عالية"
    ],
    "ranking_score": 0.93,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.93,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0473",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.85,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.85,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0474",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.85,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.85,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0475",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور",
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0476",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية"
    ],
    "ranking_score": 0.61,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.61,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0477",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "الفرامل بتفصل",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.68,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.68,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0478",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0479",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.62,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.62,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0480",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "رعشة في الموتور",
      "العربية بتنتش"
    ],
    "ranking_score": 0.8,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.8,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0481",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "صرفية بنزين عالية"
    ],
    "ranking_score": 0.81,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.81,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0482",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "العربية بتفصل"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0483",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.64,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.64,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0484",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار",
      "نتشة في النقل"
    ],
    "ranking_score": 0.85,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.85,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0485",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0486",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت"
    ],
    "ranking_score": 0.86,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.86,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0487",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0488",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه",
      "حرارة بتعلى"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0489",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور",
      "إضاءة ضعيفة"
    ],
    "ranking_score": 0.78,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.78,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0490",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية"
    ],
    "ranking_score": 0.83,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.83,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0491",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0492",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "لمبة ABS منورة",
      "الدواسة بترعش"
    ],
    "ranking_score": 0.84,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.84,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0493",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.78,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.78,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0494",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش",
      "رعشة في الموتور"
    ],
    "ranking_score": 0.82,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.82,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0495",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف"
    ],
    "ranking_score": 0.71,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.71,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0496",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.73,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.73,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0497",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "لمبة موتور",
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.72,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.72,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0498",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار"
    ],
    "ranking_score": 0.61,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.61,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0499",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "لمبة فتيس",
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0500",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.92,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.92,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0501",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.63,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.63,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0502",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "حرارة بتعلى"
    ],
    "ranking_score": 0.81,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.81,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0503",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "إضاءة ضعيفة",
      "العربية مش بتدور"
    ],
    "ranking_score": 0.67,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.67,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0504",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "العربية بتفصل",
      "لمبة بطارية"
    ],
    "ranking_score": 0.91,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.91,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0505",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0506",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.74,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.74,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0507",
    "system": "ABS",
    "fault": "ABS Wiring Issue",
    "user_symptoms": [
      "لمبة ABS بتنور وتطفي"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0508",
    "system": "Engine",
    "fault": "Misfire",
    "user_symptoms": [
      "العربية بتنتش"
    ],
    "ranking_score": 0.89,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.89,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0509",
    "system": "Engine",
    "fault": "MAF Sensor Fault",
    "user_symptoms": [
      "سحب ضعيف"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0510",
    "system": "Engine",
    "fault": "Throttle Body Dirty",
    "user_symptoms": [
      "RPM بيعوم"
    ],
    "ranking_score": 0.94,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.94,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ENGINE_0511",
    "system": "Engine",
    "fault": "Oxygen Sensor Fault",
    "user_symptoms": [
      "استهلاك بنزين عالي"
    ],
    "ranking_score": 0.88,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.88,
      "risk_level": "low",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0512",
    "system": "Transmission",
    "fault": "Low Transmission Fluid",
    "user_symptoms": [
      "تأخير في الغيار"
    ],
    "ranking_score": 0.69,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.69,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "TRANSMISSION_0513",
    "system": "Transmission",
    "fault": "Gearbox Sensor Fault",
    "user_symptoms": [
      "العربية مبتنقلش"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0514",
    "system": "Cooling",
    "fault": "Thermostat Stuck",
    "user_symptoms": [
      "مروحة شغالة طول الوقت",
      "حرارة عالية"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0515",
    "system": "Cooling",
    "fault": "Radiator Fan Failure",
    "user_symptoms": [
      "العربية بتسخن في الزحمة"
    ],
    "ranking_score": 0.61,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.61,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "COOLING_0516",
    "system": "Cooling",
    "fault": "Low Coolant Level",
    "user_symptoms": [
      "نقص مياه",
      "حرارة بتعلى"
    ],
    "ranking_score": 0.71,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.71,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0517",
    "system": "Electrical",
    "fault": "Battery Weak",
    "user_symptoms": [
      "العربية مش بتدور"
    ],
    "ranking_score": 0.71,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.71,
      "risk_level": "medium",
      "can_drive": "yes_with_caution",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ELECTRICAL_0518",
    "system": "Electrical",
    "fault": "Alternator Failure",
    "user_symptoms": [
      "لمبة بطارية"
    ],
    "ranking_score": 0.79,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.79,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0519",
    "system": "ABS",
    "fault": "Wheel Speed Sensor Failure",
    "user_symptoms": [
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.6,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.6,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  },
  {
    "fault_id": "ABS_0520",
    "system": "ABS",
    "fault": "ABS Control Module Failure",
    "user_symptoms": [
      "الدواسة بترعش",
      "لمبة ABS منورة"
    ],
    "ranking_score": 0.82,
    "questions": [
      {
        "id": "q1",
        "question": "المشكلة بتحصل باستمرار؟",
        "answers": {
          "أيوه": 0.15,
          "لا": -0.1,
          "مش عارف": 0.0
        }
      },
      {
        "id": "q2",
        "question": "المشكلة زادت مع الوقت؟",
        "answers": {
          "أيوه": 0.1,
          "لا": -0.05
        }
      }
    ],
    "final_diagnosis": {
      "base_confidence": 0.82,
      "risk_level": "high",
      "can_drive": "no",
      "recommended_fix": [
        "فحص ميكانيكي",
        "فحص كهرباء وحساسات"
      ]
    }
  }
]