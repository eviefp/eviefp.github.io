---
title: "Classical Logic in Haskell"
description: "Because why not"
author: "cvlad"
---


# Introduction

During a very pleasant conversation at a recent
[Bucharest FP](http://bucharestfp.ro) meetup,
[somebody](https://twitter.com/igstan) mentioned that `Cont` is, almost exactly,
[_Peirce's law_](https://en.wikipedia.org/wiki/Peirce%27s_law). I remembered
seeing a [tweet](https://twitter.com/paf31/status/1040304689932165120) from Phil
Freeman which proves that they are indeed equivalent. I thought it would be a
fun exercise to prove other equivalences from classical logic.

This post assumes you are familar with:
- the [Curry-Howard correspondence](https://www.youtube.com/watch?v=aeRVdYN6fE8),
- classical and intuitionistic logic
(for example, see it explained using Coq in 
[Software Foundations](https://softwarefoundations.cis.upenn.edu/current/lf-current/Logic.html)), and
- one of Haskell, Agda, Idris or Coq.


# MonadCont and the Law of Excluded Middle

Haskell and PureScript define `MonadCont`, which represent monads that support
the _call-wth-current-continuation_ (`callCC`) operation:

```haskell
class Monad m => MonadCont m where
    callCC :: ((a -> m b) -> m a) -> m a 
```

`callCC` generally calls the function it receives, passing it the current
continuation (the `a -> m b`). This acts like an `abort` method, or an early
exit.

The interesting part is that this monad looks very similar to _Peirce's law_:

$ ((P \to Q) \to P) \to P $

If we replace `P` with `a` (or `m a`) and `Q` with `m b`, we get the exact
same thing. Since we are dealing with monads, we need to use Kleisli arrows,
so all implications from logic must be lifted as such (so `P -> Q` becomes 
`a -> m b`).

## Proving equivalences

In order to keep things clean, I decided to wrap each equivalent law in its own
newtype and write an instance of `Iso` (which translates to iff) between
each of the laws and the _law of excluded middle_.

```haskell
{-# LANGUAGE InstanceSigs          #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes            #-}
{-# LANGUAGE ScopedTypeVariables   #-}

module Logic where

import           Control.Applicative (liftA2)
import           Control.Monad       ((<=<))
import           Data.Void           (Void, absurd)

class Iso a b where
    to :: a -> b
    from :: b -> a
```

This is just a neat way of having to prove both implications in an iff, packed
as `to` and `from`. Moving on, we can declare the types:

### Peirce's law
Starting with the formula from logic, we can easily write out the Haskell type
by just keeping in mind we have to transform all implications to Kleisli arrows:

$ \forall P, Q. ((P \to Q) \to P) \to P $

```haskell
newtype Peirce m =
    Peirce
        (  forall a b
        .  ((a -> m b) -> m a)
        -> m a
        )
```

### Law of Excluded Middle
The key part to remember here is that negation in classical logic translates to
`-> Void` in intuitionistic logic (and `-> m Void` in our case, since we are
using Kleisli arrows):

$ \forall P. P \lor \neg P $

```haskell
newtype Lem m =
    Lem
        (  forall a
        .  m (Either a (a -> m Void))
        )
```

### Double Negation
Nothing new here, just rewriting negation as `-> m Void`:

$ \forall P. \neg \neg P \to P $

```haskell
newtype DoubleNegation m =
    DoubleNegation
        (  forall a
        .  ((a -> m Void) -> m Void)
        -> m a
        )
```

### De Morgan's Law
The only new thing here is that we translate `and` to tuples, and `or` to
Either:

$ \forall P, Q. \neg (\neg P \land \neg Q) \to P \lor Q $

```haskell
newtype DeMorgan m =
    DeMorgan
        (  forall a b
        .  ((a -> m Void, b -> m Void) -> m Void)
        -> m (Either a b)
        )
```

### Implication to Disjunction

$ \forall P, Q. (P \to Q) \to Q \lor \neg P $

```haskell
newtype ImpliesToOr m =
    ImpliesToOr
        (  forall a b
        .  (a -> m b)
        -> m (Either b (a -> m Void))
        )
```

## Proofs
If this is interesting to you, this would be a good place to look away and try
for yourself. If you do, keep in mind that typed holes are a very useful in
this process (see [this](https://wiki.haskell.org/GHC/Typed_holes) for an
example).

### Lem and Peirce

```haskell
instance Monad m => Iso (Lem m) (Peirce m) where
    to :: Lem m -> Peirce m
    to (Lem lem) = Peirce proof

      where
        proof
            :: ((a -> m b) -> m a)
            -> m a
        proof abort = lem >>= either pure (go abort)

        go
            :: ((a -> m b) -> m a)
            -> (a -> m Void)
            -> m a
        go abort not_a = abort $ fmap absurd . not_a

    from :: Peirce m -> Lem m
    from (Peirce p) = Lem $ p go

      where
        go
            :: (Either a (a -> m Void) -> m Void)
            -> m (Either a (a -> m Void))
        go not_lem = pure . Right $ not_lem . Left
```

### Lem and DoubleNegation

```haskell
instance Monad m => Iso (Lem m) (DoubleNegation m) where
    to :: Lem m -> DoubleNegation m
    to (Lem lem) = DoubleNegation proof

      where
        proof
            :: ((a -> m Void) -> m Void)
            -> m a
        proof notNot = lem >>= either pure (go notNot)

        go
            :: ((a -> m Void) -> m Void)
            -> (a -> m Void)
            -> m a
        go notNot notA = fmap absurd $ notNot notA

    from :: DoubleNegation m -> Lem m
    from (DoubleNegation dne) = Lem $ dne not_exists_dist
```

### Lem and DeMorgan

```haskell
instance Monad m => Iso (Lem m) (DeMorgan m) where
    to :: Lem m -> DeMorgan m
    to (Lem lem) = DeMorgan proof

      where
        proof
            :: ((a -> m Void, b -> m Void) -> m Void)
            -> m (Either a b)
        proof notNotANotB = lem >>= either pure (go notNotANotB)

        go
            :: ((a -> m Void, b -> m Void) -> m Void)
            -> (Either a b -> m Void)
            -> m (Either a b)
        go notNotANotB =
            fmap absurd
            . notNotANotB
            . liftA2 (,) (. Left) (. Right)

    from :: DeMorgan m -> Lem m
    from (DeMorgan dm) = Lem $ dm go

      where
        go
            :: (a -> m Void, (a -> m Void) -> m Void)
            -> m Void
        go (notA, notNotA) = notNotA notA
```

### Lem and ImpliesToOr

```haskell
instance Monad m => Iso (Lem m) (ImpliesToOr m) where
    to :: Lem m -> ImpliesToOr m
    to (Lem lem) = ImpliesToOr proof

      where
        proof
            :: (a -> m b)
            -> m (Either b (a -> m Void))
        proof fab = either Left (go fab) <$> lem

        go
            :: (a -> m b)
            -> (b -> m Void)
            -> Either b (a -> m Void)
        go fab notB = Right $ notB <=< fab

    from :: ImpliesToOr m -> Lem m
    from (ImpliesToOr im) = Lem $ im pure
```
