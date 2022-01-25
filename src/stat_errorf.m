function [val, valErr] = stat_errorf(func, inputVals, inputErrs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if size(inputErrs,2) == 1
    inputErrs = inputErrs .* ones(1, size(inputVals,2));
end
if size(inputErrs,1) == 1
    inputErrs = inputErrs .* ones(size(inputVals,1), 1);
end

switch func
    case "sum"
        val = sum(inputVals, 2);
        valErr = sqrt(sum(inputErrs .^ 2, 2));
    case "mean"
        val = mean(inputVals, 2);
        valErr = sqrt(sum(inputErrs .^ 2, 2)) / size(inputVals, 2);
    case "diff"
        val = diff(inputVals, 1, 2);
        valErr = zeros(size(val));
        for i = 1:size(inputVals, 2) - 1
            valErr(:, i) = hypot(inputErrs(:, i), inputErrs(:, i + 1));
        end
    case "mean_diff"
        [diffVals, diffErrs] = stat_errorf("diff", inputVals, inputErrs);
        [val, valErr] = stat_errorf("mean", diffVals, diffErrs);
end

end