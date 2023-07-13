```agda
{-# OPTIONS --without-K --exact-split --safe #-}

open import UF.FunExt
open import UF.Subsingletons
open import UF.Subsingletons-FunExt  
open import UF.Quotient
open import MLTT.Spartan
open import Notation.Order
open import Naturals.Order
open import NotionsOfDecidability.Complemented
open import CoNaturals.GenericConvergentSequence
  renaming (ℕ-to-ℕ∞ to _↑
         ; Zero-smallest to zero-minimal
         ; ∞-largest to ∞-maximal)
open import TypeTopology.DiscreteAndSeparated

module TWA.Thesis.Chapter4.ConvergenceTheorems (fe : FunExt) where

open import TWA.Thesis.Chapter3.ClosenessSpaces fe
open import TWA.Thesis.Chapter3.ClosenessSpaces-Examples fe
open import TWA.Thesis.Chapter3.SearchableTypes fe
open import TWA.Thesis.Chapter4.ApproxOrder fe
open import TWA.Thesis.Chapter4.ApproxOrder-Examples fe
open import TWA.Thesis.Chapter4.GlobalOptimisation fe

open import TWA.Closeness fe hiding (is-ultra;is-closeness)

-- Definition 4.2.10 (Does not have continuity of M!)
regressor : (X : ClosenessSpace 𝓤) (Y : PseudoClosenessSpace 𝓥) → 𝓤 ⊔ 𝓥  ̇
regressor {𝓤} {𝓥} X Y
 = (M : ⟨ X ⟩ → ⟪ Y ⟫) → f-ucontinuous' (ι X) Y M → ⟪ Y ⟫ → ⟨ X ⟩

C-ucontinuous : (X : ClosenessSpace 𝓤)
              → (ε : ℕ) (x : ⟨ X ⟩) → p-ucontinuous X (CΩ X ε x)
C-ucontinuous X ε x = ε , γ
 where
  γ : (y z : ⟨ X ⟩) → C X ε y z → C X ε x y → C X ε x z
  γ y z Cyz Cxy = C-trans X ε x y z Cxy Cyz

-- TODO: Fix overloaded Ω
p-regressor : (X : ClosenessSpace 𝓤) (Y : PseudoClosenessSpace 𝓥)
            → (𝓔S : csearchable 𝓤₀ X)
            → (ε : ℕ) → regressor X Y
p-regressor {𝓤} {𝓥} X Y S ε M ϕᴹ 𝓞 = pr₁ (S ((p , d) , ϕ))
 where
  p : ⟨ X ⟩ → Ω 𝓤₀
  p x = C'Ω Y ε 𝓞 (M x)
  d : is-complemented (λ x → p x holds)
  d x = C'-decidable Y ε 𝓞 (M x)
  ϕ : p-ucontinuous X p
  ϕ = δ , γ
   where
    δ : ℕ
    δ = pr₁ (ϕᴹ ε)
    γ : (x₁ x₂ : ⟨ X ⟩) → C X δ x₁ x₂ → p x₁ holds → p x₂ holds
    γ x₁ x₂ Cδx₁x₂ px₁
     = C'-trans Y ε 𝓞 (M x₁) (M x₂) px₁ (pr₂ (ϕᴹ ε) x₁ x₂ Cδx₁x₂)

invert-rel : {X : 𝓤 ̇ } → (X → X → 𝓥 ̇ ) → (X → X → 𝓥 ̇ )
invert-rel R x y = R y x

invert-rel' : {X : 𝓤 ̇ } → (X → X → ℕ → 𝓥 ̇ ) → (X → X → ℕ → 𝓥 ̇ )
invert-rel' R x y = R y x 

invert-preorder-is-preorder : {X : 𝓤 ̇ } → (_≤_ : X → X → 𝓥 ̇ )
                            → is-preorder _≤_
                            → let _≥_ = invert-rel _≤_ in
                              is-preorder _≥_
invert-preorder-is-preorder _≤_ (r' , t' , p') = r , t , p
 where
  r : reflexive (invert-rel _≤_)
  r x = r' x
  t : transitive (invert-rel _≤_)
  t x y z q r = t' z y x r q
  p : is-prop-valued (invert-rel _≤_)
  p x y = p' y x

invert-approx-order-is-approx-order-for
 : (X : ClosenessSpace 𝓤)
 → (_≤_ : ⟨ X ⟩ → ⟨ X ⟩ → 𝓥 ̇ ) (_≤ⁿ_ : ⟨ X ⟩ → ⟨ X ⟩ → ℕ → 𝓥' ̇ )
 → is-approx-order-for X _≤_ _≤ⁿ_
 → let _≥_  = invert-rel  _≤_  in
   let _≥ⁿ_ = invert-rel' _≤ⁿ_ in
   is-approx-order-for X _≥_ _≥ⁿ_
invert-approx-order-is-approx-order-for
 X _≤_ _≤ⁿ_ (pre' , (lin' , dec' , c') , a')
 = pre , (lin , dec , c) , a
 where
  pre : is-preorder (invert-rel _≤_)
  pre = invert-preorder-is-preorder _≤_ pre'
  lin : (ϵ : ℕ) → is-linear-order (λ x y → invert-rel' _≤ⁿ_ x y ϵ)
  lin ϵ = (r'
        , (λ x y z q r → t' z y x r q)
        , λ x y → p' y x)
        , λ x y → l' y x
   where
    r' = (pr₁ ∘ pr₁)       (lin' ϵ)
    t' = (pr₁ ∘ pr₂ ∘ pr₁) (lin' ϵ)
    p' = (pr₂ ∘ pr₂ ∘ pr₁) (lin' ϵ)
    l' = pr₂               (lin' ϵ)
  dec : (ϵ : ℕ) (x y : ⟨ X ⟩) → is-decidable (invert-rel' _≤ⁿ_ x y ϵ)
  dec ϵ x y = dec' ϵ y x
  c : (ϵ : ℕ) (x y : ⟨ X ⟩) → C X ϵ x y → invert-rel' _≤ⁿ_ x y ϵ
  c ϵ x y Cxy = c' ϵ y x (C-sym X ϵ x y Cxy)
  a : (ϵ : ℕ) (x y : ⟨ X ⟩) → ¬ C X ϵ x y → invert-rel' _≤ⁿ_ x y ϵ
                                          ⇔ invert-rel _≤_ x y
  a ϵ x y ¬Cxy = a' ϵ y x (λ Cyx → 𝟘-elim (¬Cxy (C-sym X ϵ y x Cyx)))

is_global-maximal : ℕ → {𝓤 𝓥 : Universe}
                  → {X : 𝓤 ̇ } {Y : 𝓥 ̇ }
                  → (_≤ⁿ_ : Y → Y → ℕ → 𝓦 ̇ )
                  → (f : X → Y) → X → 𝓦 ⊔ 𝓤  ̇ 
(is ϵ global-maximal) {𝓤} {𝓥} {X} _≤ⁿ_ f x₀
 = is ϵ global-minimal (invert-rel' _≤ⁿ_) f x₀

has_global-maximal : ℕ → {𝓤 𝓥 : Universe} {X : 𝓤 ̇ }
                   → {Y : 𝓥 ̇ }
                   → (_≤ⁿ_ : Y → Y → ℕ → 𝓦 ̇ )
                   → (f : X → Y) → (𝓦 ⊔ 𝓤) ̇ 
(has ϵ global-maximal) {𝓤} {𝓥} {𝓦} {X} _≤ⁿ_ f
 = Σ ((is ϵ global-maximal) {𝓤} {𝓥} {𝓦} {X} _≤ⁿ_ f)

global-max-ℕ∞ : (X : ClosenessSpace 𝓤) → ⟨ X ⟩
              → totally-bounded X 𝓤'
              → (f : ⟨ X ⟩ → ℕ∞)
              → f-ucontinuous X ℕ∞-ClosenessSpace f
              → (ϵ : ℕ)
              → (has ϵ global-maximal) ℕ∞-approx-lexicorder f
global-max-ℕ∞ X x₀ t f ϕ ϵ
 = global-opt X ℕ∞-ClosenessSpace x₀
     (invert-rel' ℕ∞-approx-lexicorder)
     (is-approx-order-ι ℕ∞-ClosenessSpace
       (invert-rel ℕ∞-lexicorder) (invert-rel' ℕ∞-approx-lexicorder)
       (invert-approx-order-is-approx-order-for ℕ∞-ClosenessSpace
         ℕ∞-lexicorder ℕ∞-approx-lexicorder
         ℕ∞-approx-lexicorder-is-approx-order-for))
     ϵ f ϕ t

-- Theorem 4.2.8
-- open import CoNaturals.GenericConvergentSequence

um : (u : ℕ∞) (n : ℕ) → ¬ ((n ↑) ≼ u) → u ≺ (n ↑)
um u zero ¬n≼u = 𝟘-elim (¬n≼u (λ _ ()))
um u (succ n) ¬sn≼u with ≼-left-decidable n u
... | inl  n≼u = n
               , to-subtype-＝ (being-decreasing-is-prop (fe _ _))
                   (dfunext (fe _ _) γ)
               , <-gives-⊏ n (succ n) (<-succ n)
 where
  γ : pr₁ u ∼ pr₁ (n ↑)
  γ i = Cases (<-decidable i n)
          (λ  i<n → n≼u i (<-gives-⊏ i n i<n) ∙ <-gives-⊏ i n i<n ⁻¹)
          (λ ¬i<n → not-⊏-is-⊒ {i} {u}
                      (λ i⊏u → ¬sn≼u
                        (λ j j⊏sn → ⊏-trans'' u i j
                                      (<-≤-trans j (succ n) (succ i)
                                        (⊏-gives-< j (succ n) j⊏sn)
                                        (not-less-bigger-or-equal
                                          n i ¬i<n))
                                      i⊏u))
                  ∙ not-⊏-is-⊒ {i} {n ↑}
                      (λ i⊏n → ¬i<n (⊏-gives-< i n i⊏n)) ⁻¹)
... | inr ¬n≼u
 = ≺-trans u (n ↑) (succ n ↑)
     (um u n ¬n≼u) (n , refl , (<-gives-⊏ n (succ n) (<-succ n)))

thingy : (Y : PseudoClosenessSpace 𝓥)
       → (n : ℕ)
       → (x y : ⟪ Y ⟫)
       → ¬ C' Y n x y
       → let c = pr₁ (pr₂ Y) in
         c x y ≺ (n ↑)
thingy Y n x y ¬Cnxy = um (pr₁ (pr₂ Y) x y) n ¬Cnxy

open import TWA.Thesis.Chapter2.Sequences
open import MLTT.Two-Properties
  
allofthemare' : (Y : PseudoClosenessSpace 𝓥)
              → (Ω : ⟪ Y ⟫)
              → (ϵ : ℕ)
              → let c = pr₁ (pr₂ Y) in
                (y₁ y₂ : ⟪ Y ⟫)
              → C' Y ϵ y₁ y₂
              → C' (ι ℕ∞-ClosenessSpace) ϵ (c Ω y₁) (c Ω y₂)
allofthemare' Y Ω ϵ y₁ y₂ Cϵy₁y₂ n n⊏ϵ
 = decidable-𝟚₁ (discrete-decidable-seq _ _ _ (succ n))
       λ k k<sn → CΩ-eq k (<-≤-trans k (succ n) ϵ k<sn (⊏-gives-< n ϵ n⊏ϵ))
   where
    c = pr₁ (pr₂ Y)
    c-sym = pr₁ (pr₂ (pr₂ (pr₂ Y)))
    c-ult = pr₂ (pr₂ (pr₂ (pr₂ Y)))
    CΩ-eq : (pr₁ (c Ω y₁) ∼ⁿ pr₁ (c Ω y₂)) ϵ
    CΩ-eq n n<ϵ with 𝟚-possibilities (pr₁ (c Ω y₁) n)
                   | 𝟚-possibilities (pr₁ (c Ω y₂) n)
    ... | inl cΩy₁＝₀ | inl cΩy₂＝₀ = cΩy₁＝₀ ∙ cΩy₂＝₀ ⁻¹
    ... | inl cΩy₁＝₀ | inr cΩy₂＝₁
     = 𝟘-elim (zero-is-not-one
     (cΩy₁＝₀ ⁻¹
     ∙ c-ult Ω y₂ y₁ n
         (Lemma[a＝₁→b＝₁→min𝟚ab＝₁] cΩy₂＝₁
           (ap (λ - → pr₁ - n) (c-sym y₂ y₁)
            ∙ Cϵy₁y₂ n (<-gives-⊏ n ϵ n<ϵ)))))
    ... | inr cΩy₁＝₁ | inl cΩy₂＝₀
     = 𝟘-elim (zero-is-not-one
     (cΩy₂＝₀ ⁻¹
     ∙ c-ult Ω y₁ y₂ n
         (Lemma[a＝₁→b＝₁→min𝟚ab＝₁] cΩy₁＝₁
           (Cϵy₁y₂ n (<-gives-⊏ n ϵ n<ϵ))))) 
    ... | inr cΩy₁＝₁ | inr cΩy₂＝₁ = cΩy₁＝₁ ∙ cΩy₂＝₁ ⁻¹
  
allofthemare : (Y : PseudoClosenessSpace 𝓥)
             → (Ω : ⟪ Y ⟫)
             → let c = pr₁ (pr₂ Y) in
               f-ucontinuous' Y (ι ℕ∞-ClosenessSpace) (c Ω)
allofthemare Y Ω ϵ = ϵ , allofthemare' Y Ω ϵ
    
optimisation-convergence
       : (X : ClosenessSpace 𝓤) (Y : PseudoClosenessSpace 𝓥)
       → ⟨ X ⟩ → totally-bounded X 𝓤'
       → (M : ⟨ X ⟩ → ⟪ Y ⟫) (Ω : ⟪ Y ⟫)
       → f-ucontinuous' (ι X) Y M
       → let c = pr₁ (pr₂ Y) in
         (ϵ : ℕ)
       → (has ϵ global-maximal) ℕ∞-approx-lexicorder (λ x → c Ω (M x))
optimisation-convergence X Y x₀ t M Ω ϕᴹ
 = global-max-ℕ∞ X x₀ t (c Ω ∘ M)
     (λ ϵ → pr₁ (ϕᴹ ϵ)
          , λ x₁ x₂ Cδᶜx₁x₂ → allofthemare' Y Ω ϵ (M x₁) (M x₂)
                               (pr₂ (ϕᴹ ϵ) x₁ x₂ Cδᶜx₁x₂))
 where
  c : ⟪ Y ⟫ → ⟪ Y ⟫ → ℕ∞
  c = pr₁ (pr₂ Y)

-- Make sure the fixed oracle is on the left (in paper too)
-- Theorem 4.2.12
s-imperfect-convergence
       : (X : ClosenessSpace 𝓤) (Y : PseudoClosenessSpace 𝓥)
       → (S : csearchable 𝓤₀ X)
       → (ε : ℕ)
       → (M : ⟨ X ⟩ → ⟪ Y ⟫) (ϕᴹ : f-ucontinuous' (ι X) Y M)
       → (Ψ : ⟪ Y ⟫ → ⟪ Y ⟫) (k : ⟨ X ⟩)
       → let
           Ω = M k
           ΨΩ = Ψ Ω
           reg = p-regressor X Y S ε
           ω = M (reg M ϕᴹ ΨΩ)
         in (C' Y ε Ω ΨΩ) → (C' Y ε Ω ω)
s-imperfect-convergence X Y S ε M ϕᴹ Ψ k CεΩΨΩ
 = C'-trans Y ε Ω' ΨΩ ω CεΩΨΩ (pr₂ (S ((p , d) , ϕ)) (k , C'-sym Y ε Ω' ΨΩ CεΩΨΩ))
 where
  Ω' = M k -- fix Ω definition in paper and agda
  ΨΩ = Ψ Ω'
  reg = p-regressor X Y S ε
  ω = M (reg M ϕᴹ ΨΩ)
  p : ⟨ X ⟩ → Ω 𝓤₀
  p x = C'Ω Y ε ΨΩ (M x)
  d : is-complemented (λ x → p x holds)
  d x = C'-decidable Y ε ΨΩ (M x)
  ϕ : p-ucontinuous X p
  ϕ = δ , γ
   where
    δ : ℕ
    δ = pr₁ (ϕᴹ ε)
    γ : (x₁ x₂ : ⟨ X ⟩) → C X δ x₁ x₂ → p x₁ holds → p x₂ holds
    γ x₁ x₂ Cδx₁x₂ CεΨΩMx₂
     = C'-trans Y ε ΨΩ (M x₁) (M x₂) CεΨΩMx₂
         (pr₂ (ϕᴹ ε) x₁ x₂ Cδx₁x₂)

perfect-convergence
       : (X : ClosenessSpace 𝓤) (Y : PseudoClosenessSpace 𝓥)
       → (S : csearchable 𝓤₀ X)
       → (ε : ℕ)
       → (M : ⟨ X ⟩ → ⟪ Y ⟫) (ϕᴹ : f-ucontinuous' (ι X) Y M)
       → (k : ⟨ X ⟩)
       → let
           Ω = M k
           reg = p-regressor X Y S ε
           ω = M (reg M ϕᴹ Ω)
         in C' Y ε Ω ω
perfect-convergence X Y S ε M ϕᴹ k
 = s-imperfect-convergence X Y S ε M ϕᴹ id k (C'-refl Y ε Ω')
 where Ω' = M k

{-
sampled-loss-function : {X : 𝓤 ̇ } {Y : 𝓥 ̇ }
                      → (Y → Y → ℕ∞) → (d : ℕ) → X ^⟨succ d ⟩
                      → (X → Y) → (X → Y) → ℕ∞
sampled-loss-function {𝓤} {𝓥} {X} {Y} cy d v f g
 = ×ⁿ-codistance cy d (vec-map f v) (vec-map g v)

sampled-loss-everywhere-sin
               : {X : 𝓤 ̇ } {Y : 𝓥 ̇ }
               → (cy : Y → Y → ℕ∞) (d : ℕ) (xs : X ^⟨succ d ⟩)
               → everywhere-sin cy
               → everywhere-sin (sampled-loss-function cy d xs)
sampled-loss-everywhere-sin cy 0 xs cy→ f = cy→ (f xs)
sampled-loss-everywhere-sin cy (succ d) (x , xs) cy→ f n
 = Lemma[a≡₁→b≡₁→min𝟚ab≡₁] (cy→ (f x) n)
     (sampled-loss-everywhere-sin cy d xs cy→ f n)

sampled-loss-right-continuous
               : {X : 𝓤 ̇ } {Y : 𝓥 ̇ }
               → (cy : Y → Y → ℕ∞)
               → right-continuous cy
               → (d : ℕ) → (xs : X ^⟨succ d ⟩)
               → right-continuous (sampled-loss-function cy d xs)
sampled-loss-right-continuous cy cy-r d xs ε z x y ε≼cxy
 = ×ⁿ-right-continuous cy d cy-r ε
     (vec-map z xs) (vec-map x xs) (vec-map y xs) ε≼cxy

if_then_else_ : {X : 𝓤 ̇ } {Y : 𝓥 ̇ } → decidable X → Y → Y → Y
if (inl _) then y₀ else _ = y₀
if (inr _) then _ else y₁ = y₁

if-elim₁ : {X : 𝓤 ̇ } {Y : 𝓥 ̇ } (d : decidable X) {y₁ y₂ : Y}
         → (x : X) → if d then y₁ else y₂ ≡ y₁
if-elim₁ (inl _ ) _ = refl
if-elim₁ (inr ¬x) x = 𝟘-elim (¬x x)

if-elim₂ : {X : 𝓤 ̇ } {Y : 𝓥 ̇ } (d : decidable X) {y₁ y₂ : Y}
         → (¬x : ¬ X) → if d then y₁ else y₂ ≡ y₂
if-elim₂ (inl x) ¬x = 𝟘-elim (¬x x)
if-elim₂ (inr _)  _ = refl

order : 𝓤 ̇ → 𝓤 ⁺ ̇
order {𝓤} X = Σ _≤'_ ꞉ (X → X → 𝓤 ̇ )
            , ((x y   : X)   → decidable (x ≤' y))
            × ({x     : X}   → x ≤' x)
            × ({x y z : X}   → ¬ (x ≤' y) → ¬ (y ≤' z) → ¬ (x ≤' z))

fst : {X : 𝓤 ̇ } (d : ℕ) → X ^⟨succ d ⟩ → X
fst 0 x = x
fst (succ _) (x , _) = x

ordered : {X : 𝓤 ̇ } (d : ℕ) → order X → X ^⟨succ d ⟩ → 𝓤 ̇
ordered 0 (_≤'_ , q) xs = 𝟙
ordered (succ d) (_≤'_ , q) (y₀ , ys)
 = ¬ (fst d ys ≤' y₀) × ordered d (_≤'_ , q) ys

c-interpolation : {X : 𝓤 ̇ } {Y : 𝓥 ̇ }
                → (o : order X) (d : ℕ)
                → X ^⟨succ d ⟩
                → (X → Y) → (X → Y)
c-interpolation _ 0 x₀ f _ = f x₀
c-interpolation (_≤'_ , ≤'-dec , q) (succ d) (x₀ , xs) f x
 = if   (≤'-dec x x₀) then f x₀
   else (c-interpolation (_≤'_ , ≤'-dec , q) d xs f x)

c-int-≡ : {Y₁ : 𝓥 ̇ } {Y₂ : 𝓦 ̇ }
        → (d : ℕ)
        → (y : Y₁) (ys : Y₁ ^⟨succ d ⟩)
        → ((_≤'_ , ≤'-dec , ≤'-refl) : order Y₁)
        → (f g : Y₁ → Y₂)
        → ordered (succ d) (_≤'_ , ≤'-dec , ≤'-refl) (y , ys)
        → (vec-map (λ y' → if ≤'-dec y' y then f y else g y') ys)
        ≡ (vec-map g ys)
c-int-≡ zero y₀ y₁ (_≤'_ , ≤'-dec ,  ≤'-refl , ≤'-trans) f g or
 = if-elim₂ (≤'-dec y₁ y₀) (pr₁ or)
c-int-≡ (succ d) y₀ (y₁ , ys) (_≤'_ , ≤'-dec ,  ≤'-refl , ≤'-trans) f g or
 = ×-≡ (if-elim₂ (≤'-dec y₁ y₀) (pr₁ or))
       (c-int-≡ d y₀ ys (_≤'_ , ≤'-dec ,  ≤'-refl , ≤'-trans) f g
         (≤'-trans (pr₁ (pr₂ or)) (pr₁ or) , pr₂ (pr₂ or)))

interpolated-slf-minimises-loss : {Y₁ : 𝓥 ̇ } {Y₂ : 𝓦 ̇ }
      → (cy : Y₂ → Y₂ → ℕ∞) (d : ℕ) (ys : Y₁ ^⟨succ d ⟩)
      → ((y : Y₂) → Π (_⊏ cy y y))
      → (o₁ : order Y₁) → ordered d o₁ ys
      → (Ω : Y₁ → Y₂) (ε : ℕ)
      → under ε ≼ sampled-loss-function cy d ys
                    (c-interpolation o₁ d ys Ω) Ω
interpolated-slf-minimises-loss cy 0 y cy→ _ _ Ω _ n _ = cy→ (Ω y) n
interpolated-slf-minimises-loss cy (succ d) (y , ys) cy→
                                (_≤'_ , ≤'-dec , ≤'-refl , ≤'-trans) or Ω ε
 = ×-codistance-min cy (sampled-loss-function cy d ys) (under ε) _ _
  (c-interpolation o₁ (succ d) (y , ys) Ω) Ω
    (λ n _ → transport (λ - → n ⊏ cy - (Ω y))
      (if-elim₁ (≤'-dec y y) ≤'-refl ⁻¹) (cy→ (Ω y) n))
    (transport (λ - → under ε ≼ ×ⁿ-codistance cy d - (vec-map Ω ys))
      (c-int-≡ d y ys o₁ Ω
        (c-interpolation (_≤'_ , ≤'-dec , ≤'-refl , ≤'-trans) d ys Ω) or ⁻¹)
      (interpolated-slf-minimises-loss cy d ys cy→ o₁ (pr₂ or) Ω ε))
 where
   o₁ : order _
   o₁ = (_≤'_ , ≤'-dec , ≤'-refl , ≤'-trans)

interpolation-theorem : {X : 𝓤 ̇ } {Y₁ : 𝓥 ̇ } {Y₂ : 𝓦 ̇ }
       → (cx : X → X → ℕ∞) (cy : Y₂ → Y₂ → ℕ∞)
       → everywhere-sin cy
       → (cy-r : right-continuous cy)
       → (𝓔S : c-searchable cx)
       → (o : order Y₁) (d : ℕ)
       → (ys : Y₁ ^⟨succ d ⟩) (or : ordered d o ys)
       → let
           Φ = sampled-loss-function cy d ys
           ϕᴸ = sampled-loss-right-continuous cy cy-r d ys
           Ψ = c-interpolation o d ys
         in (ε : ℕ)
       → (M : X → (Y₁ → Y₂)) (ϕᴹ : continuous² cx Φ M)
       → (k : X)
       → let
           Ω = M k
           ΨΩ = Ψ Ω
           reg = p-regressor cx Φ ϕᴸ 𝓔S ε
           ω = M (reg M ϕᴹ ΨΩ)
         in (under ε ≼ Φ ΨΩ ω)
interpolation-theorem cx cy cy→ cy-r 𝓔S o d ys or ε M ϕᴹ k
 = s-imperfect-convergence cx Φ ϕᴸ 𝓔S ε M ϕᴹ Ψ k
     (interpolated-slf-minimises-loss cy d ys cy→ o or Ω ε)
 where
  Φ = sampled-loss-function cy d ys
  Ψ = c-interpolation o d ys
  Ω = M k
  ϕᴸ = sampled-loss-right-continuous cy cy-r d ys
-}
```
