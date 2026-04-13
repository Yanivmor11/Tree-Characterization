-- Force PostgREST to refresh schema cache immediately after migration rollout.
notify pgrst, 'reload schema';
