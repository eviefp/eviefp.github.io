---
title: "Composition"
description: "What is a Monoid?"
author: "cvlad"
---


# Introduction

This post will attempt to show what a monoid is from the algebraic perspective 
and apply it through PureScript.

How to read
- if you know the algebraic definition of a monoid, feel free to skip to
[Monoid in PureScript](#monoid-in-purescript)
- if you know the basic PureScript definition but want to see how Applicative
is a monoid and Alternative is a Semiring, skip to
[Applicative Monoid](#applicative-monoid)


## Monoid in Algebra

Before I can introduce a monoid, I need to give a brief (and extremely informal)
definition of sets, operations, associativity, identity, etc.

### Sets

We are used to grouping things together. We sometimes call such a group a *set*
of things. For example, the numbers 1 through 10 form the set
$ A = \\{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 \\} $.

Similarly, we have the set of boolean values $ B = \\{ true, false \\} $, the set
of musical notes
$ Notes = \\{ A, A\\#, B, C, C\\#, D, D\\#, E, F, F\\#, G, G\\# \\} $,
the set of friends of a person, etc.

It's worth mentioning that there's also infinite sets, for example $ \Bbb{N} $
for all natural numbers (0 through infinity), $ \Bbb{Z} $ for all integral
numbers (minus infinity through infinity), $ \Bbb{R} $ for all real numbers, etc.

### Operations

We can define operations on these sets. For example, an operation that adds 1
to an element of the natural numbers set $\Bbb{N}$ would look like

$$ addOne : \Bbb{N} \rightarrow \Bbb{N} $$

This means that **addOne** _takes_ a natural number and _returns_ a natural
number. We _call_ it by just putting a number next to the operation, such as

$$
addOne \: 0 = 1 \\
addOne \: 1 = 2 \\
addOne \: 5 = 6
$$

Operations do not need to be arithmetic. For example, we can define an operation
that gives us the next musical note

$$ next : Notes \rightarrow Notes $$

and use it

$$
\begin{align}
next \; A &= A\# \\
next \; A\# &= B \\
next \; B &= C
\end{align}
$$

These operations are *unary* operations. *Binary* operations take _two_ inputs.
For example, addition of two numbers is

$$(+) : \Bbb{N} \rightarrow \Bbb{N} \rightarrow \Bbb{N}$$

This means that $(+)$ takes two numbers and returns a number

$$
1 + 0 = 1 \\
1 + 1 = 2 \\
3 + 4 = 7
$$

### Associativity

Associativity of a binary operator simply means that, if you have any three
elements (e.g., a, b, c) from a set and a binary operation (e.g., $(+)$) on the
set, then the order in which you apply the operation does not matter

$$ (a + b) + c = a + (b + c) $$

### Semigroup

A semigroup has two components: a set and an associative binary operation.

As an example, consider all notes and possible combination of chords
(i.e., two or more notes, played at the same time) and an operation $(+)$ that
is the set union between the two (i.e., all notes are used, duplicates are removed)

$$
\{ A \} + \{ C \} = \{ A, C \} \\
\{ A, C \} + \{ E \} = \{ A, C, E \} \\
\{ A, C, E \} + \{ A, C \} = \{ A, C, E \}
$$

The order does not matter because we play all the notes at the same time.

### Identity

The identity element for a binary operation $(+)$ is an element $e$ that is neutral
for the operation, i.e., for any element $a$ from the set, the following hold:

$$
a + e = a \\
e + a = a
$$

This is another way of saying that there exists an element in the set such that,
combining that element with any other element, we get that other element back.

For example, 0 is the neutral element for addition of numbers. Whatever number you
add to 0, you get that number back. Same goes for multiplication of numbers and the
number 1.

### Monoid

A *monoid* is a semigroup with identity.

A monoid $\mathcal{M}$ has a set M, an associative binary operation $(+)$, and an
identity element $e$, and for all elements $a$, $b$, and $c$ in M

$$
(a + b) + c = a + (b + c) \\
a + e = a \\
e + a = a
$$

### Semiring

A *semiring* combines two monoids, along with a couple of new laws.

A semiring $\mathcal{S}$ has a set S, and _two_ associative binary operations $(+)$
and $(\*)$, and each of these operations has its own identity element ($0$ for $(+)$
and $1$ for $(\*)$).

There are two new laws that must be obeyed: *distributivity* of $(\*)$ over $(+)$
and *annihilation* of $0$ over $(\*)$.

Formally

- S, $(+)$ and $0$ form a _commutative_ monoid that

$$
\begin{align}
(a + b) + c = a + (b + c) & \; \; \; (associative) \\
0 + a = a + 0 = a & \; \; \; (identity) \\
a + b = b + a & \; \; \; (commutative)
\end{align}
$$

- S, $(*)$ and $1$ form a monoid

$$
\begin{align}
(a * b) * c = a * (b * c) & \; \; \; (associative) \\
1 * a = a * 1 = a & \; \; \; (identity)
\end{align}
$$

- $(\*)$ distributes over $(\+)$

$$
\begin{align}
a * (b + c) = (a * b) + (b * c) & \; \; \; (left \: distributivity) \\
(a + b) * c = (a * c) + (b * c) & \; \; \; (right \: distributivity)
\end{align}
$$

- $0$ annihilates $(*)$

$$
0 * a = a * 0 = 0 \; \; \; (annihilation)
$$


## Monoid in PureScript

In PureScript, we can define semigroups and monoids as type classes

```haskell
class Semigroup m where
    append ∷ m → m → m

class Semigroup m <= Monoid m where
    mempty ∷ m
```

For example, we can implement the addition monoid

```haskell
instance Semigroup Int where
    append a b = a + b

instance Monoid Int where
    mempty = 0
```

However, implementing the Int monoid for multiplication is impossible because we
can't define two instances of monoid for the same type. One solution is creating
a _newtype_ wrapper for both addition and multiplication and create two monoid
instances. 

```haskell
newtype Sum = Sum Int

instance sumSemigroup ∷ Semigroup Sum where
  append = (+)
instance sumMonoid ∷ Monoid Sum where
  mempty = 0


newtype Product = Product Int

instance prodSemigroup ∷ Semigroup Product where
  append = (*)
instance prodMonoid ∷ Monoid Product where
  mempty = 1
```

Here's a few more examples of monoids
  - boolean disjunction with false as the identity
  - boolean conjuction with true as the identity
  - set union with the empty set as identity
  - list concatenation with empty list as identity

### Function Monoids
There are two possible monoid instances for function types.

The set of functions `a → m` where `m` is a monoid form a monoid. The
input is *distributed* to all functions, and their results are combined together
using the `m` monoid instance to a single value. One example is functions that
return lists, where the composition of such functions gives us back a flat list,
instead of a list of lists.

```haskell
instance fnSemigroup1 ∷ Semigroup m <= Semigroup (a → m) where
    append f g = \x → append (f x) (g x)

instance fnMonoid1 ∷ Monoid m <= Monoid (a → m) where
    mempty = const mempty
```

The set of functions `a → a` can be *sequenced* one after the other to create a
pipeline of operations on the input.

```haskell
instance fnSemigroup2 ∷ Semigroup (a → a) where
    append f g = f <<< g

instance fnMonoid2 ∷ Monoid (a → a) where
    mempty = id
```

### Applicative Monoid

I will assume familiarity with the `Applicative` class.

```haskell
class Functor f <= Apply f where
  apply ∷ ∀ a b. f (a → b) → f a → f b

class Apply f <= Applicative f where
  pure ∷ ∀ a. a → f a
```

How is this a monoid? Let's try to create a different definition and see if we can
implement one in terms of the other

```haskell
class TupleMonoid f where
    tappend ∷ ∀ a b. f a → f b → f (Tuple a b)
    tempty  ∷ f Unit
```

The types for `tappend` and `tempty` do not match exactly the types required for
the monoid `append` and `empty`, which is why we need a new class. Let's consider
associativity for `TupleMonoid`, where $(+)$ is `tappend` and $(a, b)$ is
`Tuple a b`

$$
\begin{align}
(a + b) + c &= a + (b + c) \\
(a, b) + c &= a + (b, c) \\
((a, b), c) &= (a, (b, c))
\end{align}
$$

The types are not exactly equal, but they hold the exact same data and we can
easily define functions that map between the two. So we say the associativity law
holds up to isomorphism.

As for identity

$$
a + mempty = mempty + a = a \\
(a, unit) = (unit, a) = a
$$

Again, since `unit` is a trivial value, we can easily create isomorphic
functions between the equalities above.

This _up to isomorphism_ addendum is also why we can't use the default
Semigroup and Monoid lasses, but the `TupleMonoid` will do.

Now, let's try to define `TupleMonoid` for any `f` that has an `Applicative`. We
will use a newtype just to keep things clean

```haskell
newtype TMApplicative f a = TMApplicative (f a)

-- ... derive newtype Functor, Apply, Applicative

instance tmMon ∷ Applicative f ⇒ TupleMonoid (TMApplicative f) where
    tappend fa fb = Tuple <$> fa <*> fb
    tempty = TMApplicative <<< pure $ unit
```

`tappend` basically _lifts_ the `Tuple` constructor so we end up with simple
implementations for the `TupleMonoid` instance. Try mapping out the types
if it doesn't make sense.

Now the question is, can we implement it the other way around: given `f` with
`Functor` and `TupleMonoid` instances, can we implement an `Applicative`
instance? Turns out we can, although it's a bit trickier

```haskell
newtype TMMonoid f a = TMMonoid (f a)

-- ... derive newtype Functor, TupleMonoid

instance appTM ∷ (Functor f, TupleMonoid f)
               ⇒ Apply (TMMonoid f) where
  apply fab fa = tappend fab fa <#> \(Tuple ab a) → ab a

instance applTM ∷ (Functor f, TupleMonoid f)
                ⇒ Applicative (TMMonoid f) where
  pure a = a <$ tempty
```

The trick with `apply` is that `tappend fab fa ∷ f (a → b, a)`, so we `map`
(`<#>` is just `flip map`) a function that takes a tuple and applies `fst` to
`snd` to get a `f b`.

As for `pure`, `<$` is implemented as `map (const x)`, so we just discard the
unit from `tempty` but keep the container to get an `f a`.

### Alt Monoid

Similarly to `Apply` and `Alternative`, PureScript has `Alt` and `Plus`
classes which are the rough equivalents of `Semigroup` and `Monoid`

```haskell
class Functor f <= Alt f where
    alt ∷ ∀ a. f a → f a → f a

class Alt f <= Plus f where
    empty ∷ ∀ a. f a
```

Obviously, `alt` (also known as `<|>`) is `append` and `empty` is identity.
These classes already look like a monoid, so there's not much work to do here.

### The Alternative Semiring

The `Alternative` class is

```haskell
class (Applicative f, Plus f) <= Alternative f
```

Additionally, it guarantees the laws

```haskell
(f <|> g) <*> x = (f <*> x) <|> (g <*> x) -- distributivity
empty <*> f = empty                       -- annihilation
```

Which are the laws of `Semiring`. We are only missing commutativity of `<|>`,
but this is not possible to obtain from (most) `Alt` instances.


## Why should I care?

It's an interesting perspective, and we could draw a few analogies and perhaps
some insight into the reasons of how some `Applicative` and `Alternative` instances
work.

| Num | Alternative | Array             | Maybe               |
| --- | ----------- | ----------------- | ------------------- |
| +   | <&#124;>    | concat            | first non-Nothing   |
| 0   | empty       | []                | Nothing             | 
| *   | <*>         | cartesian product | Nothing annihilates |
| 1   | pure        | [a]               | Just a              |

Check out the [repository](https://github.com/vladciobanu/applicative-monoid)
with full source code and quickcheck tests.
