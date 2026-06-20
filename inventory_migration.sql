-- Inventory tracking: stock_movements table
-- Run this in the Supabase SQL editor.

CREATE TABLE IF NOT EXISTS stock_movements (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity_change integer NOT NULL,  -- positive=restock, negative=sale/adjustment
  reason text NOT NULL,              -- 'sale', 'restock', 'manual_adjustment', 'damage', 'return'
  notes text,
  order_id uuid,                     -- if reason='sale', link to order
  created_at timestamptz DEFAULT now() NOT NULL,
  created_by text                    -- admin email
);

CREATE INDEX IF NOT EXISTS stock_movements_product_id_idx ON stock_movements(product_id);
CREATE INDEX IF NOT EXISTS stock_movements_created_at_idx ON stock_movements(created_at);

-- RLS
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "allow authenticated" ON stock_movements FOR ALL TO authenticated USING (true) WITH CHECK (true);
