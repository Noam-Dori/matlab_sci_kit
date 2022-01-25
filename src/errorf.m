function [val, valErr] = errorf(func, inputVals, inputErrs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% if neccesary, convert input errs to match data dimension
if size(inputErrs,2) == 1
    inputErrs = inputErrs * ones(1,size(inputVals,2));
end

% pre-work
inputCellArr = num2cell(inputVals,2);
symbols = argnames(func);

% calculate value
val = double(func(inputCellArr{:}));

% calculate the partial derivatives
errElements = zeros(size(inputVals));
for idx = 1:size(inputVals,1)
    partial = diff(func,symbols(idx));
    errElements(idx, :) = double(partial(inputCellArr{:}) .* inputErrs(idx));
end

valErr = sqrt(sum(errElements .^ 2, 1));
end

