# Howtos #

## Results ##


### How do I get the testtargs that my classifier was trained on' ###

Inside _results.iterations(i)_:

> _test\_idx_ tells you **which** TRs were used as test data

> _created.regsname_ tells you which your regressors object was

So, to get the ''testtargs'' for the first iteration:

```
>> i = 1; 

>> regsname = results.iterations(i).created.regsname;

>> conds = get_mat(subj,'regressors',regsname);

>> test_idx = results.iterations(i).test_idx;

>> testtargs = conds(:,test_idx); 
```

We could have chosen to save things in more than one place, but instead we decided not to save anything redundantly, but to save **enough** that you could find or generate anything you need.

We plan to implement a plugin function that allows you to change the defaults of what gets saved into the _results_ structure in the future, so that you could tailor things to make them more convenient for you.