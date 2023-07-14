<pre class="Agda"><a id="9" class="Keyword">module</a> <a id="16" href="TWA.Thesis.index.html" class="Module">TWA.Thesis.index</a> <a id="33" class="Keyword">where</a>

<a id="40" class="Comment">-- Prelude files</a>
<a id="57" class="Keyword">open</a> <a id="62" class="Keyword">import</a> <a id="69" href="TWA.Thesis.Chapter2.FiniteDiscrete.html" class="Module">TWA.Thesis.Chapter2.FiniteDiscrete</a>
<a id="104" class="Keyword">open</a> <a id="109" class="Keyword">import</a> <a id="116" href="TWA.Thesis.Chapter2.Vectors.html" class="Module">TWA.Thesis.Chapter2.Vectors</a>
<a id="144" class="Keyword">open</a> <a id="149" class="Keyword">import</a> <a id="156" href="TWA.Thesis.Chapter2.Sequences.html" class="Module">TWA.Thesis.Chapter2.Sequences</a>
<a id="186" class="Keyword">open</a> <a id="191" class="Keyword">import</a> <a id="198" href="TWA.Thesis.Chapter5.PLDIPrelude.html" class="Module">TWA.Thesis.Chapter5.PLDIPrelude</a> <a id="230" class="Comment">-- TODO</a>

<a id="239" class="Comment">-- Chapter 3.2</a>
<a id="254" class="Keyword">open</a> <a id="259" class="Keyword">import</a> <a id="266" href="TWA.Thesis.Chapter3.ClosenessSpaces.html" class="Module">TWA.Thesis.Chapter3.ClosenessSpaces</a>
<a id="302" class="Keyword">open</a> <a id="307" class="Keyword">import</a> <a id="314" href="TWA.Thesis.Chapter3.ClosenessSpaces-Examples.html" class="Module">TWA.Thesis.Chapter3.ClosenessSpaces-Examples</a>

<a id="360" class="Comment">-- Chapter 3.1 + 3.3</a>
<a id="381" class="Keyword">open</a> <a id="386" class="Keyword">import</a> <a id="393" href="TWA.Thesis.Chapter3.SearchableTypes.html" class="Module">TWA.Thesis.Chapter3.SearchableTypes</a>
<a id="429" class="Keyword">open</a> <a id="434" class="Keyword">import</a> <a id="441" href="TWA.Thesis.Chapter3.SearchableTypes-Examples.html" class="Module">TWA.Thesis.Chapter3.SearchableTypes-Examples</a>

<a id="487" class="Comment">-- Chapter 4.1.1</a>
<a id="504" class="Keyword">open</a> <a id="509" class="Keyword">import</a> <a id="516" href="TWA.Thesis.Chapter4.ApproxOrder.html" class="Module">TWA.Thesis.Chapter4.ApproxOrder</a>
<a id="548" class="Keyword">open</a> <a id="553" class="Keyword">import</a> <a id="560" href="TWA.Thesis.Chapter4.ApproxOrder-Examples.html" class="Module">TWA.Thesis.Chapter4.ApproxOrder-Examples</a>

<a id="602" class="Comment">-- Chapter 4.1.3</a>
<a id="619" class="Keyword">open</a> <a id="624" class="Keyword">import</a> <a id="631" href="TWA.Thesis.Chapter4.GlobalOptimisation.html" class="Module">TWA.Thesis.Chapter4.GlobalOptimisation</a>

<a id="671" class="Comment">-- Chapter 4.2</a>
<a id="686" class="Keyword">open</a> <a id="691" class="Keyword">import</a> <a id="698" href="TWA.Thesis.Chapter4.ConvergenceTheorems.html" class="Module">TWA.Thesis.Chapter4.ConvergenceTheorems</a>

<a id="739" class="Comment">-- Chapter 5.1</a>
<a id="754" class="Keyword">open</a> <a id="759" class="Keyword">import</a> <a id="766" href="TWA.Thesis.Chapter5.IntervalObject.html" class="Module">TWA.Thesis.Chapter5.IntervalObject</a>
<a id="801" class="Keyword">open</a> <a id="806" class="Keyword">import</a> <a id="813" href="TWA.Thesis.Chapter5.IntervalObjectApproximation.html" class="Module">TWA.Thesis.Chapter5.IntervalObjectApproximation</a>

<a id="862" class="Comment">-- Chapter 5.2</a>
<a id="877" class="Keyword">open</a> <a id="882" class="Keyword">import</a> <a id="889" href="TWA.Thesis.Chapter5.SignedDigit.html" class="Module">TWA.Thesis.Chapter5.SignedDigit</a>
<a id="921" class="Keyword">open</a> <a id="926" class="Keyword">import</a> <a id="933" href="TWA.Thesis.Chapter5.SignedDigitIntervalObject.html" class="Module">TWA.Thesis.Chapter5.SignedDigitIntervalObject</a> <a id="979" class="Comment">-- TODO</a>

<a id="988" class="Comment">-- Chapter 5.3</a>
<a id="1003" class="Comment">-- open import TWA.Thesis.Chapter5.BoehmVerification</a>
<a id="1056" class="Keyword">open</a> <a id="1061" class="Keyword">import</a> <a id="1068" href="TWA.Thesis.Chapter5.BelowAndAbove.html" class="Module">TWA.Thesis.Chapter5.BelowAndAbove</a>

<a id="1103" class="Comment">-- Chapter 6.1</a>

<a id="1119" class="Keyword">open</a> <a id="1124" class="Keyword">import</a> <a id="1131" href="TWA.Thesis.Chapter6.SignedDigitContinuity.html" class="Module">TWA.Thesis.Chapter6.SignedDigitContinuity</a>
<a id="1173" class="Keyword">open</a> <a id="1178" class="Keyword">import</a> <a id="1185" href="TWA.Thesis.Chapter6.SignedDigitSearch.html" class="Module">TWA.Thesis.Chapter6.SignedDigitSearch</a>
<a id="1223" class="Keyword">open</a> <a id="1228" class="Keyword">import</a> <a id="1235" href="TWA.Thesis.Chapter6.SignedDigitExamples.html" class="Module">TWA.Thesis.Chapter6.SignedDigitExamples</a>
<a id="1275" class="Keyword">open</a> <a id="1280" class="Keyword">import</a> <a id="1287" href="TWA.Thesis.Chapter6.ZeroNormalisation.html" class="Module">TWA.Thesis.Chapter6.ZeroNormalisation</a>
<a id="1325" class="Keyword">open</a> <a id="1330" class="Keyword">import</a> <a id="1337" href="TWA.Thesis.Chapter6.Main.html" class="Module">TWA.Thesis.Chapter6.Main</a>

</pre>