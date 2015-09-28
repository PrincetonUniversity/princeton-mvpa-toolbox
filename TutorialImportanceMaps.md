# Tutorial on looking at classifier weights (importance maps) #

If you want to create a brain map showing the weights from voxels to output units as a means of telling which voxels are providing information to the classifier (as per Polyn et al, 2005), see core/learn/interpret\_weights.m. This should implement the approach described in that paper. The help in that function is fairly extensive, though if you need more information, you might find it on the mailing list. See e.g.

http://groups.google.com/group/mvpa-toolbox/browse_thread/thread/7c3f1fcf8e4545/2567faa1637599c5?lnk=gst&q=interpret_weights.m#2567faa1637599c5

http://groups.google.com/group/mvpa-toolbox/browse_thread/thread/daea8ff18a711e97/b17512fa0faa95bd?lnk=gst&q=interpret_weights#b17512fa0faa95bd


## Neural networks with a hidden layer ##

N.B. Creating importance maps from neural networks with a hidden layer is a big pain. You're almost certainly better off ditching the hidden layer and using the more straightforward approach. But if you insist, read on.

[section is excerpted from an email conversation between Sean Polyn and Jarrod Lewis-Peacock on importance maps in neural networks with a hidden layer](This.md)

I have a question about how creating the classifier importance maps
as in your Science paper. In the supplemental material, you give
the algorithm for calculation the maps:

imp(ij) = w(ij) **avg(ij)** 100 ; where w(ij) is the weight between
input unit i and output unit j and avg(ij) is the average activity
of input i during study of category j.

How do you determine w(ij) if the neural network is the common 3-
layer backprop architecture, that has (1) input weights from each
input to each node in the hidden layer, (2) biases on each hidden
layer node, (3) layer weights from the hidden layer to the output
nodes, and (4) biases on each output node? I see that you used a 2-
layer network in your paper.

I'm working on this now, and I wondered if you have figured this
out for a 3-layer network yet?



I can't find the code that I once wrote, but I found a presentation I
gave that did exactly this!  I put it on my website.

http://www.polyn.com/struct/polynetal_OHBM04.pdf

(Polyn S.M., Nystrom L.E., Norman K.A., Haxby J.V., Gobbini M.I., &
Cohen J.D. (2004) Using neural network algorithms to investigate
distributed patterns of brain activity in fMRI. Poster presented at
OHBM conference. Budapest, Hungary.)

I'm cc'ing Greg Detre on this, as he may have worked through this as
well at one point.  Hi Greg!

As you've realized, it is a tricky business to figure out the exact
contribution that a particular voxel has for a given classification
when one is using a 3-layer network.  There are a lot of avenues by
which a given input unit can influence a given output unit.  One can
do something analogous here, and I'll step through it.

Determining the importance of a given input unit on a given output
unit (for a given condition/category) for a 3-layer network.

---


- calculate the average activity of the input unit for that condition
(avg\_input)

- calculate the average activity for each of the hidden units for that
condition (avg\_hidden)

VERSION FROM POSTER
- for loop over i hidden units:
total\_importance = total\_importance + (w\_input\_to\_hidd(i) **w\_hidd\_to\_out(i))**

ALTERNATE VERSION
- for loop over i hidden units:
total\_importance = total\_importance + (avg\_input **w\_input\_to\_hidd(i)** avg\_hidden(i) **w\_hidd\_to\_out(i))**

I think I like the alternate version better now... I guess I was young
and naive then... you could whip up a synthetic dataset like I
describe in the poster and compare the two pretty easily.

The reason biases don't appear in the equations is because the biases,
in a sense, determine the average activity of the hidden units --- the
average activity is the important thing, if the hidden unit is always
off there will be no contribution to the importance value...

One potential pitfall (perhaps) is that if I recall my days of 3-layer
BP, sometimes a given hidden unit will always be active across all
categories --- so it can't really be helping the classification, the
network is just using it as an extra bias, in a sense.  Once I started
thinking about how to correct for this I think I threw up my hands and
decided to stick with 2-layer BP.

I know this is a lot of info all at once so let me know if you have
any questions!

Best,
Sean




Thanks for the response Sean.


> Out of curiosity --- are you dealing with a result that obtains with
> a 3-layer network but not with a 2-layer network?  That would be
> exciting --- I haven't yet come across a case where adding the hidden
> layer improved classification ability (which always surprised me a
> bit but I figured was due to overfitting).


Yes indeed we have the case where a 3-layer outperforms a 2-layer.
This isn't true when we do the N-minus-1 classification on the
training data by itself. However, when we use the entire training
data (the perceptual/semantic processing task as in your Science
paper) to train the network, then test the network on a completely
different task (a delayed paired-associate working memory task in
this case), the 3-layer network outperforms the 2-layer. That is, on
certain trials where we expect to see a certain result ( e.g.
face-like activity during the delay period), the 3-layer network more
reliably shows face-like activity. I don't think we have any
overfitting going on here because the training data task and testing
data task are different. The brain patterns serving task 1 and task 2
are (at least somewhat) different. It is whatever overlap exists
between the task 1 patterns and the task 2 patterns that allows us to
generalize at all in the neural network.


---


CategoryTutorials