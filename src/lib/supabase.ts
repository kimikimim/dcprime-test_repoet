import { createClient } from '@supabase/supabase-js';

// anon key는 RLS로 보호되는 공개 키라 커밋해도 안전 (dcprime-academy와 동일 프로젝트/키 공유)
const FALLBACK_SUPABASE_URL = 'https://smnakhjdtbqgwocwlluz.supabase.co';
const FALLBACK_SUPABASE_ANON_KEY =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmFraGpkdGJxZ3dvY3dsbHV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY4NDc2MDQsImV4cCI6MjA5MjQyMzYwNH0._jfUSWEVlMr8oapYLul33LRrhEnRJBSgppGNR1jshnA';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL || FALLBACK_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY || FALLBACK_SUPABASE_ANON_KEY;

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
});
