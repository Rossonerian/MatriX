create extension if not exists pgcrypto;

create type public.subscription_status as enum ('trialing','active','past_due','paused','cancelled','expired');
create type public.plan_code as enum ('base','base_plus','pro','max');
create type public.inventory_transaction_type as enum ('receipt','issue','reservation','release','return','transfer_out','transfer_in','adjustment','consumption','damage','scrap','disposal','output_receipt');

create table public.organizations (
  id uuid primary key default gen_random_uuid(), name text not null, slug text not null unique, currency text not null default 'INR', created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create unique index one_active_organization on public.organizations ((true));

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade, organization_id uuid not null references public.organizations(id), full_name text not null default '', email text not null default '', status text not null default 'active' check (status in ('active','disabled','suspended')), force_password_change boolean not null default false, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.roles (id uuid primary key default gen_random_uuid(), name text not null unique, description text not null default '');
create table public.permissions (id uuid primary key default gen_random_uuid(), key text not null unique, description text not null default '');
create table public.role_permissions (role_id uuid not null references public.roles(id) on delete cascade, permission_id uuid not null references public.permissions(id) on delete cascade, primary key(role_id, permission_id));
create table public.user_roles (user_id uuid not null references public.profiles(id) on delete cascade, role_id uuid not null references public.roles(id) on delete cascade, scope_type text not null default 'organization', scope_id uuid not null default '00000000-0000-0000-0000-000000000000', primary key(user_id, role_id, scope_type, scope_id));

create table public.plans (id uuid primary key default gen_random_uuid(), code public.plan_code not null unique, name text not null, monthly_price numeric(14,2) not null default 0, created_at timestamptz not null default now());
create table public.plan_features (plan_id uuid not null references public.plans(id) on delete cascade, feature_key text not null, enabled boolean not null default true, numeric_limit integer, primary key(plan_id, feature_key));
create table public.organization_subscriptions (organization_id uuid primary key references public.organizations(id) on delete cascade, plan_id uuid not null references public.plans(id), status public.subscription_status not null default 'trialing', trial_ends_at timestamptz, current_period_start timestamptz, current_period_end timestamptz, renewal_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table public.usage_counters (organization_id uuid not null references public.organizations(id) on delete cascade, feature_key text not null, period_start date not null, used_value integer not null default 0, primary key(organization_id, feature_key, period_start));

create table public.projects (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), code text not null, name text not null, client_name text not null default '', manager_id uuid references public.profiles(id), site text not null default '', status text not null default 'draft', budget numeric(14,2) not null default 0, spent numeric(14,2) not null default 0, progress numeric(5,2) not null default 0 check(progress between 0 and 100), start_date date, end_date date, created_at timestamptz not null default now(), unique(organization_id, code));
create table public.sites (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), project_id uuid references public.projects(id), name text not null, code text not null, created_at timestamptz not null default now());
create table public.work_packages (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), project_id uuid references public.projects(id), code text not null, name text not null, created_at timestamptz not null default now());
create table public.material_requests (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), project_id uuid references public.projects(id), site_id uuid references public.sites(id), requester_id uuid references public.profiles(id), request_number text not null, priority text not null default 'normal', status text not null default 'pending_approval', required_date date, notes text, created_at timestamptz not null default now(), unique(organization_id, request_number));
create table public.material_request_lines (id uuid primary key default gen_random_uuid(), request_id uuid not null references public.material_requests(id) on delete cascade, item_id uuid, quantity numeric(14,3) not null check(quantity > 0), unit text not null, estimated_value numeric(14,2) not null default 0);

create table public.items (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), sku text not null, name text not null, category text not null, unit text not null, reorder_level numeric(14,3) not null default 0, safety_stock numeric(14,3) not null default 0, lead_time_days integer not null default 0, barcode text, created_at timestamptz not null default now(), unique(organization_id, sku));
create table public.warehouses (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), code text not null, name text not null, site_id uuid references public.sites(id), created_at timestamptz not null default now(), unique(organization_id, code));
create table public.locations (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), warehouse_id uuid not null references public.warehouses(id), code text not null, name text not null, created_at timestamptz not null default now(), unique(warehouse_id, code));
create table public.inventory_balances (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), item_id uuid not null references public.items(id), warehouse_id uuid not null references public.warehouses(id), location_id uuid references public.locations(id), on_hand numeric(14,3) not null default 0, reserved numeric(14,3) not null default 0, average_cost numeric(14,2) not null default 0, updated_at timestamptz not null default now(), unique(item_id, warehouse_id, location_id));
create table public.inventory_transactions (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), item_id uuid not null references public.items(id), warehouse_id uuid references public.warehouses(id), location_id uuid references public.locations(id), transaction_type public.inventory_transaction_type not null, quantity numeric(14,3) not null check(quantity <> 0), unit_cost numeric(14,2) not null default 0, reference_type text, reference_id uuid, idempotency_key text, metadata jsonb not null default '{}'::jsonb, actor_id uuid references public.profiles(id), created_at timestamptz not null default now(), unique(organization_id, idempotency_key));
create table public.cycle_counts (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), warehouse_id uuid references public.warehouses(id), status text not null default 'open', counted_by uuid references public.profiles(id), approved_by uuid references public.profiles(id), created_at timestamptz not null default now());

create table public.waste_records (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), project_id uuid references public.projects(id), site_id uuid references public.sites(id), work_package_id uuid references public.work_packages(id), item_id uuid references public.items(id), source_stage text not null, category text not null default 'non-hazardous', reason_code text not null default 'unplanned', quantity numeric(14,3) not null check(quantity > 0), unit text not null, estimated_cost numeric(14,2) not null default 0, disposition text not null, responsible_party text, status text not null default 'pending_approval', notes text, created_by uuid references public.profiles(id), created_at timestamptz not null default now());
create table public.waste_approvals (id uuid primary key default gen_random_uuid(), waste_id uuid not null references public.waste_records(id) on delete cascade, actor_id uuid references public.profiles(id), decision text not null, note text, created_at timestamptz not null default now());

create table public.suppliers (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), name text not null, category text not null, tax_identifier text, payment_terms text, lead_time_days integer, risk_status text not null default 'normal', created_at timestamptz not null default now());
create table public.purchase_requisitions (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), project_id uuid references public.projects(id), requester_id uuid references public.profiles(id), status text not null default 'draft', approval_limit numeric(14,2), estimated_value numeric(14,2) not null default 0, created_at timestamptz not null default now());
create table public.purchase_orders (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), supplier_id uuid references public.suppliers(id), requisition_id uuid references public.purchase_requisitions(id), po_number text not null, status text not null default 'draft', total_value numeric(14,2) not null default 0, created_at timestamptz not null default now(), unique(organization_id, po_number));
create table public.grns (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), purchase_order_id uuid references public.purchase_orders(id), grn_number text not null, accepted_value numeric(14,2) not null default 0, rejected_value numeric(14,2) not null default 0, status text not null default 'draft', created_at timestamptz not null default now());

create table public.factories (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), name text not null, code text not null, created_at timestamptz not null default now());
create table public.products (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), sku text not null, name text not null, unit text not null, created_at timestamptz not null default now());
create table public.boms (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), product_id uuid not null references public.products(id), version text not null, status text not null default 'draft', effective_from date, created_at timestamptz not null default now());
create table public.bom_lines (id uuid primary key default gen_random_uuid(), bom_id uuid not null references public.boms(id) on delete cascade, item_id uuid not null references public.items(id), quantity numeric(14,3) not null, unit text not null, scrap_factor numeric(6,3) not null default 0);
create table public.manufacturing_orders (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), product_id uuid references public.products(id), bom_id uuid references public.boms(id), order_number text not null, quantity numeric(14,3) not null, completed_quantity numeric(14,3) not null default 0, status text not null default 'draft', due_date date, created_at timestamptz not null default now(), unique(organization_id, order_number));

create table public.audit_logs (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), actor_id uuid references public.profiles(id), action text not null, entity_type text not null, entity_id uuid, before_summary jsonb, after_summary jsonb, ip_address inet, user_agent text, correlation_id text, created_at timestamptz not null default now());
create table public.notifications (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), user_id uuid references public.profiles(id), title text not null, body text not null, read_at timestamptz, created_at timestamptz not null default now());
create table public.upgrade_requests (id uuid primary key default gen_random_uuid(), organization_id uuid not null references public.organizations(id), requested_plan public.plan_code not null, note text, status text not null default 'open', created_by uuid references public.profiles(id), created_at timestamptz not null default now());

create or replace function public.is_org_member(target_org uuid) returns boolean language sql stable security definer set search_path = public as $$ select exists(select 1 from public.profiles where id = auth.uid() and organization_id = target_org and status = 'active'); $$;
create or replace function public.has_permission(permission_key text, target_org uuid) returns boolean language sql stable security definer set search_path = public as $$ select exists(select 1 from public.profiles p join public.user_roles ur on ur.user_id=p.id join public.role_permissions rp on rp.role_id=ur.role_id join public.permissions pe on pe.id=rp.permission_id where p.id=auth.uid() and p.organization_id=target_org and p.status='active' and pe.key=permission_key); $$;

alter table public.organizations enable row level security;
alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.sites enable row level security;
alter table public.work_packages enable row level security;
alter table public.material_requests enable row level security;
alter table public.material_request_lines enable row level security;
alter table public.items enable row level security;
alter table public.warehouses enable row level security;
alter table public.locations enable row level security;
alter table public.inventory_balances enable row level security;
alter table public.inventory_transactions enable row level security;
alter table public.waste_records enable row level security;
alter table public.waste_approvals enable row level security;
alter table public.suppliers enable row level security;
alter table public.purchase_requisitions enable row level security;
alter table public.purchase_orders enable row level security;
alter table public.grns enable row level security;
alter table public.factories enable row level security;
alter table public.products enable row level security;
alter table public.boms enable row level security;
alter table public.bom_lines enable row level security;
alter table public.manufacturing_orders enable row level security;
alter table public.audit_logs enable row level security;
alter table public.notifications enable row level security;
alter table public.upgrade_requests enable row level security;

create policy org_member_select on public.organizations for select using (public.is_org_member(id));
do $$ declare table_name text; begin foreach table_name in array array['profiles','projects','sites','work_packages','material_requests','items','warehouses','locations','inventory_balances','inventory_transactions','waste_records','suppliers','purchase_requisitions','purchase_orders','grns','factories','products','boms','manufacturing_orders','audit_logs','notifications','upgrade_requests'] loop execute format('create policy %I on public.%I for all using (public.is_org_member(organization_id)) with check (public.is_org_member(organization_id));', 'org_member_' || table_name, table_name); end loop; end $$;
create policy request_lines_member on public.material_request_lines for all using (exists(select 1 from public.material_requests r where r.id=request_id and public.is_org_member(r.organization_id))) with check (exists(select 1 from public.material_requests r where r.id=request_id and public.is_org_member(r.organization_id)));
create policy waste_approvals_member on public.waste_approvals for all using (exists(select 1 from public.waste_records w where w.id=waste_id and public.is_org_member(w.organization_id))) with check (exists(select 1 from public.waste_records w where w.id=waste_id and public.is_org_member(w.organization_id)));
create policy bom_lines_member on public.bom_lines for all using (exists(select 1 from public.boms b where b.id=bom_id and public.is_org_member(b.organization_id))) with check (exists(select 1 from public.boms b where b.id=bom_id and public.is_org_member(b.organization_id)));

create index projects_org_status_idx on public.projects(organization_id, status);
create index inventory_tx_org_item_idx on public.inventory_transactions(organization_id, item_id, created_at desc);
create index audit_org_created_idx on public.audit_logs(organization_id, created_at desc);

create or replace function public.post_inventory_transaction(p_org uuid, p_item uuid, p_warehouse uuid, p_location uuid, p_type public.inventory_transaction_type, p_quantity numeric, p_unit_cost numeric, p_idempotency text, p_reference_type text default null, p_reference_id uuid default null, p_metadata jsonb default '{}'::jsonb) returns uuid language plpgsql security definer set search_path = public as $$ declare transaction_id uuid; begin if not public.is_org_member(p_org) then raise exception 'FORBIDDEN'; end if; if p_quantity = 0 then raise exception 'INVALID_QUANTITY'; end if; insert into public.inventory_transactions(organization_id,item_id,warehouse_id,location_id,transaction_type,quantity,unit_cost,idempotency_key,reference_type,reference_id,metadata,actor_id) values(p_org,p_item,p_warehouse,p_location,p_type,p_quantity,p_unit_cost,p_idempotency,p_reference_type,p_reference_id,p_metadata,auth.uid()) on conflict (organization_id,idempotency_key) do nothing returning id into transaction_id; if transaction_id is null then select id into transaction_id from public.inventory_transactions where organization_id=p_org and idempotency_key=p_idempotency; return transaction_id; end if; insert into public.audit_logs(organization_id,actor_id,action,entity_type,entity_id,after_summary) values(p_org,auth.uid(),'inventory.transaction.posted','inventory_transaction',transaction_id,jsonb_build_object('type',p_type,'quantity',p_quantity,'item_id',p_item)); return transaction_id; end; $$;
