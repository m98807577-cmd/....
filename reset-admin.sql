-- รันได้ซ้ำหลายครั้งโดยไม่ error
create table if not exists users    (id text primary key, data jsonb not null, updated_at timestamptz default now() not null);
create table if not exists products (id text primary key, data jsonb not null, updated_at timestamptz default now() not null);
create table if not exists orders   (id text primary key, data jsonb not null, updated_at timestamptz default now() not null);
 
-- ส่งข้อมูลเดิมครบในอีเวนต์ลบ/แก้ไข
alter table users    replica identity full;
alter table products replica identity full;
alter table orders   replica identity full;
 
-- เปิด Realtime (ข้ามถ้าเพิ่มไว้แล้ว)
do $$
declare t text;
begin
  foreach t in array array['users','products','orders'] loop
    if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename=t) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;
 
-- อนุญาตให้ anon key อ่าน/เขียน/ลบได้ (ถ้าเปิด RLS ไว้) — ถ้าไม่ได้เปิด RLS ไม่ต้องใช้ส่วนนี้
alter table users    enable row level security;
alter table products enable row level security;
alter table orders   enable row level security;
drop policy if exists "open_all" on users;    create policy "open_all" on users    for all using (true) with check (true);
drop policy if exists "open_all" on products; create policy "open_all" on products for all using (true) with check (true);
drop policy if exists "open_all" on orders;   create policy "open_all" on orders   for all using (true) with check (true);
 
-- (ไม่บังคับ) ล้างสินค้าตัวอย่างเก่าทั้งหมดในคราวเดียว:
-- delete from products;
 