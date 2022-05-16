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
    case "running_avg_2"
        val = zeros(1, size(inputVals, 2) - 1);
        valErr = zeros(size(val));
        for i = 1:size(inputVals, 2) - 1
            val(:, i) = (inputVals(:, i) + inputVals(:, i + 1)) / 2;
            valErr(:, i) = hypot(inputErrs(:, i), inputErrs(:, i + 1)) / 2;
        end
    case "int"
        % yN = SUM(DIFF(xI) * dyI)
        val = cumtrapz(inputVals(1, :), inputVals(2, :));
        [diffX, diffXErrs] = stat_errorf("diff", inputVals(1, :), inputErrs(1, :));
        [avgY, avgYErrs] = stat_errorf("running_avg_2", inputVals(2, :), inputErrs(2, :));
        elementErr = hypot(diffX .* avgYErrs, diffXErrs .* avgY);
        valErr = zeros(1, size(inputVals, 2));
        for i = 1:size(inputVals, 2) - 1
            valErr(i + 1) = sqrt(sum(elementErr(1:i) .^ 2, 2));
        end
end

end