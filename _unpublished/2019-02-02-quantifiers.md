---
title: "Quantifiers in Agda"
description: "More Logic in PL"
author: "cvlad"
---

# Introduction

I previously showed some fun
[classical logic proofs in Haskell](/clasical-logic-in-haskell/), thanks to the
Curry-Howard correspondence.

This post will go a bit further than that and show the type theoretic
equivalents of existential and universal quantifiers. I'll then explore some
interesting properties of these types.

## Quantifiers in Logic

First-order logic comes with two quantifiers: ∀ (forall) and ∃ (exists).

Forall is generally written as
```
∀ x. P x
```
where `x` is a variable and `P` is a predicate taking such a variable. A basic
example of such a proposition could be: "For all numbers x, if you add one to
x, you get a greater number than x", or:
```
∀ x. x + 1 > x
```

Similarly, exists is written as
```
∃ x. P x
```
where `x` is a variable and `P` is a predicate, for example: "there exists a
number that is greater than 10", or:
```
∃ x. x > 10
```

## Dependent Sum

Dependent sums (Σ) are the type theoretic equivalent of existential quantifiers.
In Agda, we can define the dependent sum type as:
```haskell
data Σ {A : Set} (P : A → Set) : Set where
    Σ_intro : ∀ (a : A) → P a → Σ P
```

The ∑ type is a higher-kinded type which takes a higher-kinded type,
`P : A → Set` -- `P` takes an `A` and gives us a new type (`Set`, in Agda). The
nice part about this is that `P` holds information about both the type of the
existential variable (`A`) as well as the type of the resulting proposition
(`P A`).

Constructing such a term requires a term of the existential type (_evidence_ for
`A`), and a term of the predicate type (_evidence_ for `P A`). For example, the
example above could be written as `∑_intro 11 (11 > 10)`, assuming there
exists a type `>` which expresses the greater-then relationship.

## Dependent Product

Dependent products (∏) are the type theoretic equivalent of universal
quantifiers. In Agda, we can define the dependent product type as:
```haskell
data Π {A : Set} (P : A → Set) : Set where
    Π_intro : (∀ (a : A) → P a) → Π P
```

The ∏ type is also a higher-kinded type. Its type is identical to the ∑ type.

Constructing a ∏ type takes a function from the quantified variable to the
type described by the predicate. 

Constructing a term would, for example be `∏_intro (λn. n + 1 > n)`.

## Tuples - Special Case of Dependent Sum

We will first need to define a `const` function:
```haskell
const : ∀ (X : Set) (Y : Set) → Y → Set
const x _ _ = x
```

This takes two types, `X` and `Y`. It then takes a value of type `Y`, and
ignores it, returning the type `X`.

So, if we take `P` to *not* depend on the quantified item and define it using
`const`, then we can obtain tuples in the case of ∑ types:
```haskell
data tuple (A : Set) (B : Set) : Set where
    tuple_intro : Σ (const B A) → tuple A B

pair : ∀ {A : Set}  {B : Set} → A → B → tuple A B
pair a b = tuple_intro (Σ_intro a b)

fst : ∀ {A : Set} {B : Set} → tuple A B → A
fst (tuple_intro (Σ_intro a _)) = a

snd : ∀ {A : Set} {B : Set} → tuple A B → B
snd (tuple_intro (Σ_intro _ b)) = b
```

## Functions - Special Case of Dependent Product

Similarly, if we take `P` to be `const B A`, we can obtain functions out of
∏ types:

```haskell
data fun (A : Set) (B : Set) : Set where
fun_intro : Π (const B A) → exp A B

abs : ∀ {A : Set} {B : Set} → (A → B) → exp A B
abs f = fun_intro (Π_intro f)

app : ∀ {A : Set} {B : Set} → exp A B → A → B
app (fun_intro (Π_intro f)) a = f a
```

## What About Sum Types?

We can obtain sum types from ∑ types by using `Bool` as the variable type, and
the predicate _returning_ type `A` for `true`, and type `B` for `false`:

```haskell
sumPredicate : ∀ (A B : Set) → Bool → Set
sumPredicate a _ true = a
sumPredicate _ b false = b

data Σ+ (A : Set) (B : Set) : Set where
    Σ+_intro : Σ (sumPredicate A B) → Σ+ A B

Σ+left : ∀ {A : Set} (B : Set) → A → Σ+ A B
Σ+left _ a = Σ+_intro (Σ_intro true a)

Σ+right : ∀ {B : Set} (A : Set) → B → Σ+ A B
Σ+right _ b = Σ+_intro (Σ_intro false b)

Σ+elim : ∀ {A B C : Set} → (A → C) → (B → C) → Σ+ A B → C
Σ+elim f _ (Σ+_intro (Σ_intro true  a)) = f a
Σ+elim _ g (Σ+_intro (Σ_intro false b)) = g b
```

Interestingly, we can also obtain sum types from ∏ types.
