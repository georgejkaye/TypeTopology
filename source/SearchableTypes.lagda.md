```agda
{-# OPTIONS --without-K --exact-split #-}


open import SpartanMLTT
open import UF-FunExt
open import UF-Subsingletons

module SearchableTypes (fe : FunExt) (pe : PropExt) where

open import Two-Properties public hiding (zero-is-not-one)
open import NaturalsOrder public
open import NaturalsAddition public renaming (_+_ to _+ℕ_)
open import IntegersB public
open import IntegersOrder public
open import IntegersAddition public renaming (_+_ to _+ℤ_)
open import IntegersNegation public renaming (-_  to  −ℤ_)
open import UF-Subsingletons public
open import NaturalsOrder public
open import DecidableAndDetachable
open import UF-Equiv
open import UF-Subsingletons-FunExt
open import InfiniteSearch1 (dfunext (fe _ _))
  hiding (predicate;everywhere-decidable;decidable;trivial-predicate)

nonempty : 𝓤 ̇ → 𝓤 ̇ 
nonempty = id

```

We start with decidable predicates on a given type.

```agda
everywhere-prop-valued : {𝓦 𝓤 : Universe} {X : 𝓤 ̇}
                       → (X → 𝓦 ̇ ) → 𝓦 ⊔ 𝓤 ̇
everywhere-prop-valued {𝓦} {𝓤} {X} p 
 = Π x ꞉ X , is-prop (p x)

predicate : {𝓦 𝓤 : Universe} {X : 𝓤 ̇} → (𝓦 ⁺) ⊔ 𝓤 ̇
predicate {𝓦} {𝓤} {X} 
 = Σ p ꞉ (X → 𝓦 ̇ ) , everywhere-prop-valued p

everywhere-decidable : {𝓦 𝓤 : Universe} {X : 𝓤 ̇}
                     → (X → 𝓦 ̇ ) → 𝓦 ⊔ 𝓤 ̇
everywhere-decidable {𝓦} {𝓤} {X} p
 = Π x ꞉ X , decidable (p x)

decidable-predicate : {𝓦 𝓤 : Universe} → 𝓤 ̇ → (𝓦 ⁺) ⊔ 𝓤 ̇
decidable-predicate {𝓦} {𝓤} X
 = Σ p ꞉ (X → 𝓦 ̇ )
 , everywhere-decidable p × everywhere-prop-valued p
```

Some predicates use equivalence relations to determine
information about the predicate.

We define equivalence relations in the usual way.

```agda
record equivalence-relation {𝓥 𝓤 : Universe} (X : 𝓤 ̇ ) : 𝓤 ⊔ 𝓥 ⁺ ̇
  where field
    _≣_ : X → X → 𝓥 ̇
    ≣-refl  : (x     : X) → x ≣ x
    ≣-sym   : (x y   : X) → x ≣ y → y ≣ x
    ≣-trans : (x y z : X) → x ≣ y → y ≣ z → x ≣ z

open equivalence-relation
```

The class of predicates quotiented (?) by a particular
equivalence relation is defined as follows.

```agda
_informs_ : {𝓦 𝓤 𝓥 : Universe} {X : 𝓤 ̇ }
          → equivalence-relation {𝓥} X
          → decidable-predicate {𝓦} X → 𝓦 ⊔ 𝓤 ⊔ 𝓥 ̇
A informs (p , _) = ∀ x y → x ≣A y → p x → p y
 where _≣A_ = _≣_ A

decidable-predicate-informed-by
 : {𝓦 𝓤 𝓥 : Universe} {X : 𝓤 ̇ }
 → equivalence-relation {𝓥} X
 → 𝓤 ⊔ 𝓥 ⊔ 𝓦 ⁺ ̇ 
decidable-predicate-informed-by {𝓦} {𝓤} {𝓥} {X} A
 = Σ p ꞉ decidable-predicate {𝓦} X
 , A informs p
```

Trivially, identity informs every predicate.

```agda
Identity : (X : 𝓤 ̇ ) → equivalence-relation {𝓤} {𝓤} X
_≣_     (Identity X)       = _≡_
≣-refl  (Identity X) x     = refl
≣-sym   (Identity X) x y   = _⁻¹
≣-trans (Identity X) x y z = _∙_

Id-informs-everything : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
                      → (p : decidable-predicate {𝓦} X)
                      → Identity X informs p
Id-informs-everything p x x refl = id
```

Therefore, decidable predicates on X are equivalent to decidable
predicates on X informed by identity; the quotienting by _≡_ does not
remove any decidable predicates.

```agda
informs-is-prop : {𝓦 𝓥 𝓤 : Universe} {X : 𝓤 ̇ }
                → (A : equivalence-relation {𝓥} X)
                → (p : decidable-predicate {𝓦} X)
                → is-prop (A informs p)
informs-is-prop A (p , _ , i)
 = Π-is-prop (fe _ _)
     (λ _ → Π-is-prop (fe _ _)
       (λ y → Π-is-prop (fe _ _)
         (λ _ → Π-is-prop (fe _ _)
           (λ _ → i y))))

to-subtype-≃ : {X : 𝓦 ̇ } {A : X → 𝓥 ̇ }
             → ((x : X) → A x × is-prop (A x))
             → X ≃ Σ A
to-subtype-≃ {_} {_} {X} {A} fi
 = (λ x → x , f x)
 , ((pr₁ , λ (x , Ax) → ap (x ,_) (i x (f x) Ax))
 , ( pr₁ , λ _ → refl))
 where
   f = λ x → pr₁ (fi x)
   i = λ x → pr₂ (fi x)

to-subtype-≃' : {X : 𝓤 ̇ } {A : X → 𝓥 ̇ } {B : X → 𝓥' ̇ }
              → ((x : X) → A x → B x)
              → ((x : X) → B x → A x)
              → ((x : X) → is-prop (A x))
              → ((x : X) → is-prop (B x))
              → Σ A ≃ Σ B
to-subtype-≃' f' g' i j
 = f
 , (g , (λ (x , Bx) → to-subtype-≡ j refl))
 , (g , (λ (x , Ax) → to-subtype-≡ i refl))
 where
   f = λ (x , Ax) → x , (f' x Ax)
   g = λ (x , Bx) → x , (g' x Bx)

decidable-predicate-≃ : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
                      → decidable-predicate  {𝓦} X
                      ≃ decidable-predicate-informed-by {𝓦} (Identity X)
decidable-predicate-≃ {𝓦} {𝓤} {X}
 = to-subtype-≃
     (λ p → Id-informs-everything p , informs-is-prop (Identity X) p)
```

We can also define a trivial equivalence relation that identifies
everything.

```agda
Trivial : {𝓥 𝓤 : Universe} (X : 𝓤 ̇ ) → equivalence-relation {𝓥} {𝓤} X
_≣_     (Trivial X)           = λ _ _ → 𝟙
≣-refl  (Trivial X) x         = ⋆
≣-sym   (Trivial X) x y   _   = ⋆ 
≣-trans (Trivial X) x y z _ _ = ⋆ 
```

The trivial predicate that satisfies everything, and the empty
predicate that satisfies nothing, is informed by the trivial
equivalence relation.

```agda
trivial-predicate : {𝓦 𝓤 : Universe} → (X : 𝓤 ̇ )
                  → decidable-predicate {𝓦} X
trivial-predicate X = (λ x → 𝟙) , (λ x → inl ⋆)    , (λ x → 𝟙-is-prop)

empty-predicate : {𝓦 𝓤 : Universe} → (X : 𝓤 ̇ )
                → decidable-predicate {𝓦} X
empty-predicate   X = (λ x → 𝟘) , (λ x → inr λ ()) , (λ x → 𝟘-is-prop)

Trivial-informs-trivial
 : {𝓦 𝓥 𝓤 : Universe} {X : 𝓤 ̇ }
 → (Trivial {𝓥} X) informs trivial-predicate {𝓦} X
Trivial-informs-trivial _ _ _ _ = ⋆

Trivial-informs-empty
 : {𝓦 𝓥 𝓤 : Universe} {X : 𝓤 ̇ }
 → (Trivial {𝓥} X) informs empty-predicate {𝓦} X
Trivial-informs-empty _ _ _ ()

trivial-not-empty : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
                  → nonempty X
                  → trivial-predicate {𝓦} X
                  ≢   empty-predicate {𝓦} X
trivial-not-empty {𝓦} {𝓤} {X} x t≡e = ¬px ⋆
 where
   ¬px : ¬ pr₁ (trivial-predicate {𝓦} X) x
   ¬px = transport (λ - → ¬ (pr₁ -) x) (t≡e ⁻¹) λ ()
```

In fact, these are the *only* predicates informed by the trivial
equivalence relation.

```agda
use-propext : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
            → (p p' : X → 𝓦 ̇ )
            → everywhere-prop-valued p
            → everywhere-prop-valued p'
            → ((x : X) → p x ⇔ p' x)
            → p ≡ p'
use-propext {𝓦} p p' i i' γ
 = dfunext (fe _ _) (λ x → pe 𝓦 (i x) (i' x) (pr₁ (γ x)) (pr₂ (γ x)))

¬-is-prop : {X : 𝓤 ̇ } → is-prop (¬ X)
¬-is-prop = Π-is-prop (fe _ _) (λ _ → 𝟘-is-prop)

everywhere-decidable-is-prop : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
                             → (p : X → 𝓦 ̇ )
                             → everywhere-prop-valued p
                             → is-prop (everywhere-decidable p)
everywhere-decidable-is-prop p i
 = Π-is-prop (fe _ _)
     (λ x → +-is-prop (i x) ¬-is-prop (λ px ¬px → ¬px px))

is-prop-is-prop : {X : 𝓤 ̇ } → is-prop X → is-prop (is-prop X)
is-prop-is-prop i
 = Π-is-prop (fe _ _)
     (λ _ → Π-is-prop (fe _ _) (λ _ → props-are-sets i))

everywhere-prop-valued-is-prop : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
                               → (p : X → 𝓦 ̇ )
                               → everywhere-prop-valued p
                               → is-prop (everywhere-prop-valued p)
everywhere-prop-valued-is-prop p i
 = Π-is-prop (fe _ _) (λ x → is-prop-is-prop (i x))

decidable-predicate-≡
 : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
 → ((p , d , i) (p' , d' , i') : decidable-predicate {𝓦} X)
 → ((x : X) → p x ⇔ p' x)
 → (p , d , i) ≡ (p' , d' , i')
decidable-predicate-≡ (p , d , i) (p' , d' , i') γ
 = to-subtype-≡
     (λ p (pd , pi) (pd' , pi')
      → ×-is-prop
          (everywhere-decidable-is-prop p pi)
          (everywhere-prop-valued-is-prop p pi)
          (pd , pi) (pd' , pi'))
     (use-propext p p' i i' γ)
```

Any predicate on 𝟘 is empty.

```agda
predicate-on-𝟘-is-empty : (p : decidable-predicate {𝓦} (𝟘 {𝓤}))
                        → p ≡ empty-predicate {𝓦} (𝟘 {𝓤})
predicate-on-𝟘-is-empty (p , d , i)
 = decidable-predicate-≡ (p , d , i) (empty-predicate 𝟘) (λ ())

constant-predicate : {𝓦 𝓤 : Universe} (X : 𝓤 ̇ ) → (𝓦 ⁺) ⊔ 𝓤 ̇
constant-predicate {𝓦} {𝓤} X
 = Σ (p , _) ꞉ decidable-predicate {𝓦} X
 , ((x : X) → p x) + ((x : X) → ¬ p x)

constant-predicates-are-trivial-or-empty
 : {𝓦 𝓥 𝓤 : Universe} {X : 𝓤 ̇ }
 → ((p , _) : constant-predicate {𝓦} X)
 → (x : X)
 → (p ≡ trivial-predicate {𝓦} X) + (p ≡ empty-predicate {𝓦} X)
constant-predicates-are-trivial-or-empty {𝓦} {𝓥} {𝓤} {X}
 ((p , d , i) , (inl f)) x
 = inl (decidable-predicate-≡ (p , d , i) (trivial-predicate X)
         (λ x → (λ _ → ⋆) , (λ _ → f x)))
constant-predicates-are-trivial-or-empty {𝓦} {𝓥} {𝓤} {X}
 ((p , d , i) , (inr g)) x
 = inr (decidable-predicate-≡ (p , d , i) (empty-predicate   X)
         (λ x → 𝟘-elim ∘ g x , λ ()))
         
trivial-no-info
 : {𝓦 𝓥 𝓤 : Universe} {X : 𝓤 ̇ } → (x : X)
 → constant-predicate {𝓦} X
 ≃ decidable-predicate-informed-by {𝓦} (Trivial {𝓥} X)
trivial-no-info x
 = to-subtype-≃'
     (λ (p , d , i) → cases
       (λ f _ y _ _  → f y)
       (λ g x _ _ px → 𝟘-elim (g x px)))
     (λ (p , d , i) Tp → Cases (d x)
       (λ  px → inl (λ y    →      Tp x y ⋆ px))
       (λ ¬px → inr (λ y py → ¬px (Tp y x ⋆ py))))
     (λ (p , d , i) → +-is-prop
       (Π-is-prop (fe _ _) i)
       (Π-is-prop (fe _ _) (λ _ → ¬-is-prop))
       (λ f g → g x (f x)))
     (informs-is-prop (Trivial _))
```

So quotienting a universe of predicates on X by identity does nothing,
and doing so by the trivial equivalence relation removes every
non-constant predicate.

Let's look at some other equivalence relations and see what predicates
fall out of the quotienting.

So-called 'continuous' predicates as defined by closeness functions
are informed by a particular equivalence relation.

First, recall our definition of closeness functions.

```agda
record closeness-function (X : 𝓤 ̇ ) : 𝓤 ̇ where
  field
    c : X × X → ℕ∞ 
    eic : (x     : X) → c (x , x) ≡ ∞
    ice : (x y   : X) → c (x , y) ≡ ∞ → x ≡ y
    sym : (x y   : X) → c (x , y) ≡ c (y , x)
    ult : (x y z : X) → min (c (x , y)) (c (y , z)) ≼ c (x , z)

≼-min : ∀ x y z → x ≼ y → x ≼ z → x ≼ min y z
≼-min x y z x≼y x≼z n r = Lemma[a≡₁→b≡₁→min𝟚ab≡₁] (x≼y n r) (x≼z n r)

≼-min2 : ∀ x y z w → x ≼ z → y ≼ w → min x y ≼ min z w
≼-min2 x y z w x≼z y≼w n r
 = Lemma[a≡₁→b≡₁→min𝟚ab≡₁] (x≼z n (Lemma[min𝟚ab≡₁→a≡₁] r))
                           (y≼w n (Lemma[min𝟚ab≡₁→b≡₁] r))

≼-trans : ∀ x y z → x ≼ y → y ≼ z → x ≼ z
≼-trans x y z p q n = q n ∘ p n

_-Close-via_ : {X : 𝓤 ̇ } (δ : ℕ) → closeness-function X
             → equivalence-relation X
_≣_     (δ -Close-via C) x y
 = (δ ↑) ≼ c (x , y)
 where open closeness-function C
≣-refl  (δ -Close-via C) x
 = transport ((δ ↑) ≼_) (eic x ⁻¹) (∞-maximal (δ ↑))
 where open closeness-function C
≣-sym   (δ -Close-via C) x y
 = transport ((δ ↑) ≼_) (sym x y)
 where open closeness-function C
≣-trans (δ -Close-via C) x y z δ≼cxy δ≼cyz
 = ≼-trans (δ ↑) (min (c (x , y)) (c (y , z))) (c (x , z))
     (≼-min (δ ↑) (c (x , y)) (c (y , z)) δ≼cxy δ≼cyz)
     (ult x y z)
 where open closeness-function C
```

Continuous predicates are those for which there is some δ : ℕ
such that the equivalence relation of being δ-close via any
closeness function informs the predicate.

```agda
continuous-predicate : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
                     → closeness-function X → (𝓦 ⁺) ⊔ 𝓤 ̇
continuous-predicate {𝓦} C
 = Σ δ ꞉ ℕ , decidable-predicate-informed-by {𝓦} (δ -Close-via C)

minℕ : ℕ → ℕ → ℕ
minℕ 0 0 = 0
minℕ 0 (succ y) = 0
minℕ (succ x) 0 = 0
minℕ (succ x) (succ y) = succ (minℕ x y)

min-preserves-min' : (a b : ℕ)
                   → pr₁ (minℕ a b ↑) ∼ pr₁ (min (a ↑) (b ↑))
min-preserves-min' 0        0        _ = refl
min-preserves-min' 0        (succ b) _ = refl
min-preserves-min' (succ a) 0        _ = Lemma[min𝟚ab≡₀] (inr refl) ⁻¹
min-preserves-min' (succ a) (succ b) 0 = refl
min-preserves-min' (succ a) (succ b) (succ i)
 = min-preserves-min' a b i

min-preserves-min : (a b : ℕ) → minℕ a b ↑ ≡ min (a ↑) (b ↑)
min-preserves-min a b = ℕ∞-equals (min-preserves-min' a b)

Continuous-via : {X : 𝓤 ̇ } → closeness-function X
               → equivalence-relation X
_≣_     (Continuous-via C) x y
 = Σ δ ꞉ ℕ , (δ ↑) ≼ c (x , y)
 where open closeness-function C
≣-refl  (Continuous-via C) x
 = 0 , (transport ((0 ↑) ≼_) (eic x ⁻¹) (∞-maximal (0 ↑)))
 where open closeness-function C
≣-sym   (Continuous-via C) x y (δ , δ≼cxy)
 = δ , transport ((δ ↑) ≼_) (sym x y) δ≼cxy
 where open closeness-function C
≣-trans (Continuous-via C) x y z (δ₁ , δ≼cxy) (δ₂ , δ≼cyz)
 = minℕ δ₁ δ₂ , ≼-trans ((minℕ δ₁ δ₂) ↑)
                        (min (c (x , y)) (c (y , z)))
                        (c (x , z))
                        (transport (_≼ min (c (x , y)) (c (y , z)))
                          (min-preserves-min δ₁ δ₂ ⁻¹)
                          (≼-min2 (δ₁ ↑) (δ₂ ↑) (c (x , y)) (c (y , z))
                            δ≼cxy δ≼cyz))
                        (ult x y z)
 where open closeness-function C
```

0 information literally gives us zero information -- equiv to trivial
equivalence relation.

```agda

0-info' : {𝓥 𝓤 : Universe} {X : 𝓤 ̇ }
        → (C : closeness-function X)
        → (x y : X)
        → let _≣₁_ = _≣_ (0 -Close-via C) in
          let _≣₂_ = _≣_ (Trivial {𝓥} X) in
          (x ≣₁ y) ⇔ (x ≣₂ y)
0-info' C x y = (λ _ → ⋆) , (λ _ x ())

eq-close : {𝓦 𝓥 𝓤 : Universe} {X : 𝓤 ̇ }
        → (A B : equivalence-relation {𝓥} X)
        → let _≣₁_ = _≣_ A in
          let _≣₂_ = _≣_ B in
          ((x y : X) → x ≣₁ y ⇔ x ≣₂ y)
        → (p : decidable-predicate {𝓦} X)
        → (A informs p)
        ⇔ (B informs p)
eq-close A B γ p = (λ Ap x y Bxy → Ap x y (pr₂ (γ x y) Bxy))
                 , (λ Bp x y Axy → Bp x y (pr₁ (γ x y) Axy))
                 
eq-sim : {𝓦 𝓥 𝓤 : Universe} {X : 𝓤 ̇ }
       → (A B : equivalence-relation {𝓥} X)
       → ((x y : X) → _≣_ A x y
                    ⇔ _≣_ B x y)
       → (p : decidable-predicate {𝓦} X)
       → (A informs p)
       ≃ (B informs p)
eq-sim A B γ p = logically-equivalent-props-are-equivalent
                   (informs-is-prop A p)
                   (informs-is-prop B p)
                   (pr₁ Ap⇔Bp) (pr₂ Ap⇔Bp)
 where Ap⇔Bp = eq-close A B γ p

0-info : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
       → (C : closeness-function X)
       → (p : decidable-predicate {𝓦} X)
       → ((0 -Close-via C) informs p)
       ≃ ((Trivial      X) informs p)
0-info {𝓦} {𝓤} {X} C = eq-sim (0 -Close-via C) (Trivial X) (0-info' C)
```

information is transitive

```agda
succ-info : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
       → (C : closeness-function X)
       → (p : decidable-predicate {𝓦} X)
       → (n : ℕ)
       → ((n      -Close-via C) informs p)
       → ((succ n -Close-via C) informs p)
succ-info {𝓦} {𝓤} {X} C (p , d , i) n ι x y sn≼cxy = ι x y n≼cxy
 where
   open closeness-function C
   n≼cxy : (n ↑) ≼ c (x , y)
   n≼cxy 0 r = sn≼cxy 0 refl
   n≼cxy (succ k) r = sn≼cxy (succ k) (pr₂ (n ↑) k r)
   
```

If the underlying type X is discrete, every decidable predicate is
trivially continuous with any modulus of continuity using the discrete
sequence closeness function.

```agda
d-closeness : {X : 𝓤 ̇ } → is-discrete X → closeness-function X
closeness-function.c   (d-closeness ds) = discrete-clofun ds
closeness-function.eic (d-closeness ds) = equal→inf-close
 where open is-clofun (discrete-is-clofun ds)
closeness-function.ice (d-closeness ds) = inf-close→equal
 where open is-clofun (discrete-is-clofun ds)
closeness-function.sym (d-closeness ds) = symmetricity
 where open is-clofun (discrete-is-clofun ds)
closeness-function.ult (d-closeness ds) = ultrametric
 where open is-clofun (discrete-is-clofun ds)

1-close-informs-discrete : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
                         → (ds : is-discrete X)
                         → (p : decidable-predicate {𝓦} X)
                         → (1 -Close-via d-closeness ds) informs p
1-close-informs-discrete ds (p , _) x y 1≼cxy
 = transport p (γ (ds x y) 1≼cxy)
 where
   open closeness-function (d-closeness ds)
   γ : (q : decidable (x ≡ y)) → (1 ↑) ≼ discrete-c' (x , y) q → x ≡ y
   γ (inl  x≡y) _ = x≡y
   γ (inr ¬x≡y) r = 𝟘-elim (zero-is-not-one (r 0 refl))

succ-close-informs-discrete
 : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
 → (n : ℕ)
 → (ds : is-discrete X)
 → (p : decidable-predicate {𝓦} X)
 → (succ n -Close-via d-closeness ds) informs p
succ-close-informs-discrete 0 = 1-close-informs-discrete
succ-close-informs-discrete (succ n) ds p
 = succ-info (d-closeness ds) p (succ n)
     (succ-close-informs-discrete n ds p)

decidable-discrete-predicate-≃
 : {𝓦 𝓤 : Universe} {X : 𝓤 ̇ }
 → (n : ℕ)
 → (ds : is-discrete X)
 → decidable-predicate  {𝓦} X
 ≃ decidable-predicate-informed-by {𝓦}
     (succ n -Close-via d-closeness ds)
decidable-discrete-predicate-≃ n ds
 = to-subtype-≃ (λ p → (succ-close-informs-discrete n ds p)
                     , (informs-is-prop
                         (succ n -Close-via d-closeness ds) p))

```

A searcher takes decidable predicates and returns something that,
if the predicate is answerable, answers the predicate.

It also returns a natural number denoting the number of times the
predicate was queried.

```agda

Searchable : {𝓦 𝓥 𝓤 : Universe} {X : 𝓤 ̇ }
           → equivalence-relation {𝓥} X
           → (𝓦 ⁺) ⊔ 𝓥 ⊔ 𝓤 ̇ 
Searchable {𝓦} {𝓥} {𝓤} {X} _≣_
 = Π ((p , _) , _) ꞉ decidable-predicate-informed-by {𝓦} _≣_
 , Σ x₀ ꞉ X , (Σ p → p x₀)

All-Searchable : {𝓦 𝓤 : Universe} (X : 𝓤 ̇ )
               → (𝓦 ⁺) ⊔ 𝓤 ̇
All-Searchable {𝓦} {𝓤} X = Searchable {𝓦} (Identity X) 

𝟙-is-searchable : {𝓦 𝓥 𝓤 : Universe} → All-Searchable {𝓦} {𝓤} 𝟙
𝟙-is-searchable ((p , _) , _) = ⋆ , γ
 where
   γ : Σ p → p ⋆
   γ (⋆ , px) = px

×-equivalence-relation : {𝓥 𝓥' 𝓤 𝓤' : Universe} {X : 𝓤 ̇ } {Y : 𝓤' ̇ }
                       → equivalence-relation {𝓥     }  X
                       → equivalence-relation {    𝓥'}      Y
                       → equivalence-relation {𝓥 ⊔ 𝓥'} (X × Y)
_≣_     (×-equivalence-relation A B)
 (x₁ , y₁) (x₂ , y₂) = (x₁ ≣x x₂) × (y₁ ≣y y₂)
 where
   _≣x_ = _≣_ A
   _≣y_ = _≣_ B
≣-refl  (×-equivalence-relation A B)
 (x₁ , y₁) = ≣x-refl x₁ , ≣y-refl y₁
 where
   ≣x-refl = ≣-refl A
   ≣y-refl = ≣-refl B
≣-sym   (×-equivalence-relation A B)
 (x₁ , y₁) (x₂ , y₂) (ex , ey) = ≣x-sym x₁ x₂ ex , ≣y-sym y₁ y₂ ey
 where
   ≣x-sym = ≣-sym A
   ≣y-sym = ≣-sym B
≣-trans (×-equivalence-relation A B)
 (x₁ , y₁) (x₂ , y₂) (x₃ , y₃) (ex₁ , ey₁) (ex₂ , ey₂)
  = ≣x-trans x₁ x₂ x₃ ex₁ ex₂ , ≣y-trans y₁ y₂ y₃ ey₁ ey₂
  where
   ≣x-trans = ≣-trans A
   ≣y-trans = ≣-trans B

×-equivalence-relation-elim-l
 : {𝓥 𝓤 𝓤' : Universe} {X : 𝓤 ̇ } {Y : 𝓤' ̇ }
 → equivalence-relation {𝓥} (X × Y)
 → equivalence-relation {𝓥 ⊔ 𝓤'}  X
_≣_     (×-equivalence-relation-elim-l AB)
 x₁ x₂ = ∀ y → (x₁ , y) ≣AB (x₂ , y)
 where _≣AB_ = _≣_ AB
≣-refl  (×-equivalence-relation-elim-l AB)
 x₁ y = ≣-refl AB (x₁ , y)
≣-sym   (×-equivalence-relation-elim-l AB)
 x₁ x₂ f y = ≣-sym AB (x₁ , y) (x₂ , y) (f y)
≣-trans (×-equivalence-relation-elim-l AB)
 x₁ x₂ x₃ f g y = ≣-trans AB (x₁ , y) (x₂ , y) (x₃ , y) (f y) (g y)
 
head-predicate* : {𝓦 𝓥 𝓤 𝓤' : Universe} {X : 𝓤 ̇ } {Y : 𝓤' ̇ }
                → (AB : equivalence-relation {𝓥} (X × Y))
                → decidable-predicate-informed-by {𝓦} AB
                → (y : Y)
                → decidable-predicate-informed-by {𝓦}
                    (×-equivalence-relation-elim-l AB)
head-predicate* AB ((p' , d' , i') , ϕ') y = (p , d , i) , ϕ
 where
   p : _ → _ ̇
   p x = p' (x , y)
   d : everywhere-decidable p
   d x = d' (x , y)
   i : everywhere-prop-valued p
   i x = i' (x , y)
   ϕ : ×-equivalence-relation-elim-l AB informs (p , d , i)
   ϕ x₁ x₂ x≣y = ϕ' (x₁ , y) (x₂ , y) (x≣y y)
                           
fst-predicate : {𝓦 𝓥 𝓥' 𝓤 𝓤' : Universe} {X : 𝓤 ̇ } {Y : 𝓤' ̇ }
              → (A : equivalence-relation {𝓥 } X)
              → (B : equivalence-relation {𝓥'} Y)
              → decidable-predicate-informed-by {𝓦}
                  (×-equivalence-relation A B)
              → (y : Y)
              → decidable-predicate-informed-by {𝓦} A
fst-predicate A B ((p' , d' , i') , ϕ') y = (p , d , i) , ϕ
 where
   open equivalence-relation B
   p : _ → _ ̇
   p x = p' (x , y)
   d : everywhere-decidable p
   d x = d' (x , y)
   i : everywhere-prop-valued p
   i x = i' (x , y)
   ϕ : A informs (p , d , i)
   ϕ x₁ x₂ x₁≈x₂ = ϕ' (x₁ , y) (x₂ , y) (x₁≈x₂ , ≣-refl B y)

Searcher-preserves-equivalence-relation
 : {𝓦 𝓥 𝓥' 𝓤 𝓤' : Universe} {X : 𝓤 ̇ } {Y : 𝓤' ̇ }
 → (A : equivalence-relation {𝓥 } X)
 → (B : equivalence-relation {𝓥'} Y)
 → ((a : X) → decidable-predicate-informed-by {𝓦} B)
 → Searchable {𝓦} B
 → 𝓥 ⊔ 𝓥' ⊔ 𝓤 ̇ 
Searcher-preserves-equivalence-relation
 {𝓦} {𝓥} {𝓥'} {𝓤} {𝓤'} {X} {Y} A B ps 𝓔y
 = (x₁ x₂ : X) → x₁ ≣x x₂ → pr₁ (𝓔y (ps x₁)) ≣y pr₁ (𝓔y (ps x₂))
 where
   _≣x_ = _≣_ A
   _≣y_ = _≣_ B   

snd-predicate : {𝓦 𝓥 𝓥' 𝓤 𝓤' : Universe} {X : 𝓤 ̇ } {Y : 𝓤' ̇ }
              → (A : equivalence-relation {𝓥 } X)
              → (B : equivalence-relation {𝓥'} Y)
              → (p : decidable-predicate-informed-by {𝓦}
                       (×-equivalence-relation A B))
              → (𝓔x : Searchable {𝓦} A)
              → Searcher-preserves-equivalence-relation {𝓦} B A
                  (fst-predicate A B p) 𝓔x
              → decidable-predicate-informed-by {𝓦} B
snd-predicate A B ((p' , d' , i') , ϕ') 𝓔x preserves = (p , d , i) , ϕ
 where
   open equivalence-relation A
   P : _ → _
   P y = pr₁ (𝓔x (fst-predicate A B ((p' , d' , i') , ϕ') y))
   p : _ → _ ̇
   p y = p' (P y , y)
   d : everywhere-decidable p
   d y = d' (P y , y)
   i : everywhere-prop-valued p
   i y = i' (P y , y)
   ϕ : B informs (p , d , i)
   ϕ y₁ y₂ y₁≈y₂ = ϕ' (P y₁ , y₁) (P y₂ , y₂)
                      (preserves y₁ y₂ y₁≈y₂ , y₁≈y₂)
   
×-is-searchable-l : {𝓦 𝓥 𝓥' 𝓤 𝓤' : Universe} {X : 𝓤 ̇ } {Y : 𝓤' ̇ }
                  → (A : equivalence-relation {𝓥 } X)
                  → (B : equivalence-relation {𝓥'} Y)
                  → (𝓔x : Searchable {𝓦} A)
                  →       Searchable {𝓦} B
                  → (∀ p → Searcher-preserves-equivalence-relation {𝓦}
                           B A (fst-predicate A B p) 𝓔x)
                  → Searchable {𝓦} (×-equivalence-relation A B)
×-is-searchable-l {𝓦} {𝓥} {𝓥'} {𝓤} {𝓤'} {X} {Y} A B 𝓔x 𝓔y preserves p
 = (x₀→ y₀ , y₀)
 , λ ((x , y) , pxy) → γy (y , (γx y (x , pxy)))
 where
   px : Y → Σ (A informs_)
   px y = fst-predicate A B p y
   py : Σ (B informs_)
   py = snd-predicate A B p 𝓔x (preserves p)
   x₀→ : Y → X
   x₀→ y = pr₁ (𝓔x (px y))
   y₀ : Y
   y₀ = pr₁ (𝓔y py)
   γx : (y : Y) → Σ (pr₁ (pr₁ (px y))) → (pr₁ (pr₁ (px y))) (x₀→ y)
   γx y = pr₂ (𝓔x (px y))
   γy : Σ (pr₁ (pr₁ py)) → (pr₁ (pr₁ py)) y₀
   γy = pr₂ (𝓔y py)

swap : {X : 𝓤 ̇ } {Y : 𝓥 ̇ } → X × Y → Y × X
swap (x , y) = y , x

×-is-searchable-r : {𝓦 𝓥 𝓥' 𝓤 𝓤' : Universe} {X : 𝓤 ̇ } {Y : 𝓤' ̇ }
                  → (A : equivalence-relation {𝓥 } X)
                  → (B : equivalence-relation {𝓥'} Y)
                  →       Searchable {𝓦} A
                  → (𝓔y : Searchable {𝓦} B)
                  → (∀ p → Searcher-preserves-equivalence-relation {𝓦}
                           A B (fst-predicate B A p) 𝓔y)
                  → Searchable {𝓦} (×-equivalence-relation A B)
×-is-searchable-r {𝓦} {𝓥} {𝓥'} {𝓤} {𝓤'} {X} {Y} A B 𝓔x 𝓔y
 preserves ((p' , d' , i') , ϕ')
 = swap yx₀ , λ ((x , y) , p'xy) → pr₂ (γ p) ((y , x) , p'xy)
 where
   -- ≣-sym = ≣-sym (×-equivalence-relation A B)
   p : decidable-predicate-informed-by {𝓦}
         (×-equivalence-relation B A)
   p = (p' ∘ swap , d' ∘ swap , i' ∘ swap)
     , λ (x₁ , y₁) (x₂ , y₂) (x≣ , y≣)
     → ϕ' (y₁ , x₁) (y₂ , x₂) (y≣ , x≣)
   γ = ×-is-searchable-l B A 𝓔y 𝓔x preserves
   yx₀ : Y × X
   yx₀ = pr₁ (γ p)

×-is-searchable : {𝓦 𝓥 𝓥' 𝓤 𝓤' : Universe} {X : 𝓤 ̇ } {Y : 𝓤' ̇ }
                → (A : equivalence-relation {𝓥 } X)
                → (B : equivalence-relation {𝓥'} Y)
                → (𝓔x : Searchable {𝓦} A)
                → (𝓔y : Searchable {𝓦} B)
                → (∀ p → Searcher-preserves-equivalence-relation {𝓦}
                         B A (fst-predicate A B p) 𝓔x)
                + (∀ p → Searcher-preserves-equivalence-relation {𝓦}
                         A B (fst-predicate B A p) 𝓔y)
                → Searchable {𝓦} (×-equivalence-relation A B)
×-is-searchable      A B 𝓔x 𝓔y (inl preserves)
 = ×-is-searchable-l A B 𝓔x 𝓔y      preserves
×-is-searchable      A B 𝓔x 𝓔y (inr preserves)
 = ×-is-searchable-r A B 𝓔x 𝓔y      preserves

Identity-always-preserves
 : {𝓦 𝓦' 𝓥' 𝓤 𝓤' : Universe} {X : 𝓤 ̇ } {Y : 𝓤' ̇ }
 → (B : equivalence-relation {𝓥'} Y)
 → (𝓔y : Searchable {𝓦} B)
 → (p : (x : X) → decidable-predicate-informed-by {𝓦} B)
 → Searcher-preserves-equivalence-relation {𝓦} (Identity X) B p 𝓔y
Identity-always-preserves B 𝓔y p x x refl = ≣-refl B (pr₁ (𝓔y (p x)))

{-
splittable : {𝓦 𝓥 𝓥' 𝓤 𝓤' : Universe} {X : 𝓤 ̇ } {Y : 𝓤' ̇ }
           → (C : closeness-function {𝓥 } X)
           → ?
splittable {𝓦} {𝓥} {𝓥'} {𝓤} {𝓤'} {X} {Y} C
 = (δ : ℕ)
 → (p : decidable-predicate-informed-by (δ -Close-via C))
 → 
-}

record pred-equivalence {𝓤 𝓤' 𝓥 𝓥' : Universe} {X : 𝓤 ̇ } {Y : 𝓤' ̇ }
  (A : equivalence-relation {𝓥 } X)
  (B : equivalence-relation {𝓥'} Y)  : 𝓤 ⊔ 𝓤' ⊔ 𝓥 ⊔ 𝓥' ⁺  ̇ where
  _≣A_ = _≣_ A
  _≣B_ = _≣_ B
  field
    f : X → Y
    g : Y → X
    trans-A : (x : X) → x ≣A ((g ∘ f) x)
    trans-B : (y : Y) → y ≣B ((f ∘ g) y)
    lift-AB : (x₁ x₂ : X) → x₁ ≣A x₂ → (f x₁) ≣B (f x₂)
    lift-BA : (y₁ y₂ : Y) → y₁ ≣B y₂ → (g y₁) ≣A (g y₂)

_≈_ : {X : 𝓤 ̇ } → (ℕ → X) → (ℕ → X) → ℕ → 𝓤 ̇
(α ≈ β) n = (i : ℕ) → i <ℕ n → α n ≡ β n

sequence-relation-≈' : (X : 𝓤 ̇ ) → (δ : ℕ)
                     → equivalence-relation {𝓤} (ℕ → X)
_≣_     (sequence-relation-≈' X δ)
 α β = (α ≈ β) δ
≣-refl  (sequence-relation-≈' X δ)
 α             = λ i i<δ → refl
≣-sym   (sequence-relation-≈' X δ)
 α β   α≈β     = λ i i<δ → α≈β i i<δ ⁻¹
≣-trans (sequence-relation-≈' X δ)
 α β ζ α≈β β≈ζ = λ i i<δ → α≈β i i<δ ∙ β≈ζ i i<δ

sequence-relation-≈ : (X : 𝓤 ̇ ) → equivalence-relation {𝓤} (ℕ → X)
_≣_ (sequence-relation-≈ X)
 α β = Σ δ ꞉ ℕ , (α ≈ β) (succ δ)
≣-refl (sequence-relation-≈ X)
 α = {!!}
≣-sym (sequence-relation-≈ X)
 = {!!}
≣-trans (sequence-relation-≈ X)
 = {!!}

sequence-relation-c : (X : 𝓤 ̇ ) → equivalence-relation {{!!}} (ℕ → X)
sequence-relation-c X = Continuous-via {!!}


```

searcher : {𝓦 𝓥 𝓤 : Universe} {X : 𝓤 ̇ }
         → Σ 𝓔 
