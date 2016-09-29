function y = randSort(x)
% y = randSort(x)
% sort rows randomly

dims = size(x);
if dims(2)>dims(1)
    x = x';
end

RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));

y = x(randperm(size(x,1)),:);


end
