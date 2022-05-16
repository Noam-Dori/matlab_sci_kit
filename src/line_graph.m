function line_graph(xData,yData,xError,yError,titleStructs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data_size = size(yData,1);
points_size = size(xData, 2);

% if neccesary, convert xData to match y dimension
if size(xData,1) == 1
    xData = xData .* ones(size(yData,1), 1);
end

% basic setup
figure('Name', titleStructs.title);

% visual data
graphics = cell(1, data_size);
titles = cell(1, data_size);

hold on
for data_index = 1:data_size
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
    % delete data using the -2 consideration
    cond = (dataErrX ~= -2) & (dataErrY ~= -2);
    graphX = xData(data_index,:);
    graphX = graphX(cond);
    graphY = yData(data_index,:);
    graphY = graphY(cond);
    dataErrX = dataErrX(cond);
    dataErrY = dataErrY(cond);

    ignore_vector = -ones(size(dataErrX));

    if dataErrX == ignore_vector
        if dataErrY == ignore_vector % none
            if contains(titleStructs.data(data_index), "Regression")
                graphics{data_index} = plot(graphX, graphY);
            else
                graphics{data_index} = plot(graphX, graphY, 'o');
            end
        else % errY
            graphics{data_index} = errorbar(graphX, graphY,dataErrY,'vertical','.');
        end
    else
        if dataErrY == ignore_vector % errX
            graphics{data_index} = errorbar(graphX, graphY,dataErrX,'horizontal','.');
        else % errX+errY
            graphics{data_index} = errorbar(graphX, graphY,dataErrY,dataErrY,dataErrX,dataErrX,'.');
        end
    end

    % titles
    if size(titleStructs.data, 1) == 1
        titles{data_index} = sprintf(titleStructs.data, data_index);
    else
        titles{data_index} = sprintf(titleStructs.data(data_index), data_index);
    end
end
legend(titles, 'Location', 'NorthWest', 'Interpreter', 'latex');

% Label axes
xlabel(titleStructs.x_axis, 'Interpreter', 'latex' );
ylabel(titleStructs.y_axis, 'Interpreter', 'latex' );
title(titleStructs.title, 'Interpreter', 'latex');

grid on
hold off
end

