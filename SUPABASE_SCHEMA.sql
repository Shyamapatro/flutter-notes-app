-- RUN THIS IN SUPABASE SQL EDITOR

-- 1. Create Notes Table
create table public.notes (
  id uuid primary key,
  title text,
  content text,
  is_pinned boolean default false,
  is_archived boolean default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  user_id uuid default auth.uid() -- Optional: Link to Auth User
);

-- 2. Enable Row Level Security (RLS)
alter table public.notes enable row level security;

-- 3. Create Policy (Allow All - For Dev Only)
-- WARN: In production, you want to restrict this to "auth.uid() = user_id"
create policy "Enable all access for all users"
on public.notes
for all
using (true)
with check (true);
