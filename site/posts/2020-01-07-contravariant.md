---
title: "The Functor Family: Contravariant"
author: Evie Ciobanu
date: Jan 07, 2020
tags: [haskell, functor]
description: "A look into contravariant functors."
---

This post assumes prior knowledge of
- the `Functor` class / concept
- the functor instance for `(->) r`

## Why

Not all higher kinded types `* -> *` can have a `Functor` instance. While types
like `Maybe a`, `(x, a)`, `r -> a`, `Either e a` and `[a]` are `Functors` in
`a`, there are some types that cannot have a `Functor` instance. A good example
is `Predicate`:
```haskell
newtype Predicate a = Predicate { getPredicate :: a -> Bool }
```

We call this type a predicate in `a` because, given some value of type `a` we
can obtain a `True` or a `False`. So, for example:
- `Predicate (> 10)` is a predicate in `Int` which returns true if the number is
    greater than 10,
- `Predicate (== "hello")` is a predicate in `String` which returns true if the
    string is equal to *"hello"*, and
- `Predicate not` is a predicate in `Bool` which returns the negation of the
    boolean value it receives.

We can try writing a `Functor` instance and see what we can learn:
```haskell
instance Functor Predicate where
  fmap :: (a -> b) -> Predicate a -> Predicate b
  fmap f (Predicate g) = 
    Predicate
        $ \b -> _welp
```

As the type hole above would suggest, we need to return a `Bool` value, and we
have:
- `b :: b`
- `f :: a -> b`
- `g :: a -> Bool`

There is no way we can combine these terms at all, let alone in such a way as to
obtain a `Bool` value. The only way we would be able to obtain a `Bool` value is
by calling `g`, but for that, we need an `a` -- but all we have is a `b`.

What if `f` was reversed, though? If we had `f' :: b -> a`, then we could apply
`b` to it `f' b :: a` and then pass it to `g` to get a `Bool`. Let's write this
function outside of the `Functor` class:
```haskell
mapPredicate :: (b -> a) -> Predicate a -> Predicate b
mapPredicate f (Predicate g) =
    Predicate
        $ \b -> g (f b)
```

This looks very weird, compared to `Functor`s, right? If you want to go from
`Predicate a` to `Predicate b`, you need a `b -> a` function?


*Exercise 1*: fill in the typed hole `_e1`:
```haskell
greaterThan10 :: Predicate Int
greaterThan10 = Predicate (> 10)

exercise1 :: Predicate String
exercise1 = mapPredicate _e1 greaterThan10
```

*Exercise 2*: write `mapShowable` for the following type:
```haskell
newtype Showable a = Showable { getShowable :: a -> String }

mapShowable :: (b -> a) -> Showable a -> Showable b
```

*Exercise 3*: Use `mapShowable` and `showableInt` to implement `exercise3` such
that `getShowable exercise3 True` is `"1"` and `getShowable exercise3 False`
is `"2"`.
```haskell
showableInt :: Showable Int
showableInt = Showable show

exercise3 :: Showable Bool
exercise3 =
```

## How

`Predicate` and `Showable` are very similar, and types like them admit a
`Contravariant` instance. Let's start by looking at it:
```haskell
class Contravariant f where
  contramap :: (b -> a) -> f a -> f b
```

The instances for `Predicate` and `Showable` are trivial: they are exactly
`mapPredicate` and `mapShowable`. The difference between `Functor` and
`Contravariant` is exactly the function they receive: one is "forward" and the
other is "backward", and it's all about how the data type is defined.

All `Functor` types have their type parameter `a` in what we call a *positive*
position. This usually means there can be some `a` available in the type (which
is always the case for tuples, or sometimes the case for `Maybe`, `Either` or
`[]`). It can also mean *we can obtain an `a`*, like is the case for `r -> a`.
Sure, we need some `r` to do that, but we are able to obtain an `a` afterwards.

On the opposite side, `Contravariant` types have their type parameter `a` in
what we call a *negative* position: they *need* to consume an `a` in order to
produce something else (a `Bool` or a `String` for our examples).

*Exercise 4*: Look at the following types and decide which can have a `Functor`
instance and which can have a `Contravariant` instance. Write the instances
down:
```haskell
data T0 a = T0 a Int
data T1 a = T1 (a -> Int)
data T2 a = T2L a | T2R Int
data T3 a = T3
data T4 a = T4L a | T4R a
data T5 a = T5L (a -> Int) | T5R (a -> Bool)
```

As with `Functor`s, we can partially apply higher kinded types to write a
`Contravariant` instance. The most common case is for the flipped version of
`->`:
```haskell
newtype Op a b = Op { getOp :: b -> a }
```
While `a -> b` has a `Functor` instance, because the type is actually `(->) a
b`, and `b` is in a *positive* position, its flipped version has a
`Contravariant` instance.

*Exercise 5*: Write the `Contravariant` instance for `Op`:
```haskell
instance Contravariant (Op r) where
  contramap :: (b -> a) -> Op r a -> Op r b
```

*Exercise 6*: Write a `Contravariant` instance for `Comparison`:
```haskell
newtype Comparison a = Comparison { getComparison :: a -> a -> Ordering }
```

*Exercise 7*: Can you think of a type that has both `Functor` and
`Contravariant` instances?

*Exercise 8*: Can you think of a type that can't have a `Functor` nor a
`Contravariant` instance? These types are called `Invariant` functors.

