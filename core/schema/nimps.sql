-- NIMPS Project Database Schema (Simplified)
-- Version: 2.1
-- NPL-compatible SQLite schema with JSON details for flexibility

-- Enable foreign keys
PRAGMA foreign_keys = ON;

-- Projects table
CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    slug TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    status TEXT DEFAULT 'discovery' CHECK(status IN ('discovery', 'analysis', 'persona', 'planning', 'architecture', 'creation', 'mockup', 'documentation', 'completed')),
    details JSON, -- {elevator_pitch, executive_summary, pitch_30s, pitch_2min, description, market: {tam, sam, som, trends}}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Business Analysis table (SWOT, Competition, Risks)
CREATE TABLE IF NOT EXISTS business_analysis (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    type TEXT CHECK(type IN ('swot_strength', 'swot_weakness', 'swot_opportunity', 'swot_threat', 'competitor', 'risk')),
    name TEXT NOT NULL,
    category TEXT, -- For risks: Technical/Market/Financial/Legal/Operational
    priority TEXT CHECK(priority IN ('low', 'medium', 'high', 'critical')),
    details JSON, -- Flexible structure per type
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Revenue & Marketing table
CREATE TABLE IF NOT EXISTS go_to_market (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    type TEXT CHECK(type IN ('revenue_model', 'pricing_tier', 'projection', 'marketing_channel', 'campaign')),
    name TEXT NOT NULL,
    period TEXT, -- For projections: M1, Q1, Y1, etc.
    metrics JSON, -- {mrr, arr, cac, ltv, conversion, budget, etc.}
    details JSON, -- Additional flexible data
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Mockups & Design table
CREATE TABLE IF NOT EXISTS designs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    type TEXT CHECK(type IN ('wireframe', 'mockup', 'prototype', 'component', 'style_token')),
    name TEXT NOT NULL,
    format TEXT CHECK(format IN ('svg', 'html', 'react', 'figma', 'css', 'json')),
    device TEXT CHECK(device IN ('desktop', 'tablet', 'mobile', 'responsive', 'na')),
    content TEXT, -- Actual SVG/HTML/CSS/JSX content
    file_path TEXT,
    details JSON, -- {screen, state, variants, tokens, etc.}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Style Guide table
CREATE TABLE IF NOT EXISTS style_guide (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    category TEXT CHECK(category IN ('brand', 'color', 'typography', 'spacing', 'component', 'token')),
    name TEXT NOT NULL,
    value TEXT, -- CSS value, hex code, font name, etc.
    details JSON, -- {variants, states, usage, examples}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Personas table
CREATE TABLE IF NOT EXISTS personas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    age INTEGER,
    journey_stage TEXT CHECK(journey_stage IN ('awareness', 'consideration', 'evaluation', 'usage')),
    details JSON, -- All persona details: {visual, demographics, psychology, professional, behavior, context, impact}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Persona Relationships table
CREATE TABLE IF NOT EXISTS persona_relationships (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    persona_a_id INTEGER NOT NULL,
    persona_b_id INTEGER NOT NULL,
    relationship_type TEXT CHECK(relationship_type IN ('professional', 'personal', 'hierarchical', 'peer')),
    details JSON, -- {frequency, influence_direction, shared_contexts, conflict_areas, collaboration_opportunities}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (persona_a_id) REFERENCES personas(id) ON DELETE CASCADE,
    FOREIGN KEY (persona_b_id) REFERENCES personas(id) ON DELETE CASCADE
);

-- Competitors table
CREATE TABLE IF NOT EXISTS competitors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    details JSON, -- {strengths, weaknesses, market_position, differentiation_opportunity}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Epics table
CREATE TABLE IF NOT EXISTS epics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    epic_id TEXT UNIQUE NOT NULL, -- EP-001 format
    title TEXT NOT NULL,
    complexity TEXT CHECK(complexity IN ('low', 'medium', 'high')),
    status TEXT DEFAULT 'planned' CHECK(status IN ('planned', 'in_progress', 'completed', 'blocked')),
    details JSON, -- {theme, personas_impacted, business_value, dependencies, success_criteria, timeline, risk_factors}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- User Stories table
CREATE TABLE IF NOT EXISTS user_stories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    epic_id INTEGER,
    ticket TEXT UNIQUE NOT NULL, -- US-001 format
    title TEXT NOT NULL,
    priority TEXT CHECK(priority IN ('P0', 'P1', 'P2', 'P3')),
    points INTEGER,
    status TEXT DEFAULT 'backlog' CHECK(status IN ('backlog', 'planned', 'in_progress', 'testing', 'done', 'blocked')),
    narrative JSON, -- {user_type, context, want, outcome, emotion, goal}
    details JSON, -- {personas, background, user_goals, business_goals, tech_notes, ux_notes, dependencies, assumptions, questions}
    dod JSON, -- {code_complete, tested, accessible, performant, documented, approved}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (epic_id) REFERENCES epics(id) ON DELETE SET NULL
);

-- Acceptance Criteria table
CREATE TABLE IF NOT EXISTS acceptance_criteria (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    story_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    criteria JSON, -- {given, when, then, and}
    is_met BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (story_id) REFERENCES user_stories(id) ON DELETE CASCADE
);

-- Components table
CREATE TABLE IF NOT EXISTS components (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    type TEXT CHECK(type IN ('frontend', 'backend', 'database', 'integration', 'external')),
    status TEXT DEFAULT 'planned' CHECK(status IN ('planned', 'in_development', 'testing', 'deployed', 'deprecated')),
    details JSON, -- {purpose, tech, apis, performance, scale, interfaces, nfr, notes}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Component Dependencies table
CREATE TABLE IF NOT EXISTS component_dependencies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    component_id INTEGER NOT NULL,
    depends_on_id INTEGER NOT NULL,
    type TEXT CHECK(type IN ('upstream', 'downstream', 'external')),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (component_id) REFERENCES components(id) ON DELETE CASCADE,
    FOREIGN KEY (depends_on_id) REFERENCES components(id) ON DELETE CASCADE,
    UNIQUE(component_id, depends_on_id)
);

-- Assets table
CREATE TABLE IF NOT EXISTS assets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    type TEXT CHECK(type IN ('mockup', 'prototype', 'code', 'documentation', 'design', 'data', 'diagram')),
    status TEXT DEFAULT 'planned' CHECK(status IN ('planned', 'in_progress', 'completed', 'approved')),
    file_path TEXT,
    content TEXT, -- For storing actual content/code
    details JSON, -- {purpose, audience, format, method, dependencies, success_criteria}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Dependencies table (unified for all dependency types)
CREATE TABLE IF NOT EXISTS dependencies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    type TEXT CHECK(type IN ('team', 'vendor', 'compliance', 'integration', 'approval')),
    name TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'approved', 'active', 'blocked')),
    details JSON, -- Flexible structure for any dependency type
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Yield Points table (for tracking review cycles)
CREATE TABLE IF NOT EXISTS yield_points (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    phase TEXT NOT NULL,
    items_generated INTEGER DEFAULT 0,
    status TEXT CHECK(status IN ('pending', 'approved', 'modify', 'expand')),
    feedback TEXT,
    details JSON, -- Any additional context
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Diagrams table (for storing generated diagrams)
CREATE TABLE IF NOT EXISTS diagrams (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    type TEXT CHECK(type IN ('mermaid', 'plantuml', 'svg')),
    category TEXT CHECK(category IN ('persona', 'journey', 'epic', 'architecture', 'stack', 'data', 'flow')),
    content TEXT NOT NULL,
    file_path TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX idx_personas_project ON personas(project_id);
CREATE INDEX idx_epics_project ON epics(project_id);
CREATE INDEX idx_stories_project ON user_stories(project_id);
CREATE INDEX idx_stories_epic ON user_stories(epic_id);
CREATE INDEX idx_components_project ON components(project_id);
CREATE INDEX idx_assets_project ON assets(project_id);
CREATE INDEX idx_dependencies_project ON dependencies(project_id);
CREATE INDEX idx_diagrams_project ON diagrams(project_id);

-- JSON extraction indexes for common queries (SQLite 3.38.0+)
CREATE INDEX idx_epics_complexity ON epics(json_extract(details, '$.complexity'));
CREATE INDEX idx_stories_priority ON user_stories(priority);
CREATE INDEX idx_personas_journey ON personas(journey_stage);

-- Triggers to update timestamps
CREATE TRIGGER update_projects_timestamp 
AFTER UPDATE ON projects 
BEGIN
    UPDATE projects SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TRIGGER update_personas_timestamp 
AFTER UPDATE ON personas 
BEGIN
    UPDATE personas SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TRIGGER update_epics_timestamp 
AFTER UPDATE ON epics 
BEGIN
    UPDATE epics SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TRIGGER update_stories_timestamp 
AFTER UPDATE ON user_stories 
BEGIN
    UPDATE user_stories SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TRIGGER update_components_timestamp 
AFTER UPDATE ON components 
BEGIN
    UPDATE components SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TRIGGER update_assets_timestamp 
AFTER UPDATE ON assets 
BEGIN
    UPDATE assets SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TRIGGER update_diagrams_timestamp 
AFTER UPDATE ON diagrams 
BEGIN
    UPDATE diagrams SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;