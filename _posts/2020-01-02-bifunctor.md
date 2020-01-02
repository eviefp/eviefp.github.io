---
title: "The Functor Family: Bifunctor"
description: ""
author: "cvlad"
---

## Prerequisites

This post assumes prior knowledge of
- the `Functor` class / concept
- the functor instance for `Either a`, `(,) a`
- basic kind knowledge, e.g. the difference between `* -> *` and `* -> * -> *`

## Why

In Haskell, functors can only be defined for types of kind `* -> *` like
`Maybe a` or `[a]`. Their instances allow us to use `fmap` (or `<$>`) to go from
`Maybe a` to `Maybe b` using some `a -> b`, like:
```haskell
λ> show <$> Just 1
Just "1"

λ> show <$> Nothing
Nothing

λ> show <$> [1, 2, 3]
["1", "2", "3"]

λ> show <$> []
[]
```

We can even define functor instances for higher kinded types, as long as we fix
type arguments until we get to `* -> *`. For example, `Either` has kind
`* -> * -> *`, but `Either e` has kind `* -> *`. So that means that we can have
a functor instance for `Either e`, given some type `e`. This might sound
confusing at first, but all it means is that the `e` cannot vary, so we can go
from `Either e a` to `Either e b` using some `a -> b`, but we cannot go from
`Either e1 a` to `Either e2 a` or `Either e2 b` even if we had both `a -> b` and
`e1 -> e2`. How would we even pass two functions to `fmap`?

```haskell
λ> show <$> Right 1
Right "1"

λ> show <$> Left True
Left True
```

In the first example, we go from `Either a Int` to `Either a String` using `show
:: Int -> String`. In the second example, we go from `Either Bool a` to `Either
Bool String`, where `a` needs to have a `Show` instance.

But what if we want to go from `Either a x` to `Either b x`, given some
`a -> b`?

Let's see how we could implement it ourselves:
```haskell
mapLeft :: (a -> b) -> Either a x -> Either b x
mapLeft f (Left a) = Left (f a)
mapLeft _ r        = r
```

Since we are trying to map the `Left`, the interesting bit is for that
constructor: we apply `f` under `Left`. Otherwise, we just leave the value
as-is; a `Right` value of type `x` (we could have written `mapLeft _ (Right x) =
Right x` and it would work the same).

Here's a few warm-up exercises. The first uses typed holes to guide you and
clarify what's meant by "using `either`". The last exercise can be a bit tricky.
Look up what `Const` is and use typed holes.

*Exercise 1*: re-implement `mapLeft'` using `either`:
```haskell
mapLeft' :: (a -> b) -> Either a x -> Either b x
mapLeft' f e = either _leftCase _rightCase e
```

*Exercise 2*: implement `mapFirst`:
```haskell
mapFirst :: (a -> b) -> (a, x) -> (b, x)
```

*Exercise 3*: implement `remapConst`:
```haskell
import Data.Functor.Const (Const(..))

remapConst :: (a -> b) -> Const a x -> Const b x
```

## How

While we can implement `mapLeft`, `mapFirst`, and `remapConst` manually, there
is a pattern: some types of kind `* -> * -> *` allow both their type arguments
to be mapped like a `Functor`, so we can define a new class:

```haskell
class Bifunctor p where
  {-# MINIMAL bimap | first, second #-}
  bimap :: (a -> b) -> (c -> d) -> p a c -> p b d
  first :: (a -> b) -> p a c -> p b c
  second :: (b -> c) -> p a b -> p a c
```

`bimap` takes two functions and is able to map both arguments in a type of kind
`* -> * -> *`. `first` is a lot like the functions we just defined manually.
`second` is always the same thing as `fmap`.  This class exists in `base`, under
`Data.Bifunctor`.

*Exercise 4*: implement `bimap` in terms of `first` and `second`.

*Exercise 5*: implement `first` and `second` in terms of `bimap`.

*Exercise 6*: implement the `Bifunctor` instance for `Either`:
```haskell
instance Bifunctor Either where
  bimap f _ (Left a)  = _leftCase
  bimap _ g (Right b) = _rightCase
```

*Exercise 7*: Implement the `Bifunctor` instance for tuples `(a, b)`.

*Exercise 8*: Implement the `Bifunctor` instance for `Const`.

*Exercise 9*: Implement the `Bifunctor` instance for `(a, b, c)`.

*Exercise 10*: Find an example of a type with kind `* -> * -> *` that cannot
have a `Bifunctor` instance.

*Exercise 11*: Find an example of a type with kind `* -> * -> *` which has a
`Functor` instance when you fix one type argument, but can't have a
`Bifunctor` instance.
