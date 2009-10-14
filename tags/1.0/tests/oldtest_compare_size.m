function [success errmsg] = test_compare_size()

success = 1;
errmsg = '';

a = rand(10);
if ~compare_size(a,a)
  success = 0;
  errmsg = 'Something basic wrong';
end

b = rand([10 5]);
if compare_size(b,b')
  success = 0;
  errmsg = 'Problem with transposing';
end


