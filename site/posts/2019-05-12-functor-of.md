---
title: "Functor-Of"
author: Evie Ciobanu
date: May 12, 2019
tags: [haskell, functor]
description: "Towards a more general Functor class"
---

Due to kind restrictions, the Haskell _Functor_ cannot represent a lot of valid
functors: functors of higher kinded types (higher than `* -> *`), contravariant
functors, invariant functors, etc.

This post will show an alternate `Functor` that can handle all of the above.
I got this idea from the awesome [Tom Harding](https://twitter.com/am_i_tom),
and he apparently got it from [@Iceland_jack](https://twitter.com/Iceland_jack).

Although this is not new, I could not find any blog post or paper covering it.

## The actual problem
The problem is quite straight-forward. Let's say we want to define a functor
instance for `(a, b)` which changes the `a`, to `c` using an `a -> c` function.
This should be possible, but there is no way to write it using `Functor` and
`fmap`.

There are two ways to do this in Haskell using `Prelude`:
- by using `Bifunctor`/`first`, or
- by using the `Flip` newtype.

While both the above options work, they are not particularly elegant. On top of
that, there is no common _Trifunctor_ package, and flipping arguments around
and wrapping/unwrapping newtypes is not very appealing, which means the approach
doesn't quite scale well.

## FunctorOf to the rescue
There are two problems with `Functor`:
- `f` has the wrong kind if we want to allow higher kinded functors, and
- the arrow of the mapped function is the wrong type if we want to allow 
contravariant or invariant functors (or even other types of mappings!).

We can fix both problems by adding additional types to the class:
```haskell
class FunctorOf (p :: k -> k -> Type) (q :: l -> l -> Type) f where
  map :: p a b -> q (f a) (f b)
```

`p` represents a relationshiop (arrow) between `a` and `b`. In case of a regular
functor, it's just `->`, but we can change it to a reverse arrow for
contravariants.

`q` is normally just an optional layer on top of `->`, in order to allow mapping
over other arguments. For example, if we want to map over the second-to-last
argument, we'd use natural transforms (`~>`). 

The regular functor instance can be obtained by simply:
```haskell
instance Functor f => FunctorOf (->) (->) f where
  map :: forall a b. (a -> b) -> f a -> f b
  map = fmap

functorExample :: [String]
functorExample = map show ([1, 2, 3, 4] :: [Int])
```

## Functor for HKD
I'll use the `Bifunctor` instance in order to show all bifunctors can have such
a `FunctorOf` instance. Of course, one could define instances manually for any
`Bifunctor`.

Going back to our original example, we can define a `FunctorOf` instance for
`* -> * -> *` types in the first argument via:
```haskell
newtype (~>) f g = Natural (forall x. f x -> g x)
  
instance Bifunctor f => FunctorOf (->) (~>) f where
  map :: forall a b. (a -> b) -> f a ~> f b
  map f = Natural $ first f
```

In order to avoid fiddling about with newtypes, we can define a helper `bimap'`
function for `* -> * -> *` that maps both arguments:
```haskell
bimap'
  :: forall a b c d f
  .  FunctorOf (->) (->) (f a)
  => FunctorOf (->) (~>) f
  => (a -> b)
  -> (c -> d)
  -> f a c
  -> f b d
bimap' f g fac =
  case map f of
    Natural a2b -> a2b (map g fac)

bifunctorExample :: (String, String)
bifunctorExample = bimap' show show (1 :: Int, 1 :: Int)
```

## Contravariant
Okay, cool. But what about _contravariant_ functors? We can use `Op` from
`Data.Functor.Contravariant` (defined as `data Op a b = Op (b -> a)`):
```haskell
instance Contravariant f => FunctorOf Op (->) f where
  map :: forall a b. (Op b a) -> f b -> f a
  map (Op f) = contramap f
```

This is pretty cool since we only need to change the mapped function's type to
be `Op` instead of `->`! As before, we can make things easier by defining a
helper:

```haskell
cmap
  :: forall a b f
  .  FunctorOf Op (->) f
  => (b -> a)
  -> f a
  -> f b
cmap f fa = map (Op f) fa

contraExample :: Predicate Int
contraExample = cmap show (Predicate (== "5"))
```

## What about Profunctors?
I'm glad you asked! It's as easy as 1-2-3, or well, as easy as "functor in the
last argument" - "contravariant in the previous" - "write helper function":

```haskell
instance Profunctor p => FunctorOf Op (~>) p where
  map :: forall a b. (Op b a) -> p b ~> p a
  map (Op f) = Natural $ lmap f

dimap'
  :: forall a b c d p
  .  FunctorOf (->) (->) (p a)
  => FunctorOf Op   (~>) p
  => (b -> a)
  -> (c -> d)
  -> p a c
  -> p b d
dimap' f g pac =
  case map (Op f) of
    Natural b2a -> b2a (map g pac)

profunctorExample :: String -> String
profunctorExample = dimap' read show (+ (1 :: Int))
```

## Tri..functors?
Yep. We only need to define a higher-kinded natural transform and write the
`FunctorOf` instance, along with the helper:
```haskell
newtype (~~>) f g = NatNat (forall x. f x ~> g x)

data Triple a b c = Triple a b c deriving (Functor)

instance {-# overlapping #-} FunctorOf (->) (~>) (Triple x) where
  map :: forall a b. (a -> b) -> Triple x a ~> Triple x b
  map f = Natural $ \(Triple x a y) -> Triple x (f a) y

instance FunctorOf (->) (~~>) Triple where
  map :: (a -> b) -> Triple a ~~> Triple b
  map f = NatNat $ Natural $ \(Triple a x y) -> Triple (f a) x y

triple
  :: forall a b c d e f t
  .  FunctorOf (->) (->)  (t a c)
  => FunctorOf (->) (~>)  (t a)
  => FunctorOf (->) (~~>) t
  => (a -> b)
  -> (c -> d)
  -> (e -> f)
  -> t a c e
  -> t b d f
triple f g h = a2b . c2d . map h
  where
    (Natural c2d) = map g
    (NatNat (Natural a2b)) = map f

tripleExample :: Triple String String String
tripleExample = triple show show show (Triple (1 :: Int) (2 :: Int) (3 :: Int))
```

The pattern is pretty simple:
- we need a `FunctorOf` instance for every argument we want to map
- for each such argument, we need to use `->` for variant and `Op` for
contravariant arguments as the first argument to `FunctorOf`
- from right to left, we need to use increasing level of transforms to map the
type arguments (`->`, `~>`, `~~>`, etc)

## What about invariants?
We can define an instance for `Endo` using:
```haskell
data Iso a b = Iso
  { to   :: a -> b
  , from :: b -> a
  }

instance FunctorOf Iso (->) Endo where
  map :: forall a b. Iso a b -> Endo a -> Endo b
  map Iso { to, from } (Endo f) = Endo $ to . f . from

endoExample :: Endo String
endoExample = map (Iso show read) (Endo (+ (1 :: Int)))
```

We can even go further:
```haskell
instance FunctorOf (->) (->) f => FunctorOf Iso Iso f where
  map :: Iso a b -> Iso (f a) (f b)
  map Iso { to, from } = Iso (map to) (map from)
```
which is to say, given an isomorphism between `a` and `b`, we can obtain an
isomorphism between `f a` and `f b`!

## Future work ideas
I think this instance can be also used for proofs. For example, using the `Refl`
equality type:
```haskell
data x :~: y where
  Refl :: x :~: x
```

And this means we can write transitivity as:
```haskell
instance FunctorOf (:~:) (->) ((:~:) x) where
  map :: forall a b. a :~: b -> x :~: a -> x :~: b
  map Refl Refl = Refl

proof :: Int :~: String -> Bool :~: Int -> Bool :~: String
proof = map
```

Code is available [here](https://github.com/eviefp/functorof/blob/master/src/FunctorOf.hs).

Another thing worth mentioning is the awesome upcoming
[GHC extension](https://gitlab.haskell.org/kcsongor/ghc/tree/unsaturated_type_families)
(being worked on by [Csongor Kiss](https://twitter.com/Lowert)) which allows type
families to be partially applied. If you haven't
[read the paper](https://www.microsoft.com/en-us/research/publication/higher-order-type-level-programming-in-haskell/), you should!
Using this feature, one could do something like:
```haskell
type family Id a where Id x = x

instance FunctorOf (->) (->) Id
  map = ($)

idExample :: Bool
idExample = map (+1) 1 == 2
```
Please note I have not tested the above code; it was suggested by Tom Harding
(thanks again for the idea and reviewing!).


What other uses can you come up with?
