-- V14 – Eliminazione atomica e protetta di un'attività After Sales Assistant.
-- Eseguire UNA SOLA VOLTA nel SQL Editor del progetto Supabase after-sales-assistant.
-- La funzione verifica l'UID autorizzato, elimina gli eventi collegati,
-- scollega (senza cancellarli) gli appunti e cancella l'attività.
-- Tutte le operazioni fanno parte della stessa transazione.
CREATE OR REPLACE FUNCTION public.delete_after_sales_activity(p_activity_id text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF auth.uid() IS DISTINCT FROM '2e461df2-8341-45ef-b322-652272129c1f'::uuid THEN
    RAISE EXCEPTION 'Utente non autorizzato';
  END IF;
  IF p_activity_id IS NULL OR length(trim(p_activity_id)) = 0 THEN
    RAISE EXCEPTION 'ID attività mancante';
  END IF;
  PERFORM 1 FROM public.activities WHERE id = p_activity_id FOR UPDATE;
  IF NOT FOUND THEN RETURN false; END IF;
  DELETE FROM public.activity_events WHERE activity_id = p_activity_id;
  UPDATE public.quick_notes SET activity_id = NULL WHERE activity_id = p_activity_id;
  DELETE FROM public.activities WHERE id = p_activity_id;
  RETURN FOUND;
END;
$$;
REVOKE ALL ON FUNCTION public.delete_after_sales_activity(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_after_sales_activity(text) TO authenticated;
