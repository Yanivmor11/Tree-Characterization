-- ============================================================================
-- PostgREST schema cache reload
-- ============================================================================
-- Notifies PostgREST to pick up new columns/policies without manual restart.
-- ============================================================================
notify pgrst, 'reload schema';
