---
title: "Lean, Advent of Code and Sigma Types"
author: Evie Ciobanu
date: Dec 22, 2023
tags: [lean, advent-of-code, dependent-types]
description: "TODO"
---

I've been doing this year's [Advent of Code](https://adventofcode.com) in [Lean4](https://lean-lang.org/). If you're unfamiliar, it's a dependently language that's both a functional programming language and a theorem prover. But before I go any further, let me take a brief moment to cover some of the basics. Feel free to skip this part if you're familiar with dependent types and sized vectors.


## Sized vectors

Dependent languages, or languages that allow type-level natural numbers, allow you to store the size of a vector into its type:

```haskell
inductive Vector (α: Type): Nat → Type where
  | nil : Vector α 0
  | cons: α → Vector α n → Vector α (n + 1)
```

If you're unfamiliar with Lean syntax, it's essentially declaring a new type called `Vector`, which takes two arguments: an `α` which is the type of the elements the vector will hold, and a `Nat`, which stands for natural numbers. The result is a `Type`, which is essentially the type of `Vector α n`, for example `Vector Bool 3` is a vector of 3 booleans.

The following two lines are the two constructors: `nil` which creates a vector of size 0 with no values, and `cons`, which takes one more value (the single `α`), and a vector of size `n` to create a vector of size `n + 1`.

What this means is, an empty, or `nil` vector will *always* have a size of 0, because you can't construct it otherwise. Similarly, whatever the size of the vector, it will always have that many elements in it.

Here are a few quick examples:

```haskell
def empty   : Vector Bool 0 := nil
def oneBool : Vector Bool 1 := cons true nil
def twoBools: Vector Bool 2 := cons true (cons false nil)
```

If we ask for the element at some position, as long as that number is smaller than the natural parameter of the Vector, we can always just grab it! Lean has a type that helps with that: `Fin` carries a natural number, and the _proof_ that it is **smaller** than some other natural number, **n**:

```haskell
structure Fin (n : Nat) where
  val  : Nat
  isLt : LT.lt val n     -- LT stands for Lower Than; this reads as 'val < n'
```

Which means we can now write a `get` function for our vector type:

```haskell
def get: Fin n → Vector α n → α
  | ⟨0    , h⟩, .cons x xs ⇒ x
  | ⟨i + 1, h⟩, .cons x xs ⇒ get ⟨i, Nat.le_of_succ_le_succ h⟩ xs
```

How this works out is:

- you cannot write `Fin 0` because you can't create a proof that any *natural* number is smaller than 0
- which, in turn means, there's no missing case for `.nil`: it's impossible to call this function on an empty vector!
- if we reached 0 (the value stored in `Fin n`; `n` can never be 0!), we'll just return the top element of the (deconstructed) vector
- otherwise, we recursively call `get` with `i - 1` (or, rather, match on `i + 1` and call it with `i`)
- since `xs` now has size `n - 1`, we need to also construct a `Fin (n - 1)`
- we need to create the proof that `i - 1 < n - 1`, given `h: i < n`
- that proof already exists, and that's `Nat.le_of_succ_le_succ`
- we know `Fin n` and `Vector α n` have the same `n`, so we can never reach 0 before running out of Vector `cons` or values

Whew! There's a lot going in in those packed 2 lines of code.

And before we move on, I just have to share this:

```haskell
def length: Vector α n → Nat := λ _ ⇒ n
```

Normally, with a list, we'd need to iterate through all of it to find its length. However, since we keep track of the size of the vector in its type, and well, Lean is a dependently typed language, we can just grab that `n` from Vector's type and return it as a value!

It seems so natural, and yet, it's either impossible or requires quite some elaborate tricks in languages without dependent type support.

## Back to Advent of Code

This year's Advent of Code (AoC) featured quite a few puzzles where a `Grid` type comes in handy, specifically when a rectangular map is a reasonable way to model the problem. For example, if you wanted to represent a cell that can either be a wall or an empty space, one can easily write

```haskell
inductive Cell where
  | Wall
  | Space
```

And there's plenty of ways to represent a map, such as:

- a list of lists
- a (hash)map of coordinates to cell
- a function from coordinate to cell

However, I went for a 2D vector, and since not all grids (/maps) are square, it'll need both a width (x) and a height (y):

```haskell
structure Grid (x: Nat) (y: Nat) (α: Type) where
  data: Vector (Vector α x) y
```

So once I wrote this and a few helper functions, I was ready to start using it. And naturally, I wanted to write a parser to read up the input for the day's puzzle:

```haskell
def parseInput: Parsec (Grid x y Cell) := ...
```

But, whoops. This won't work. `x` and `y` are universally quantified, which means that the **caller** of `parseInput` gets to decide what they are. However, it's not up to them! It's up to `parseInput` to read the input file and figure out `x` and `y`. So, essentially, they need to be existentially quantified. In other words, they are *outputs* and not *inputs*.

And well, thanks to being used with Haskell and other non-dependently typed languages, I've been going for a different approach until today:

```haskell
def parseInput: Parsec (List (List Cell)) := ...

-- ...

def solve (inputs: List (List Cell)): Nat :=
  -- convert the list of lists to a grid
  -- and use the grid here
  -- in this context we know `x` and `y` so it's fine
```

## Sigma types to the rescue!

But all the awkwardness of passing in that list of lists instead of a grid finally caught up to me, and today I spent more than a few seconds thinking about it, and well, I decided to see whether an existential type would work. I haven't gotten to use Lean that much yet, but I do remember seeing this type, which looks like what I need:

```haskell
structure Sigma {α : Type u} (β : α → Type v) where
  fst : α
  snd : β fst
```

Let me explain the syntax for a bit: the curly braces mean "implicit argument", which basically means, Lean will figure it out on its own from the other arguments -- in this case, the second argument named `β`.

And what is `β`? A type-level function that takes an `α` and returns a type.

And this sounds exactly like what we want: we have our `Grid` type which takes two naturals, but we don't want to use them explicitly, so what if we wrote:

```haskell
def SomeGrid (pair: Nat × Nat): Type :=
  Grid pair.fst pair.snd Cell
```

This basically says, give me a pair of natural numbers, and I'll give you a type. That type is a `Grid` where the `x` is the first part of the pair, and the `y` is the second. And yes, since types and values live at the same level, we don't need special syntax to define type-level functions: we can write it like any other function.

And now, we can write our parser like this:

```haskell
def parseGrid: Parsec (Sigma SomeGrid) := ...
```

... and the awesome thing is, we can grab any `Sigma SomeGrid` value and use it as a regular pair:

- its `fst` argument will just be a pair of natural numbers which represent the size of the grid
- its `snd` argument is our `Grid x y Cell`

I'll admit I was rather surprised to see that it all worked as simply as I expected, without any surprises or hard-to-read type-level errors. It might just be the case that my Haskell experience trying to play with dependent types has scared me a bit too much, so I'm looking forward to using Lean a bit more!

And since I've mentioned it, my full advent of code solutions up to today (day 22) are on github: https://github.com/eviefp/lean4-aoc2023
