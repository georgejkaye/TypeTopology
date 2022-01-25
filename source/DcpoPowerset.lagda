Tom de Jong, 25 January 2022

\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-}

open import SpartanMLTT

open import UF-FunExt
open import UF-PropTrunc
open import UF-Subsingletons

module DcpoPowerset
        (pt : propositional-truncations-exist)
        (fe : ∀ {𝓤 𝓥} → funext 𝓤 𝓥)
        (pe : propext 𝓤)
        {X : 𝓤 ̇  }
        (X-is-set : is-set X)
       where

open PropositionalTruncation pt

{-
open import UF-Equiv

open import UF-Miscelanea
open import UF-Subsingletons-FunExt


-}

open import List

open import UF-ImageAndSurjection
open import UF-Powerset
open import UF-Powerset-Fin pt
open import UF-Subsingletons-FunExt

open import Dcpo pt fe 𝓤
open import DcpoMiscelanea pt fe 𝓤
open import DcpoWayBelow pt fe 𝓤

open import Poset fe

open binary-unions-of-subsets pt
open canonical-map-from-lists-to-subsets X-is-set
open ImageAndSurjection pt
open singleton-subsets X-is-set
open unions-of-small-families pt

𝓟-dcpo : DCPO {𝓤 ⁺} {𝓤}
𝓟-dcpo = 𝓟 X , _⊆_ ,
         ( powersets-are-sets fe pe
         , ⊆-is-prop fe
         , ⊆-refl
         , ⊆-trans
         , λ A B → subset-extensionality pe fe)
         , dir-compl
 where
  dir-compl : is-directed-complete _⊆_
  dir-compl I α δ = ⋃ α , ⋃-is-upperbound α , ⋃-is-lowerbound-of-upperbounds α

𝓟-dcpo⊥ : DCPO⊥ {𝓤 ⁺} {𝓤}
𝓟-dcpo⊥ = (𝓟-dcpo , ∅ , ∅-is-least)

κ⁺ : (A : 𝓟 X) → (Σ l ꞉ List X , κ l ⊆ A) → 𝓟 X
κ⁺ A = κ ∘ pr₁

κ⁺-is-directed : (A : 𝓟 X) → is-Directed 𝓟-dcpo (κ⁺ A)
κ⁺-is-directed A = inh , semidir
 where
  inh : ∃ l ꞉ List X , κ l ⊆ A
  inh = ∣ [] , (∅-is-least A) ∣
  semidir : is-semidirected _⊆_ (κ⁺ A)
  semidir (l₁ , s₁) (l₂ , s₂) = ∣ ((l₁ ++ l₂) , s) , u₁ , u₂ ∣
   where
    e : κ (l₁ ++ l₂) ≡ κ l₁ ∪ κ l₂
    e = κ-of-concatenated-lists-is-union pe fe l₁ l₂
    u : (κ l₁ ∪ κ l₂) ⊆ κ (l₁ ++ l₂)
    u = ≡-to-⊑ 𝓟-dcpo (e ⁻¹)
    -- unfortunately, using the ⊑⟨ 𝓟-dcpo ⟩-syntax here gives
    -- implicit arguments problems, so we use ⊆-trans instead.
    u₁ : κ l₁ ⊆ κ (l₁ ++ l₂)
    u₁ = ⊆-trans (κ l₁) (κ l₁ ∪ κ l₂) (κ (l₁ ++ l₂))
          (∪-is-upperbound₁ (κ l₁) (κ l₂)) u
    u₂ = ⊆-trans (κ l₂) (κ l₁ ∪ κ l₂) (κ (l₁ ++ l₂))
          (∪-is-upperbound₂ (κ l₁) (κ l₂)) u
    s : κ (l₁ ++ l₂) ⊆ A
    s = ⊆-trans (κ (l₁ ++ l₂)) (κ l₁ ∪ κ l₂) A ⦅1⦆ ⦅2⦆
     where
      ⦅1⦆ : κ (l₁ ++ l₂) ⊆ (κ l₁ ∪ κ l₂)
      ⦅1⦆ = ≡-to-⊑ 𝓟-dcpo e
      ⦅2⦆ : (κ l₁ ∪ κ l₂) ⊆ A
      ⦅2⦆ = ∪-is-lowerbound-of-upperbounds (κ l₁) (κ l₂) A s₁ s₂

Kuratowski-finite-if-compact : (A : 𝓟 X)
                             → is-compact 𝓟-dcpo A
                             → is-Kuratowski-finite-subset A
Kuratowski-finite-if-compact A c =
 Kuratowski-finite-subset-if-in-image-of-κ A γ
  where
   claim : ∃ l⁺ ꞉ (Σ l ꞉ List X , κ l ⊆ A) , A ⊆ κ⁺ A l⁺
   claim = c (domain (κ⁺ A)) (κ⁺ A) (κ⁺-is-directed A) A-below-∐κ⁺
    where
     A-below-∐κ⁺ : A ⊆ ⋃ (κ⁺ A) -- TODO: Factor this out & prove the converse too
     A-below-∐κ⁺ x a = ⋃-is-upperbound (κ⁺ A) ([ x ] , s) x i
      where
       s : (❴ x ❵ ∪ ∅) ⊆ A
       s = ∪-is-lowerbound-of-upperbounds ❴ x ❵ ∅ A t (∅-is-least A)
        where
         t : ❴ x ❵ ⊆ A
         t _ refl = a
       i : x ∈ (❴ x ❵ ∪ ∅)
       i = ∪-is-upperbound₁ ❴ x ❵ ∅ x ∈-❴❵
   γ : A ∈image κ
   γ = ∥∥-functor h claim
    where
     h : (Σ l⁺ ꞉ (Σ l ꞉ List X , κ l ⊆ A) , A ⊆ κ⁺ A l⁺)
       → Σ l ꞉ List X , κ l ≡ A
     h ((l , s) , t) = (l , subset-extensionality pe fe s t)

∅-is-compact : is-compact 𝓟-dcpo ∅
∅-is-compact = ⊥-is-compact 𝓟-dcpo⊥

singletons-are-compact : (x : X) → is-compact 𝓟-dcpo ❴ x ❵
singletons-are-compact x I α δ l = ∥∥-functor h (l x ∈-❴❵)
 where
  h : (Σ i ꞉ I , x ∈ α i)
    → (Σ i ꞉ I , ❴ x ❵ ⊆ α i)
  h (i , m) = (i , (λ y p → transport (_∈ α i) p m))

∪-is-compact : (A B : 𝓟 X)
             → is-compact 𝓟-dcpo A
             → is-compact 𝓟-dcpo B
             → is-compact 𝓟-dcpo (A ∪ B)
∪-is-compact A B =
 binary-join-is-compact 𝓟-dcpo {A} {B} {A ∪ B}
  (∪-is-upperbound₁ A B) (∪-is-upperbound₂ A B)
  (∪-is-lowerbound-of-upperbounds A B)

compact-if-Kuratowski-finite : (A : 𝓟 X)
                             → is-Kuratowski-finite-subset A
                             → is-compact 𝓟-dcpo A
compact-if-Kuratowski-finite A k = lemma (A , k)
 where
  Q : 𝓚 X → 𝓤 ⁺ ̇
  Q A = is-compact 𝓟-dcpo (pr₁ A)
  lemma : (A : 𝓚 X) → Q A
  lemma = Kuratowski-finite-subset-induction pe fe X X-is-set Q
           (λ A → being-compact-is-prop 𝓟-dcpo (pr₁ A))
           ∅-is-compact
           singletons-are-compact
           (λ A B → ∪-is-compact (pr₁ A) (pr₁ B))

\end{code}