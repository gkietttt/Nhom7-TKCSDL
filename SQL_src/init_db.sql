-- ============================================================================
-- MASTER INITIALIZATION SCRIPT: init_db.sql
-- Project: Platform Connecting Film Photography Community with Darkroom & Studio Services
-- Usage with sqlcmd:
--   sqlcmd -S localhost -U sa -P "YourPassword" -C -i init_db.sql
-- ============================================================================

:r 01_create_database.sql
:r 02_create_tables.sql
:r 03_create_constraints_and_indexes.sql
:r 04_create_triggers_and_procedures.sql
:r 05_seed_data.sql
