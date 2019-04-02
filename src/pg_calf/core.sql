-- :name table-names*
SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name;

-- :name table-columns*
SELECT column_name AS "name",
       ordinal_position AS "position",
       data_type AS "type",
       udt_name AS "udt-type",
       column_default AS "default",
       character_maximum_length AS "max-length",
       is_nullable::boolean AS "nullable",
       numeric_precision AS "numeric-precision",
       numeric_scale AS "numeric-scale",
       datetime_precision AS "datetime-precision"
  FROM information_schema.columns WHERE table_name = :table ORDER BY ordinal_position;

-- :name foreign-keys
SELECT tc.constraint_name AS "name",
       kcu.column_name AS "column",
       ccu.table_name AS "foreign-table",
       ccu.column_name AS "foreign-column"
  FROM information_schema.table_constraints AS tc
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
  WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name = :table;

-- :name enum-types*
SELECT t.typname AS "name",
       e.enumlabel AS "value"
  FROM pg_type t
    JOIN pg_enum e ON t.oid = e.enumtypid
    JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
  ORDER BY t.typname;

-- :name table-oid
SELECT c.oid,
       n.nspname,
       c.relname
  FROM pg_catalog.pg_class c
  LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE c.relname OPERATOR(pg_catalog.~) :regex
    AND pg_catalog.pg_table_is_visible(c.oid)
    ORDER BY 2, 3;

-- :name indexes*
SELECT
    c2.relname AS "name",
    i.indisprimary as "primary",
    i.indisunique as "unique",
    i.indisclustered as "clustered",
    i.indisvalid as "invalid",
    pg_catalog.pg_get_indexdef(i.indexrelid, 0, true) AS "indexdef",
    pg_catalog.pg_get_constraintdef(con.oid, true) AS "constraint-def",
    contype as "type", --TODO not sure what this is
    c2.reltablespace as "table-space"
  FROM pg_catalog.pg_class c,
       pg_catalog.pg_class c2,
       pg_catalog.pg_index i
  LEFT JOIN pg_catalog.pg_constraint con ON (conrelid = i.indrelid AND conindid = i.indexrelid AND contype IN ('p','u','x'))
  WHERE c.oid = :oid AND c.oid = i.indrelid AND i.indexrelid = c2.oid
  ORDER BY i.indisprimary DESC, i.indisunique DESC, c2.relname;
