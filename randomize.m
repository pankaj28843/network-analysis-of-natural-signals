function [randomized_ts] = randomize(ts)
[M, N] = size(ts);
randomized_ts = [];
for i=1:M
    r = round(rand()*M*0.05)+1;
    randomized_ts = [randomized_ts; ts(i, r:N), ts(i, 1:r-1)];
end