(ns pg-calf.core
  (:require [hugsql.core :as hugs]))

(def sql-file "pg_calf/core.sql")

(hugs/def-db-fns sql-file)
(hugs/def-sqlvec-fns sql-file)

(defn table-names [db]
  (map :table_name (table-names* db)))

(defn table-columns [db name]
  (table-columns* db {:table name}))

(defn enum-types [db]
  (reduce (fn [m {:keys [name value]}]
            (update m name (fnil conj []) value)) {} (enum-types* db)))

(defn table-indexes [db table]
  (when-let [oid (some-> (table-oid db {:regex (str "^(" table ")$")}) first :oid)]
    (indexes* db {:oid oid})))

(defn table-info [db name]
  {:columns      (table-columns db name)
   :foreign-keys (foreign-keys db {:table name})
   :indexes      (table-indexes db name)})

;;\set ECHO_HIDDEN on
