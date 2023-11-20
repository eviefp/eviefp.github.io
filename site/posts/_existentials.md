---
title: "Closed World Existentials"
author: Evie Ciobanu
date: May 1, 2022
tags: [haskell, existential]
description: "A different type of existentials"
---

This post is about a special kind of existential types we ended up using at
Hasura. 

## Existential types

Talk about existentials in general.

## Trees That Grow

Detour! Because why else do we have the HKT existential type?!

## Closed World Existential Types

```haskell
data BackendTag = Postgres | MSSQL | MySQL

data AnyBackend (i :: BackendTag -> Type)
  = PostgresBackend (i 'Postgres)
  | MSSQLBackend (i 'MSSQL)
  | MySQLBackend (i 'MySQL)

type AllBackendsSatisfy (i :: BackendTag -> Type) (c :: Type -> Constraint)
  = ( c (i 'Postgres)
    , c (i 'MSSQL)
    , c (i 'MySQL)
    )

dispatchAnyBackend
  :: AllBackendsSatisfy i c
  => (c b => i b -> r)
  -> AnyBackend i
  -> r
```
