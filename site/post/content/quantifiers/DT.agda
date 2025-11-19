open import Agda.Primitive
open import Agda.Builtin.Nat
open import Agda.Builtin.Bool

-----------------------------------------------------
-- Σ types
-----------------------------------------------------
data Σ {A : Set} (P : A → Set) : Set where
    Σ_intro : ∀ (a : A) → P a → Σ P

-----------------------------------------------------
-- Π type
-----------------------------------------------------
data Π {A : Set} (P : A → Set) : Set where
    Π_intro : (∀ (a : A) → P a) → Π P

-----------------------------------------------------
-- constT
-----------------------------------------------------
constT : ∀ (X : Set) (Y : Set) → Y → Set
constT x _ _ = x

-----------------------------------------------------
-- Tuples using Σ types (const)
-----------------------------------------------------
Σ-pair : ∀ (A B : Set) → Set
Σ-pair a b = Σ (constT b a)

Σ-mkPair : ∀ {A : Set}  {B : Set} → A → B → Σ-pair A B
Σ-mkPair a b = Σ_intro a b

Σ-fst : ∀ {A B : Set} → Σ-pair A B → A
Σ-fst (Σ_intro a _) = a

Σ-snd : ∀ {A B : Set} → Σ-pair A B → B
Σ-snd (Σ_intro _ b) = b

-----------------------------------------------------
-- Exponential using Π type (const)
-----------------------------------------------------
Π-function : ∀ (A B : Set) → Set
Π-function a b = Π (constT b a)

Π-mkFunction : ∀ {A B : Set} → (A → B) → Π-function A B
Π-mkFunction f = Π_intro f

Π-apply : ∀ {A B : Set} → Π-function A B → A → B
Π-apply (Π_intro f) a = f a

-----------------------------------------------------
-- bool
-----------------------------------------------------
bool : ∀ (A B : Set) → Bool → Set
bool a _ true  = a
bool _ b false = b

-----------------------------------------------------
-- Sum type using Σ types
-----------------------------------------------------
Σ-sum : ∀ (A B : Set) → Set 
Σ-sum a b = Σ (bool a b)

Σ-sum_left : ∀ {A : Set} (B : Set) → A → Σ-sum A B
Σ-sum_left _ a = Σ_intro true a

Σ-sum_right : ∀ {B : Set} (A : Set) → B → Σ-sum A B
Σ-sum_right _ b = Σ_intro false b

Σ-sum_elim : ∀ {A B R : Set} → (A → R) → (B → R) → Σ-sum A B → R
Σ-sum_elim f _ (Σ_intro true  a) = f a
Σ-sum_elim _ g (Σ_intro false b) = g b

-----------------------------------------------------
-- prodPredicate
-----------------------------------------------------
prodPredicate : ∀ (A B R : Set) → Set
prodPredicate a b r = (a → r) → (b → r) → r

-----------------------------------------------------
-- Sum type using Π types
-----------------------------------------------------
data Π' {a b} {A : Set a} (P : A → Set b) : Set (a ⊔ b) where
    Π'_intro : (∀ (a : A) → P a) → Π' P

Π-sum : ∀ (A B : Set) → Set₁
Π-sum a b = Π' (prodPredicate a b)

Π-sum-left : ∀ {A : Set} (B : Set) → A → Π-sum A B
Π-sum-left _ a = Π'_intro (\_ f _ → f a)

Π-sum-right : ∀ {A : Set} (B : Set) → B → Π-sum A B
Π-sum-right _ b = Π'_intro (\_ _ g → g b)

Π-sum-elim : ∀ {A B R : Set} → (A → R) → (B → R) → Π-sum A B → R
Π-sum-elim f g (Π'_intro elim) = elim _ f g

-----------------------------------------------------
-- Extra: Tuples using Π types
-----------------------------------------------------
Π-pair : ∀ (A B : Set) → Set
Π-pair a b = Π (bool a b)

Π-mkPair : ∀ {A B : Set} → A → B → Π-pair A B
Π-mkPair a b = Π_intro f
    where
    f : (b : Bool) → bool _ _ b
    f true = a
    f false = b

Π-fst : ∀ {A B : Set} → Π-pair A B → A
Π-fst (Π_intro f) = f true

Π-snd : ∀ {A B : Set} → Π-pair A B → B
Π-snd (Π_intro f) = f false

---
-- ??
--

data Σ' {a b} {A : Set a} (P : A → Set b) : Set (a ⊔ b) where
    Σ'_intro : ∀ (a : A) → P a → Σ' P

id : ∀ {A : Set} → A → A
id a = a

x : ∀ (A : Set) → Set1
x a = Σ (\(b : Set1) → (a → b))


mk : ∀ (A B : Set) → A → x A B
mk _ b a' = Σ'_intro b (\f g → f (g a'))

elim : {A B : Set} → (A → B) → x A B → B
elim f (Σ'_intro _ g) = g id f

 -- : ∀ {A : Set} (B : Set) → A → Π-sum A B
--Π-sum-left _ a = Π'_intro (\_ f _ → f a)
--
--Π-sum-right : ∀ {A : Set} (B : Set) → B → Π-sum A B
--Π-sum-right _ b = Π'_intro (\_ _ g → g b)
--
--Π-sum-elim : ∀ {A B R : Set} → (A → R) → (B → R) → Π-sum A B → R
--Π-sum-elim f g (Π'_intro elim) = elim _ f g
