# Howtos #



### Why is my generalization performance poor ###

See: [Troubleshooting poor classification performance](#_Troubleshooting_poor_classification.md).


### How do I find the weights that backprop has learned ###

If you're using the Mathworks Neural Networks toolbox, they're stored in the net (that gets saved to results.iterations(i).scratchpad) object in the 'weight and bias values' section. See the [Matlab Neural Networks manual](http://www.mathworks.com/access/helpdesk/help/toolbox/nnet/) for more information.

See the [Netlab](http://www.ncrg.aston.ac.uk/netlab/) mlp.m help (and also [here](http://www.ncrg.aston.ac.uk/netlab/book.php)) for more information about where the Netlab net object stores the weights matrix or matrices.


### What if I want to train or test on averaged data ###

If you want to train and test on averaged data, then the easiest thing to do would be to average all of your patterns, regressors and selectors, and just run the analysis as normal with the averaged data.

If you're trying to train on single TRs but test on averaged data, things are a little more complicated. There are two main solutions.

1. Implement the averaging inside your training or testing function. This is easy to do.

2. Have one copy of your pattern, regressors and mask that's unaveraged, and one copy that's averaged. Then, you'd have to either hack cross\_validation.m, or maybe feed in the data that you want to use in through the extra arguments of the training/testing functions.

If you're planning to do this, let us know and we'll try and help, since averaging definitely helps and this functionality will be useful to others.


### My classifier sometimes hangs in the srchcha bit of the algorithm, why ###
<a href='Hidden comment: 
See: http://newsreader.mathworks.com/WebX"50@482.SFQaa3hT5tQ.0@.eefecf2
link no longer valid.
'></a>
We've experienced this problem occasionally and we never found a solution. Please [contact us](mailto:mvpa-toolbox@googlegroups.com) if you think you're having this problem so that we can help Mathworks debug the problem with as many examples as possible ' better still, let us know if you fix it'

Update ELN: Try using a different training function (e.g. trainscg instead of traincgb) just change the alg field of the class\_args that you feed into cross\_validation.m:

```
>> class_args.train_funct_name = 'train_bp'; 

>> class_args.test_funct_name = 'test_bp';

>> class_args.nHidden = 0;

>> class_args.alg = 'trainscg';

etc.

>> [subj results] = cross_validation(blahblahblah'); 
```

A little more background to what these functions are:

When a network hangs, or never finishes training it is commonly due to the function srchcha.m entering into a never-satisfied while-loop. srchcha is a line search function used by the default training algorithm in the toolbox called _traincgb_. This is a powerful and effective training algorithm that looks for the direction of the steepest gradient and then performs a line search in the direction of that gradient to decide how far in that direction to adjust the weights. _Traincgb_ is an example of a conjugate training algorithm, meaning it uses information about the direction of steepest descent from previous epochs to guide the learning on the current epoch. Conjugate training algorithms (accoding to Mathworks) converge faster than other training algorithms and thus are nice to use. Another such algorithm is _trainscg_  a major difference however is that this function does not use a line search algorithm to determine the next weight update and thus avoids the problem of hanging nets.

See the [comparison](http://www.mathworks.com/access/helpdesk/help/toolbox/nnet/backpro2.html#34220) in the Backpropagation chapter of the [Matlab NN toolbox manual](http://www.mathworks.com/access/helpdesk/help/toolbox/nnet/) for more information.


### Why do I sometimes get a divide-by-zero error when training ###

We believe that this just means that your performance is improving very very slowly with training, and so when the neural network algorithm tries to calculate the gradient of its performance improvement, it's dividing by zero. So, we don't think'' it indicates a major problem. If you want to get rid of it, make your stopping criteria a little more strict, or try the solution described in [My classifier sometimes hangs in the srchcha bit of the algorithm, why](HowtosClassification#My_classifier_sometimes_hangs_in_the_srchcha_bit_of_the_algorith.md).