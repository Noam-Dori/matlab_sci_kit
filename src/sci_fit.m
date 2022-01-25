function fitData = sci_fit(xData,yData,xError,yError,titleStructs)
%UNTITLED Create a regression of the data with (optional) error bars
%   Detailed explanation goes here
% determine dimension of data. This is the basis for most loops.
data_size = size(xData,1);
points_size = size(xData, 2);

ignore_vector = -ones(1,points_size);

% basic setup
ft = fittype('poly1');
figure('Name', titleStructs.title);

% visual data
graphics = cell(1,2 * data_size);
titles = cell(1,2 * data_size);

hold on
fitData = zeros(data_size,2,3);
for data_index = 1:data_size
    % get regression
    [xCurve, yCurve] = prepareCurveData(xData(data_index,:), yData(data_index,:));
    fitresult = fit(xCurve, yCurve, ft);

    % extract polynomial values and errors
    fitData(data_index,:,1) = coeffvalues(fitresult);
    conf = confint(fitresult, 0.95);
    fitData(data_index,:,2) = (conf(2,:) - conf(1,:)) / 2;
    fitData(data_index,:,3) = fitData(data_index,:,2) ./ fitData(data_index,:,1);

    % create measurement graph
    % if the size of the error does not fit, extend it accordingly
    dataErrX = xError(rem(data_index - 1, size(xError,1)) + 1, :);
    dataErrY = yError(rem(data_index - 1, size(yError,1)) + 1, :);
    if size(dataErrX, 2) == 1
        dataErrX = dataErrX * ones(1, points_size);
    end
    if size(dataErrY, 2) == 1
        dataErrY = dataErrY * ones(1, points_size);
    end
    if dataErrX == ignore_vector
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
    graphics{2 * data_index} = plot(fitresult);
    graphics{2 * data_index}.Color = get_color(data_index);
    graphics{2 * data_index - 1}.Color = get_color(data_index);

    % titles
    if size(titleStructs.fit, 1) == 1
        titles{2 * data_index} = sprintf(titleStructs.fit, data_index);
    else
        titles{2 * data_index} = sprintf(titleStructs.fit(data_index), data_index);
    end
    if size(titleStructs.data, 1) == 1
        titles{2 * data_index - 1} = sprintf(titleStructs.data, data_index);
    else
        titles{2 * data_index - 1} = sprintf(titleStructs.data(data_index), data_index);
    end
end
legend(titles, 'Location', 'NorthWest', 'Interpreter', 'None');

% Label axes
xlabel(titleStructs.x_axis, 'Interpreter', 'none' );
ylabel(titleStructs.y_axis, 'Interpreter', 'none' );
title(titleStructs.title);

grid on
hold off
end

