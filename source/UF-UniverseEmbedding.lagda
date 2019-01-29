Martin Escardo, 29th January 2019

If univalence holds, then any universe is embedded into any larger universe.

Moreover, any map (f : 𝓤 ̇ → 𝓤 ⊔ 𝓥 ̇) with f X ≃ X for all X : 𝓤 is en
embedding, for example X ↦ X + 𝟘 {𝓥}.

We do this without cumulativity,
because it is not available in the Martin-Loef type theory that we are
working with in Agda.

\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-}

open import UF-Univalence

module UF-UniverseEmbedding (ua : Univalence) where

open import SpartanMLTT
open import UF-Base
open import UF-Embedding
open import UF-Equiv
open import UF-EquivalenceExamples
open import UF-FunExt
open import UF-Equiv-FunExt
open import UF-UA-FunExt

private
 fe : FunExt
 fe = FunExt-from-univalence ua

 nfe : {X : 𝓤 ̇} {A : X → 𝓥 ̇} {f g : Π A} → f ∼ g → f ≡ g
 nfe {𝓤} {𝓥} = dfunext (fe 𝓤 𝓥)

inverse-involutive : {X : 𝓤 ̇} {Y : 𝓥 ̇} (f : X → Y) (e : is-equiv f)
                   → inverse (inverse f e) (inverse-is-equiv f e) ≡ f
inverse-involutive f e = refl

≃-sym-involutive : {X : 𝓤 ̇} {Y : 𝓥 ̇} (ε : X ≃ Y)
                 → ≃-sym (≃-sym ε) ≡ ε
≃-sym-involutive {𝓤} {𝓥} {X} {Y} (f , e) = to-Σ-≡ (p , being-equiv-is-a-prop fe f _ e)
 where
  p : inverse (inverse f e) (inverse-is-equiv f e) ≡ f
  p = inverse-involutive f e

≃-Sym : {X : 𝓤 ̇} {Y : 𝓥 ̇}
    → (X ≃ Y) ≃ (Y ≃ X)
≃-Sym {𝓤} {𝓥} {X} {Y} = qinveq ≃-sym (≃-sym , ≃-sym-involutive , ≃-sym-involutive)

≃-Trans : {X : 𝓤 ̇} {Y : 𝓥 ̇} {Z : 𝓦 ̇}
        → X ≃ Y → (Y ≃ Z) ≃ (X ≃ Z)
≃-Trans {𝓤} {𝓥} {𝓦} {X} {Y} {Z} (f , e) = qinveq (≃-trans κ) (≃-trans (≃-sym κ) , γφ , φγ)
 where
  κ : X ≃ Y
  κ = (f , e)
  γφ : (δ : Y ≃ Z) → ≃-trans (≃-sym κ) (≃-trans κ δ) ≡ δ
  γφ (g , d) = to-Σ-≡ (p , being-equiv-is-a-prop fe g _ d)
   where
    p : g ∘ f ∘ inverse f e ≡ g
    p = ap (g ∘_) (nfe (inverse-is-section f e))
  φγ : (ε : X ≃ Z) → ≃-trans κ (≃-trans (≃-sym κ) ε) ≡ ε
  φγ (h , c) = to-Σ-≡ (p , being-equiv-is-a-prop fe h _ c)
   where
    p : h ∘ inverse f e ∘ f ≡ h
    p = ap (h ∘_) (nfe (inverse-is-retraction f e))

Id-Eq-cong : (X Y : 𝓤 ̇) (A B : 𝓥 ̇)
           → X ≃ A → Y ≃ B → (X ≡ Y) ≃ (A ≡ B)
Id-Eq-cong {𝓤} {𝓥} X Y A B d e =
 (X ≡ Y) ≃⟨ is-univalent-≃ (ua 𝓤) X Y ⟩
 (X ≃ Y) ≃⟨ ≃-Trans (≃-sym d) ⟩
 (A ≃ Y) ≃⟨ ≃-Sym ⟩
 (Y ≃ A) ≃⟨ ≃-Trans (≃-sym e) ⟩
 (B ≃ A) ≃⟨ ≃-Sym ⟩
 (A ≃ B) ≃⟨ ≃-sym (is-univalent-≃ (ua 𝓥) A B) ⟩
 (A ≡ B)  ■

\end{code}

With this, we can prove the main result of this module:

\begin{code}

universe-embedding-criterion : (𝓤 𝓥 : Universe) (f : 𝓤 ̇ → 𝓤 ⊔ 𝓥 ̇)
                             → ((X : 𝓤 ̇) → f X ≃ X)
                             → is-embedding f
universe-embedding-criterion 𝓤 𝓥 f i = embedding-criterion' f γ
 where
  γ : (X X' : 𝓤 ̇) → (f X ≡ f X') ≃ (X ≡ X')
  γ X X' = Id-Eq-cong (f X) (f X') X X' (i X) (i X')

\end{code}

For instance:

\begin{code}

module example where

 universe-up : (𝓤 𝓥 : Universe) → 𝓤 ̇ → 𝓤 ⊔ 𝓥 ̇
 universe-up 𝓤 𝓥 X = X + 𝟘 {𝓥}

 universe-up-is-embedding : is-embedding (universe-up 𝓤 𝓥)
 universe-up-is-embedding {𝓤} {𝓥} = universe-embedding-criterion 𝓤 𝓥
                                      (universe-up 𝓤 𝓥)
                                      (λ X → 𝟘-rneutral' {𝓤} {𝓥} {X})

\end{code}