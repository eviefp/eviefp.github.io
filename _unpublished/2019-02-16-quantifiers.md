---
title: "Quantifiers in Agda"
description: "More Logic in PL"
author: "cvlad"
---

# Introduction

I previously showed a [single proof](/curry-howard) in logic, type theory,
and category theory, and some fun
[classical logic proofs in Haskell](/clasical-logic-in-haskell/), thanks to the
Curry-Howard correspondence.

This post will go a bit further than that and show the type theoretic
equivalents of existential and universal quantifiers. I'll then explore some
interesting properties of these types. This post will not go into the
category theory part of this, although I may do that in a future post.

## Quantifiers in Logic

Forall (∀) is the universal quantifier and is generally written as
```
∀ x. P x
```
where `x` is a variable and `P` is a predicate taking such a variable. A basic
example of such a proposition could be: _"For all numbers x, if you add one to
x, you get a greater number than x"_, or:
```
∀ x. x + 1 > x
```

Similarly, exists (∃) is the existential quantifier and is written as
```
∃ x. P x
```
where `x` is a variable and `P` is a predicate, for example: _"there exists a
number that is greater than 10"_, or:
```
∃ x. x > 10
```

Please note that in classical logic, you can prove an existential proposition by
either finding an `x` for which `P(x)` is _true_, or by assuming there does not
exist such an `x` and reaching a contradiction (
[proof by contradiction](https://en.wikipedia.org/wiki/Proof_by_contradiction)).
In _intuitionistic_ logic, the latter is not possible: we have to find the `x`.
One could then say that an existential quantifier in intuitionistic logic is
described by a pair of `x` and `P(x)`.

In the next chapter, we will look at dependent sum and I will say it's the
Curry-Howard correspondent of existential quantifiers. Most theorem provers that
rely on this correspondence will use make use of 
[proof irrelevance](https://www.cs.cmu.edu/~fp/courses/15317-f08/lectures/08-irrelevance.pdf)
which essentially means that it should not matter whether one picks `11` or `12`
in order to to prove `∃ x. x > 10`: the proofs should be equivalent. We will not
look into this, nor will we make use of proof irrelevance in this post.

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
existential variable (`A`) as well as the type of the resulting type (`P A`).

Constructing such a term requires a term of the existential type (_evidence_ for
`A`), and a term of the predicate type (_evidence_ for `P A`). For example, the
example above could be written as `∑_intro 11 (11 > 10)`, assuming there
exists a type `>` which expresses the greater-than relationship.

Please note that the above example is a simplification and going into the
details of how an inductive type for `>` works is beyond the scope of this post.

## Dependent Product

Dependent products (∏) are the type theoretic equivalent of universal
quantifiers. In Agda, we can define the dependent product type as:
```haskell
data Π {A : Set} (P : A → Set) : Set where
    Π_intro : (∀ (a : A) → P a) → Π P
```

The ∏ type is also a higher-kinded type. Note that this definition is almost
identical to the Σ definition, except for the parantheses used in the
constructor (`Π_intro`). This lines up with the intuition that `∀x. P(X)` can
be described by a function `A -> P(x)`, where `x : A`.

Constructing a ∏ type takes a function from the quantified variable to the
type described by the predicate.

Constructing a term would, for example be `∏_intro (λn. n + 1 > n)`.

## Tuples - Special Case of Dependent Sum

We will first need to define a `constT` function:
```haskell
constT : ∀ (X : Set) (Y : Set) → Y → Set
constT x _ _ = x
```

This takes two types, `X` and `Y`. It then takes a value of type `Y`, and
ignores it, returning the type `X`.

So, if we take `P` to *not* depend on the quantified item and define it using
`constT`, then we can obtain tuples in the case of ∑ types:
```haskell
data Σ-pair (A B : Set) : Set where
    Σ-pair_intro : Σ (constT B A) → Σ-pair A B
```

We can then define a simple pair constructor using the constructor above:
```haskell
Σ-mkPair : ∀ {A : Set}  {B : Set} → A → B → Σ-pair A B
Σ-mkPair a b = Σ-pair_intro (Σ_intro a b)
```

And we can have the two projections by simple pattern match, returning the
appropriate value:
```haskell
Σ-fst : ∀ {A B : Set} → Σ-pair A B → A
Σ-fst (Σ-pair_intro (Σ_intro a _)) = a

Σ-snd : ∀ {A B : Set} → Σ-pair A B → B
Σ-snd (Σ-pair_intro (Σ_intro _ b)) = b
```

This works because Σ types are defined as `a -> P a -> Σ P`, so if we take a 
`P` such that `P a` always is `b`, then we get `a -> b -> Σ` which is
essentially a tuple of `a` and `b`.

We can now say `Σ_snd (Σ_mkPair 1 2)` and get the result `2`.

## Functions - Special Case of Dependent Product

Similarly, if we take `P` to be `const B A`, we can obtain functions out of
∏ types:
```haskell
data Π-function (A B : Set) : Set where
    Π-function_intro : Π (constT B A) → Π-function A B

Π-mkFunction : ∀ {A B : Set} → (A → B) → Π-function A B
Π-mkFunction f = Π-function_intro (Π_intro f)

Π-apply : ∀ {A B : Set} → Π-function A B → A → B
Π-apply (Π-function_intro (Π_intro f)) a = f a
```

As with sum types, this works because Π types are defined as `(a -> P a) -> Π P`,
so if we take `P` such that `P a` always is `b`, then we get `(a -> b) -> Π`,
which is essentially a function from `a` to `b`.

We can now write `Π-apply (Π-mkFunction (λx. x + 1)) 1` and get the result `2`.

## What About Sum Types?

We can obtain sum types from ∑ types by using `Bool` as the variable type, and
the predicate _returning_ type `A` for `true`, and type `B` for `false`:
```haskell
bool : ∀ (A B : Set) → Bool → Set
bool a _ true  = a
bool _ b false = b
```

Note that `a` and `b` are types! We can now write:
```haskell
data Σ-sum (A B : Set) : Set where
    Σ-sum_intro : Σ (bool A B) → Σ-sum A B
```

Now, in order to construct such a type (via _left_ or _right_), we just need
to pass the appropriate boolean value along with an item of the correct type:
```haskell
Σ-sum_left : ∀ {A : Set} (B : Set) → A → Σ-sum A B
Σ-sum_left _ a = Σ-sum_intro (Σ_intro true a)

Σ-sum_right : ∀ {B : Set} (A : Set) → B → Σ-sum A B
Σ-sum_right _ b = Σ-sum_intro (Σ_intro false b)
```

Eliminating is just a matter of pattern matching on the boolean value and
applying the correct function:
```haskell
Σ-sum_elim : ∀ {A B R : Set} → (A → R) → (B → R) → Σ-sum A B → R
Σ-sum_elim f _ (Σ-sum_intro (Σ_intro true  a)) = f a
Σ-sum_elim _ g (Σ-sum_intro (Σ_intro false b)) = g b
```

As an example, `Σ-sum_elim (const "left") (const "right") (Σ-sum_left Bool 1)`,
and get the result `"left"`.

Interestingly, we can also obtain sum types from ∏ types: the idea is to encode
the eliminator right into our type! For that we will need the following
predicate:
```haskell
prodPredicate : ∀ (A B R : Set) → Set
prodPredicate a b r = (a → r) → (b → r) → r
```

This means that given two types `A` and `B`, we get a type-level function from
`R` to `(A -> R) -> (B -> R) -> R`, which is exactly the eliminator type. Don't
worry about `Set₁` or `Π'` for now:

```haskell
data Π-sum (A B : Set) : Set₁ where
    Π-sum_intro : Π' (prodPredicate A B) → Π-sum A B
```

This means that in order to build a sum type, we need to pass a type `R` and
a function `(A -> R) -> (B -> R) -> R`. So, the constructors will look like:

```haskell
Π-sum-left : ∀ {A : Set} (B : Set) → A → Π-sum A B
Π-sum-left _ a = Π-sum_intro (Π'_intro (\_ f _ → f a))
```

The lambda is the only interesting bit: we construct a function that given a
type `R` (first `_`) and a function `A -> R` (named `f`), we can return an `R`
by calling `f a` (the third `_` parameter is for the function `g : B -> R`,
which is not required for the _left_ constructor).

Similarly, we can write a constructor for _right_:

```haskell
Π-sum-right : ∀ {A : Set} (B : Set) → B → Π-sum A B
Π-sum-right _ b = Π-sum_intro (Π'_intro (\_ _ g → g b))
```

As for the eliminator, we simply require the two functions `A -> R` and `B -> R`
in order to pass to our dependent product and get an `R`:
```haskell
Π-sum-elim : ∀ {A B R : Set} → (A → R) → (B → R) → Π-sum A B → R
Π-sum-elim f g (Π-sum_intro (Π'_intro elim)) = elim _ f g
```
