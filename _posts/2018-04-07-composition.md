---
title: "Composition"
description: "What is a Monoid?"
author: "cvlad"
---

# Introduction

Despite the fact that monoid is a simple concept, people seem to get
frustrated with them, or just say
[nonsense](https://twitter.com/unclebobmartin/status/982229999276060672).

This post will attempt to show what a monoid is from the perspective of
algebra and, more practically, through PureScript.

How to read:
- if you know the algebraic definition of a monoid, feel free to skip to
[Monoid in PureScript](#monoid-in-purescript)
- if you know the basic PureScript definition but want to see how Applicative
is a monoid and Alternative is a Semiring, skip to
[Applicative Monoid](#applicative-monoid)

## Algebraic Monoid

Before I can introduce a monoid, I need to give a brief (and extremely informal)
definition of sets, operations, associativity, identity, etc.

### Sets

We are used to grouping things together. We sometimes call such a group a set
of things. For example, the numbers 1 through 10 form the set:
$ A = \\{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 \\} $

Similarly, we have the set of boolean values $ \\{ true, false \\} $, the set
of musical notes
$ Notes = \\{ A, A\\#, B, C, C\\#, D, D\\#, E, F, F\\#, G, G\\# \\} $,
set of friends of a person, etc.

It's worth mentioning that there's also infinite sets, for example $ \Bbb{N} $
for all natural numbers (0 through infinity), $ \Bbb{Z} $ for all integral
numbers (minus infinity through infinity), etc.

### Operations

We can define operations on these sets. For example, an operation that adds 1
to an item of the natural numbers set $\Bbb{N}$ would look like:

$$ addOne : \Bbb{N} \rightarrow \Bbb{N} $$

This means that **addOne** _takes_ a natural number and _returns_ a natural
number. We _call_ it by just putting a number next to the operation, such as:

$$
addOne \: 0 = 1 \\
addOne \: 1 = 2 \\
addOne \: 5 = 6
$$

Operations do not need to be arithmetic. For example, we can define an operation
that gives us the next musical note:

$$ next : Notes \rightarrow Notes $$

And use it:

$$
\begin{align}
next \; A &= A\# \\
next \; A\# &= B \\
next \; B &= C
\end{align}
$$

Binary operations take _two_ inputs. For example, general addition (of any two
numbers) is:

$$(+) : \Bbb{N} \rightarrow \Bbb{N} \rightarrow \Bbb{N}$$

This means that **add (+)** takes two numbers and returns a number:

$$
1 + 0 = 1 \\
1 + 1 = 2 \\
3 + 4 = 7
$$

### Associativity

Associativity of a binary operator simply means that, if you have any three
elements (a, b and c) from a set and a binary operation $(+)$ on the
set, then the order in which you apply the binary operation does not matter:

$$ (a + b) + c = a + (b + c) $$

For example, this is true for both addition and multiplication.

### Semigroup

A semigroup has two components: a set and a binary operation that respects
associativity.

As an example, consider all notes and possible combination of possible chords
(two or more notes, played at the same time) and an operation ($\bigoplus$) that
is the set union between the two (all notes are used, duplicates are removed):

$$
\{ A \} \bigoplus \{ C \} = \{ A, C \} \\
\{ A, C \} \bigoplus \{ E \} = \{ A, C, E \} \\
\{ A, C, E \} \bigoplus \{ A, C \} = \{ A, C, E \}
$$

The order does not matter because we play all the notes at the same time anyway.

### Identity

The identity element for a binary operation is an element that is neutral for
the operation. Let's name our operation $(+)$, and the identity element as
**e**, then the following need to hold true for any **a** from the set:

$$
a + e = a \\
e + a = a
$$

This is another way of saying, there exists an element in the set such that,
combining that element with any other element, we get that other element back.

For example, 0 is the neutral element for addition. Whatever number you add to
0, you get that number back. Same goes for multiplication and the number 1.

### Monoid

A monoid a semigroup with identity.

So, monoid M with the set $\Bbb{S}$, a binary operation $(+)$, and the
identity element $e$ will respect the following laws:

$$
(a + b) + c = a + (b + c) \\
a + e = a \\
e + a = a
$$

are true for all $a, b, c \in \Bbb{S}$.

### Semiring

A semiring is a set $\Bbb{S}$ with _two_ binary operations $(+)$ and $(\*)$.
Each of the operations has its own identity element ($0$ for $(+)$ and $1$ for
$(*)$). In addition, there are two new laws that must be obeyed.

$\Bbb{S}$, $(+)$ and $0$ form a _commutative_ monoid that:

$$
\begin{align}
(a + b) + c = a + (b + c) & \; \; \; (associative) \\
0 + a = a + 0 = a & \; \; \; (identity) \\
a + b = b + a & \; \; \; (commutative)
\end{align}
$$

$\Bbb{S}$, $(*)$ and $1$ form a monoid:

$$
\begin{align}
(a * b) * c = a * (b * c) & \; \; \; (associative) \\
1 * a = a * 1 = a & \; \; \; (identity)
\end{align}
$$

Multiplication distributes over addition:

$$
\begin{align}
a * (b + c) = (a * b) + (b * c) & \; \; \; (left distributivity) \\
(a + b) * c = (a * c) + (b * c) & \; \; \; (right distributivity)
\end{align}
$$

And ultimately, $0$ annihilates $(*)$:

$$
0 * a = a * 0 = 0 \; \; \; (annihilation)
$$

## Monoid in PureScript

In PureScript, we can define semigroup and monoid as a type classes:

```haskell
class Semigroup m where
    append :: m -> m -> m

class Semigroup m <= Monoid m where
    mempty  :: m
```

We can now implement the addition monoid:

```haskell
instance Semigroup Int where
    append a b = a + b

instance Monoid Int where
    mempty = 0
```

However, implementing the monoid for multiplication is impossible because we
can't define two instances of monoid for the same type. The solution is creating
a _newtype_ wrapper for both addition and multiplication and create two monoid
instances (Additive and Multiplicative).

Here's a few more examples of monoids:
  - boolean disjunction with false as the identity
  - boolean conjuction with true as the identity
  - set union with the empty set as identity
  - list concatenation with empty list as identity
  - functions with `a -> a` signatures and function identity
  - functions with `a -> m` signatures where `m` is a monoid and the const
  function that returns `m`s empty as identity

### Function Monoids
There are two possible monoid instances for function types.

The set of functions `a -> m` where `m` is a monoid form a different monoid. The
input is "distributed" to all functions, and their results are combined together
using the `m` monoid instance to a single value. One example of where this could
be interesting is functions that return lists, where the composition of such
functions gives us back a flat list, instead of a list of lists.

```haskell
instance Semigroup m <= Semigroup (a -> m) where
    append f g = \x -> append (f x) (g x)

instance Monoid m <= Monoid (a -> m) where
    mempty = const mempty
```

The set of functions `a -> a` can be _plugged_ one after the other to create a
pipeline of operations on the input.

```haskell
instance Semigroup (a -> a) where
    append f g = f . g

instance Monoid (a -> a) where
    mempty = id
```

### Applicative Monoid

I will assume you know what `Applicative` is. To simplify things, we will
group together the definitions of `Apply` and `Applicative`:

```haskell
class Applicative f where
    apply :: forall a b. f (a -> b) -> f a -> f b
    pure :: forall a. a -> f a
```

How is this a monoid? Let's try to create a different definition and see if
we can implement one in terms of the other:

```haskell
class MonoidApplicative f where
    append :: forall a b. f a -> f b -> f (Tuple a b)
    mempty :: f Unit
```

We can implement MonoidApplicative in terms of Applicative:

```
instance Applicative f <= MonoidApplicative f where
    append fa fb = Tuple <$> fa <*> fb
    mempty = pure unit
```

And this looks like a monoid. Let's see about the laws:

```haskell
-- Associativity
(fa <> fb) <> fc = fa <> (fb <> fc)
f (Tuple a b) <> f c = fa <> f (Tuple b c)
f (Tuple (Tuple a b) c) = f (Tuple a (Tuple b c))

-- Identity
fa <> mempty = mempty <> fa = fa
f (Tuple a Unit) = f (Tuple Unit a) = a
```

Unfortunately, the laws don't hold exactly, but we can see that they there is
an _isomorphism_ between the Tuples. So, we say the laws hold _up to
isomorphism_.

Now that we proved we can implement a monoidal applicative, let's see if we can
do it the other way around:

```haskell
instance (MonoidApplicative f, Functor f) <= Applicative f where
    apply fab fa = tapply <$> tuple

        where

        tuple :: f (Tuple (a -> b) a)
        tuple = append fab fa

        tapply :: Tuple (a -> b) a -> b
        tapply (Tuple ab a) = ab a
    pure a = const a <$> mempty
```

This is a bit trickier. The idea is that using the monoidal applicative gives us
a tuple of `a -> b` and `a`, inside an `f` (the `tuple` in the where clause). We
can then `map` a tuple combinator that applies `snd` to `fst`.

Pure is a bit simpler, we just `map mempty` over `const a` to get `f a`.

This substitute of a proof might not be very interesting or impressive to
everyone, but the important take-away is that _Applicative is a monoid_.

### Alt Monoid

Similarly to `Apply` and `Alternative`, PureScript has `Alt` and `Plus` which
are the rough equivalents of `Semigroup` and `Monoid`:

```haskell
class Functor f <= Alt f where
    alt :: forall a. f a -> f a -> f a

class Alt f <= Plus f where
    empty :: forall a. f a
```

Obviously, `alt` (also known as `<|>`) is `append` and `empty` is identity.
These classes already look like a monoid, so there's not much work to do here.

### The Alternative Semiring

The `Alternative` class is:

```haskell
class (Applicative f, Plus f) <= Alternative f
```

Additionally, it guarantees the laws:

```haskell
(f <|> g) <*> x = (f <*> x) <|> (g <*> x) -- distributivity
empty <*> f = empty -- annihilation
```

Which are the laws of `Semiring`.

## Why should I care?

Do we even keep this chapter?