# Advanced Manual #

## Accessing the subj structure directly ##

We realise that using the accessor functions is slightly more cumbersome than accessing the contents of the _subj_ structure directly. However, bypassing them can cause many subtle problems and is not recommended.

Having said that, nothing can go wrong if you're just using the standard syntax to view an object, e.g.
```

>> subj.regressors{5}

```

It's really only when you change the values in an object that there's a real risk of things getting badly confused amidst the assumptions and interactions between functions. Hopefully, these should all be preserved intact by the provided accessor functions.

We will provide one example of how the accessor scripts can help. If you remove voxels from a _pattern_ by just deleting them from the matrix, this could disrupt all the fragile indexing that is used to determine which voxel is which. In order to avoid this, _set\_mat.m_ makes it very difficult to change the dimensions of the _pattern_ matrix, unless you are using the [authorized masking functionality that preserves the indexing](ManualAdvancedVoxelLocation.md). Such bugs can be particularly insidious because they may or may not cause errors. In the worst case, your analysis could run without incident, but actually scramble your voxels.

These [handy shortcuts](ManualAdvancedShortcuts.md) may make your life a little easier.