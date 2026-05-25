-- ============================================
-- SISTEMA DE GESTIÓN KIOSCO - Setup Supabase
-- Ejecutar en Supabase > SQL Editor
-- ============================================

-- Categorías
create table if not exists categorias (
  id serial primary key,
  nombre text not null unique,
  created_at timestamptz default now()
);

-- Proveedores
create table if not exists proveedores (
  id serial primary key,
  nombre text not null,
  contacto text,
  telefono text,
  rubro text,
  notas text,
  created_at timestamptz default now()
);

-- Productos
create table if not exists productos (
  id serial primary key,
  nombre text not null,
  categoria_id integer references categorias(id),
  proveedor_id integer references proveedores(id),
  precio numeric(12,2) not null default 0,
  stock numeric(12,2) not null default 0,
  stock_minimo numeric(12,2) not null default 5,
  por_peso boolean default false,
  activo boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Ventas (cabecera)
create table if not exists ventas (
  id serial primary key,
  total numeric(12,2) not null,
  descuento_tipo text, -- 'disc' | 'inc' | null
  descuento_valor numeric(5,2) default 0,
  medio_pago text not null,
  usuario text default 'operador',
  created_at timestamptz default now()
);

-- Detalle de ventas
create table if not exists venta_items (
  id serial primary key,
  venta_id integer references ventas(id) on delete cascade,
  producto_id integer references productos(id),
  nombre_snapshot text not null,
  precio_unitario numeric(12,2) not null,
  cantidad numeric(12,3) not null,
  total numeric(12,2) not null
);

-- Ingresos de mercadería
create table if not exists ingresos (
  id serial primary key,
  proveedor_id integer references proveedores(id),
  producto_id integer references productos(id),
  cantidad numeric(12,2) not null,
  costo_unitario numeric(12,2) default 0,
  notas text,
  fecha date not null default current_date,
  usuario text default 'operador',
  created_at timestamptz default now()
);

-- Usuarios del sistema
create table if not exists usuarios (
  id serial primary key,
  nombre text not null,
  pin text not null,
  rol text not null check (rol in ('admin','operador')),
  activo boolean default true,
  created_at timestamptz default now()
);

-- ============================================
-- DATOS INICIALES
-- ============================================

insert into categorias (nombre) values
  ('Bebidas'),('Golosinas'),('Galletitas'),('A granel'),
  ('Electrónica'),('Kiosco'),('Regalería')
on conflict do nothing;

insert into proveedores (nombre, contacto, telefono, rubro, notas) values
  ('CocaCola', '', '', 'Bebidas', ''),
  ('DonSatur', '', '', 'Galletitas, golosinas', ''),
  ('Arcor', '', '', '', ''),
  ('Pepsico', '', '', '', ''),
  ('Manaos', '', '', 'Bebidas', ''),
  ('ECR', '', '', 'Controles remotos', 'Proveedor principal de controles, mayor calidad'),
  ('Terrabusi', '', '', '', ''),
  ('Quilmes', '', '', 'Bebidas línea Pepsi', 'No trabajamos bebidas alcohólicas'),
  ('UniversoCR', 'Cristian', '1125596272', 'Controles remotos', 'Más económico que ECR'),
  ('Mayorista El Rey', '', '', 'Artículos de kiosco', 'Pegamentos, pilas Duracell, encendedores, etc.'),
  ('Bazar (Once)', '', '', 'Regalería', 'Proveedor del barrio de Once, CABA')
on conflict do nothing;

insert into usuarios (nombre, pin, rol) values
  ('Juan (Admin)', '1234', 'admin'),
  ('Operador', '0000', 'operador')
on conflict do nothing;

-- Productos de ejemplo
insert into productos (nombre, categoria_id, proveedor_id, precio, stock, stock_minimo, por_peso) values
  ('Coca Cola 500ml',    1, 1,  1200, 24, 6,   false),
  ('Sprite 500ml',       1, 1,  1100, 18, 6,   false),
  ('Manaos Naranja 1.5L',1, 5,  900,  30, 8,   false),
  ('Pepsi 500ml',        1, 8,  1100, 4,  6,   false),
  ('Alfajor Jorgito',    2, 2,  450,  40, 10,  false),
  ('Alfajor Jorgelin',   2, 2,  380,  35, 10,  false),
  ('Pitusas x10',        2, 2,  300,  22, 8,   false),
  ('Caramelos a granel', 4, 10, 12,   500,100, true),
  ('Gomitas a granel',   4, 10, 15,   400,100, true),
  ('Control remoto ECR', 5, 6,  4500, 8,  2,   false),
  ('Pilas Duracell AA x2',6,10, 600,  3,  5,   false),
  ('Encendedor',         6, 10, 350,  15, 5,   false),
  ('Galletitas Don Satur',3,2,  550,  20, 6,   false),
  ('Capitán del Espacio', 2, 2, 420,  2,  5,   false)
on conflict do nothing;

-- ============================================
-- POLÍTICAS DE SEGURIDAD (RLS deshabilitado para simplificar)
-- ============================================
alter table categorias enable row level security;
alter table proveedores enable row level security;
alter table productos enable row level security;
alter table ventas enable row level security;
alter table venta_items enable row level security;
alter table ingresos enable row level security;
alter table usuarios enable row level security;

-- Permitir todo desde anon key (la app maneja autenticación propia por PIN)
create policy "allow all" on categorias for all using (true) with check (true);
create policy "allow all" on proveedores for all using (true) with check (true);
create policy "allow all" on productos for all using (true) with check (true);
create policy "allow all" on ventas for all using (true) with check (true);
create policy "allow all" on venta_items for all using (true) with check (true);
create policy "allow all" on ingresos for all using (true) with check (true);
create policy "allow all" on usuarios for all using (true) with check (true);
