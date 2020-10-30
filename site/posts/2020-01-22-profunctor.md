---
title: "The Functor Family: Profunctor"
author: Vladimir Ciobanu
date: Jan 22, 2020
tags: [haskell, functor]
description: "A look into profunctors"
---

This post assumes prior knowledge of
- [Contravariant](/contravariant)
- [Bifunctor](/bifunctor)

## Why

We've seen how types of kind `* -> *` can have instances for `Functor` or
`Contravariant`, depending on the position of the type argument. We have also
seen that types of kind `* -> * -> *` can have `Bifunctor` instances. These
types are morally `Functor` in both type arguments. We're left with one very
common type which we can't map both arguments of: `a -> b`. It does have a
`Functor` instance for `b`, but the `a` is morally `Contravariant` (so it can't
have a `Bifunctor` instance). This is where `Profunctor`s come in.

Here's a list of a few common types with the instances they allow:

Type          | `Functor` | `Bifunctor` | `Contravariant` | `Profunctor`
------------- |:---------:|:-----------:|:---------------:|:------------:
`Maybe a`     | ✓ |   |   |
`[a]`         | ✓ |   |   |
`Either a b`  | ✓ | ✓ |   |
`(a,b)`       | ✓ | ✓ |   |
`Const a b`   | ✓ | ✓ |   |
`Predicate a` |   |   | ✓ |
`a -> b`      | ✓ |   |   | ✓

Although there are some exceptions, you will usually see `Contravariant` or
`Profunctor` instances over function types. `Predicate` itself is a newtype over
`a -> Bool`, and so are most types with these instances.

Let's take a closer look at `a -> b`. We can easily map over the `b`, but what
about the `a`? For example, given `showInt :: Int -> String`, what do we need to
convert this function to `showBool :: Bool -> String`:
```haskell
showInt :: Int -> String
showInt = show

showBool :: Bool -> String
showBool b = _help
```

We would have access to:
- `showInt :: Int -> String`
- `b :: Bool`
and we want to use `showInt`, so we would need a way to pass `b` to it, which
means we'd need a function `f :: Bool -> Int` and then `_help` would become
`showInt (f b)`.

But if we take a step back, in order to go from `Int -> String` to
`Bool -> String`, we need `Bool -> Int`, which is exactly the `Contravariant`
way of mapping types.

*Exercise 1*: Implement a `mapInput` function like:
```haskell
mapInput :: (input -> out) -> (newInput -> input) -> (newInput -> out)
```
Extra credit: try a pointfree implementation as `mapInput = _`.

*Exercise 2*: Try to guess how the `Profunctor` class looks like. Look at
`Functor`, `Contravariant`, and `Bifunctor` for inspiration.
```haskell
class Profunctor p where
```

*Exercise 3*: Implement an instance for `->` for your `Profunctor` class.
```haskell
instance Profunctor (->) where
```

## How

Unlike `Functor`, `Contravariant`, and `Bifunctor`, the `Profunctor` class is
not in `base`/`Prelude`. You will need to bring in a package like `profunctors`
to access it.

```haskell
class Profunctor p where
  {-# MINIMAL dimap | lmap, rmap #-}
  dimap :: (c -> a) -> (b -> d) -> p a b -> p c d
  lmap :: (c -> a) -> p a b -> p c b
  rmap :: (b -> c) -> p a b -> p a c
```

`dimap` takes two functions and is able to map both arguments in a type of kind
`* -> * -> *`. `lmap` is like `mapInput`.  `second` is always the same thing as
`fmap`.

*Exercise 4*: implement `dimap` in terms of `lmap` and `rmap`.

*Exercise 5*: implement `lmap` and `rmap` in terms of `dimap`.

*Exercise 6*: implement the `Profunctor` instance for `->`:
```haskell
instance Profunctor (->) where
    -- your pick: dimap or lmap and rmap
```

*Exercise 7*: (hard) implement the `Profunctor` instance for:
```haskell
data Sum f g a b
    = L (f a b)
    | R (g a b)

instance (Profunctor f, Profunctor g) => Profunctor (Sum f g) where
```

*Exercise 8*: (hard) implement the `Profunctor` instance for:
```haskell
newtype Product f g a b = Product (f a b, g a b)

instance (Profunctor f, Profunctor g) => Profunctor (Product f g) where
```
