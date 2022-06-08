function fitData = sci_fit(xData,yData,xError,yError,titleStructs)
%UNTITLED Create a regression of the data with (optional) error bars
%   Detailed explanation goes here
% determine dimension of data. This is the basis for most loops.
data_size = size(yData,1);
points_size = size(yData, 2);

% if neccesary, convert xData to match y dimension
if size(xData,1) == 1
    xData = xData .* ones(size(yData,1), 1);
end

% basic setup
ft = fittype('poly1');
figure('Name', titleStructs.title);

% visual data
graphics = cell(1,2 * data_size);
titles = cell(1,2 * data_size);

hold on
fitData = zeros(data_size,2,4);
isRegression = contains(titleStructs.data, "Regression");
titleStructs.data = strrep(titleStructs.data, "%Regression%", "");
if size(isRegression, 1) == 1
    isRegression = isRegression .* ones(size(yData,1), 1);
end
for data_index = 1:data_size
    % create measurement data
    % if the size of the error does not fit, extend it accordingly
    dataErrX = xError(rem(data_index - 1, size(xError,1)) + 1, :);
    dataErrY = yError(rem(data_index - 1, size(yError,1)) + 1, :);
    if size(dataErrX, 2) == 1
        dataErrX = dataErrX * ones(1, points_size);
    end
    if size(dataErrY, 2) == 1
        dataErrY = dataErrY * ones(1, points_size);
    end
    % delete data using the -2 consideration
    cond = (dataErrX ~= -2) & (dataErrY ~= -2);
    graphX = xData(data_index,:);
    graphX = graphX(cond);
    graphY = yData(data_index,:);
    graphY = graphY(cond);
    dataErrX = dataErrX(cond);
    dataErrY = dataErrY(cond);

    ignore_vector = -ones(size(dataErrX));

    % get regression
    [xCurve, yCurve] = prepareCurveData(graphX, graphY);
    [fitresult, dataGOF] = fit(xCurve, yCurve, ft);

    % extract polynomial values and errors
    fitData(data_index,:,1) = coeffvalues(fitresult);
    conf = confint(fitresult, 0.95);
    fitData(data_index,:,2) = (conf(2,:) - conf(1,:)) / 2;
    fitData(data_index,:,3) = fitData(data_index,:,2) ./ fitData(data_index,:,1);
    fitData(data_index,:,4) = [dataGOF.rsquare, dataGOF.sse];

    if isRegression(data_index)
        graphics{2 * data_index - 1} = plot(xCurve,yCurve);
    elseif dataErrX == ignore_vector
        if dataErrY == ignore_vector % none - O
            graphics{2 * data_index - 1} = plot(xCurve,yCurve,'o');
        else % errY
            graphics{2 * data_index - 1} = errorbar(xCurve,yCurve,dataErrY,'vertical','.');
        end
    else
        if dataErrY == ignore_vector % errX
            graphics{2 * data_index - 1} = errorbar(xCurve,yCurve,dataErrX,'horizontal','.');
        else % errX+errY
            graphics{2 * data_index - 1} = errorbar(xCurve,yCurve,dataErrY,dataErrY,dataErrX,dataErrX,'.');
        end
    end

    % graph fit result after data to ensure it is drawn in its entirety
    if titleStructs.fit(rem(data_index - 1, size(titleStructs.fit,1)) + 1) ~= "IGNORE" && ~isRegression(data_index)
        graphics{2 * data_index} = plot(fitresult);
    end
    graphics{2 * data_index}.Color = get_color(data_index);
    color_pullback = isRegression(data_index) * (1 - isRegression(max(1,data_index - 1)));
    graphics{2 * data_index - 1}.Color = get_color(max(1, data_index - color_pullback));

    % titles
    if titleStructs.fit(rem(data_index - 1, size(titleStructs.fit,1)) + 1) ~= "IGNORE" && ~isRegression(data_index)
        titles{2 * data_index} = sprintf(titleStructs.fit(rem(data_index - 1, size(titleStructs.fit,1)) + 1), data_index);
    end
    titles{2 * data_index - 1} = sprintf(titleStructs.data(rem(data_index - 1, size(titleStructs.data,1)) + 1), data_index);
end
warning('off','MATLAB:legend:IgnoringExtraEntries')
legend(titles(~cellfun('isempty',titles)), 'Location', 'NorthWest', 'Interpreter', 'latex');
warning('on','MATLAB:legend:IgnoringExtraEntries')

% Label axes
xlabel(titleStructs.x_axis, 'Interpreter', 'latex');
ylabel(titleStructs.y_axis, 'Interpreter', 'latex');
title(titleStructs.title, 'Interpreter', 'latex');

grid on
hold off
end