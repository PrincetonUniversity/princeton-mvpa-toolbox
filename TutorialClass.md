# Classification tips and tricks #

---



## Backprop parameters ##
Tweaking the backpropagation classification parameters is pretty easy. For instance, if you want to use a different backpropagation algorithm (using the Matlab Neural Networks toolbox), just add the following argument to 'class\_args', before calling cross\_validation.m_:_

```
>> class_args.alg = 'traincgb';
```

or if you want to include a hidden layer with 10 units:

```
class_args.nHidden = 10;
```

See [train\_bp.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/train_bp.m) and [train\_bp\_netlab.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/train_bp_netlab.m) for more information.

## Getting rid of 1-of-n warnings using propval ##
In the original tutorial, you kept being besieged by warnings like 'Warning: Not 1-of-n regressors' during classification. This was because you were trying to train your classifiers on rest timepoints, and the toolbox was warning you in case that wasn't your intention.

Having used the 'runs\_xval\_norest' selector group (which was created using the 'norest' actives selector to exclude rest timepoints), that warning should go away.

If you want to know how to turn it off anyway, here's how:

```
>> cv_args.perfmet_args.ignore_1ofn = true; 

>> [subj results] = cross_validation(subj,'epi_z','conds_conv','runs_xval_norest','3dD_200',class_args,cv_args); 
```

In other words, you need to add an optional 'perfmet\_args' argument to the _cross\_validation.m_ call, which contains a structure that will be passed to the _perfmet\_maxclass.m_ function.

One of the internal functions has an optional argument ('ignore\_1ofn') that turns off the warning, and we need to pass this optional argument as part of an optional argument to cross\_validation.m itself. This is the same kind of thing that we're doing when we pass an optional 'statmap\_arg' optional argument to feature\_select.m_._

## Performance metrics ##
Under construction.

## Visualizing the classifier's responses ##
Let's say you've just finished running a classification analysis, and you want to know a little more about how things are working.

One of the most useful ways to analyze the classification data is to plot a [[http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/util/multiple\_iterations\_confusion.m confusion matrix](See.md), showing the classifier's guesses for each condition. This is easy to do:

```
confmat = multiple_iterations_confusion(results);
```

This will flash up an image where the rows represent the right answers, and the columns the classifier's guesses. Ideally, the on-diagonal elements will be highest (where the guesses == right answers). Sometimes, some hidden systematicity in the classifier's outputs becomes apparent. Perhaps the classifier's guesses for two similar conditions are forgivably switched around. Or perhaps the classifier is struggling with one condition in particular, or keeps guessing the same condition over and over. MULTIPLE\_ITERATIONS\_CONFUSION.M amalgamates the results from all the separate classifier iterations.

Simply plotting the classifier's outputs over time is also often a useful diagnostic visualization.

```
>> plot(results.iterations(1).acts')
>> titlef('Classifier outputs')
```

[N.B. Note that these are the responses for the first iteration only.]

You might also want to show what the correct answers should have been on a separate figure.

```
% check which regressors object we used this time
regsname = results.iterations(1).created.regsname

figure, plot(regs(:, results.iterations(1).test_idx)')
titlef('Correct answers')
```

This occasionally highlights some gross bug, such as when the classifier's activity is permanently flat at one or zero.

## Scrambling regressors ##
The toolbox tries to make it hard for you to peek. That is, it makes it hard to train the classifier on the same timepoints it will be tested on later. This is a critical mistake, because it renders your results meaningless. And it's a mistake that you can make in a variety of subtle ways.

To demonstrate how much of a problem peeking is, consider this thought experiment. In a legitimate no-peeking analysis, if you were to scramble the condition labels for each timepoint, and then train and test a classifier, your performance would be no better than chance . Perhaps on some attempts performance would be higher than chance, but other times it would be lower. Such is the nature of chance. If you were to run some non-parametric test, it would not be significant.

On the other hand, imagine if you were to accidentally expose your classifier to some of the test timepoints during training. The weights would be tweaked during training to improve performance on the training set, and so, by definition, the classifier will do better than chance when re-exposed to those some timepoints at test. It might or might not do much better than chance, but over a large enough sample of attempts, it will perform at a level statistically higher than chance. In fact, if you were to tweak the parameters a little, and do some feature selection using the same timepoints your classifier was trained on (including some of the test timepoints), you could probably artificially boost this illegitimate peeking performance considerably further.

Just remember - we scrambled the condition labels on these timepoints. We deliberately destroyed any relationships between the timepoints before beginning the analysis. The fact that the classifier's generalization performance on scrambled regressors is above chance is incontrovertible evidence that your analysis is peeking. The above-chance performance levels tell you nothing publishable. I think we can agree that we definitely want to avoid inadvertently making this mistake in a real analysis.

The [scramble\_regressors.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/scramble_regressors.m) function simply provides a convenient way to scramble your condition labels. Then, you can run your entire analysis exactly as before, but using these scrambled regressors, and breathe a sigh of relief when performance drops to chance.

```
>> subj = scramble_regressors(subj,'conds_conv_thr','runs','conds_conv_thr_scr');
```

P.S. One might question whether such a simple operation as scrambling requires its own function. Actually, the precise way that you scramble could potentially make a difference. This function takes in a runs selector argument, to ensure that the scrambling takes place within runs, to preserve the statistics of your conditions. Likewise, it scrambles the columns not the rows, since we want to preserve the statistics of how many conditions are active at once.

## Assessing the significance of your classifier's performance ##
[N.B. This part of the tutorial relies on functionality from version 1.0 of the toolbox (which hasn't yet been released at the time of writing).]

Let's say that chance is 50%, and you're pretty consistently getting 55% performance. Is that significant? Is it publishable? This is an active area of research, and different people have different answers.

[Polyn et al (2005)](http://compmem.princeton.edu/publications.html#PolynEtAl_2005) describe a non-parametric statistical test for whether the classifier's performance is better than chance. By repeatedly generating carefully scrambled versions of the classifier output, they create a null distribution of performance values against which the actual performance value can be compared.  Rather than just permuting the order of the timepoints, this method scrambles the coefficients of a wavelet decomposition of the classifier outputs to take into account their time-varying spectral characteristics (e.g. the fact that the classifier outputs probably vary slowly over time with the condition labels). See [wavestrapper\_results.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/wavestrapper_results.m) and [wavelet\_scramble\_multi.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/util/wavelet_scramble_multi.m) for an implementation of this wavelet-based scrambling technique.

```
pval = wavestrapper_results(results);
```

See [Bullmore et al (2004)](http://www.ncbi.nlm.nih.gov/sites/entrez?Db=pubmed&Cmd=ShowDetailView&TermToSearch=15501094&ordinalpos=2&itool=EntrezSystem2.PEntrez.Pubmed.Pubmed_ResultsPanel.Pubmed_RVDocSum), 'Wavelets and functional magnetic resonance imaging of the human brain', _Neuro Image 23_, suppl S234-49, for more information.

[N.B. Both the above wavelet-based functions rely on the Matlab Wavelets toolbox.]

[remainder of this section is under construction.](The.md)