% This example file can be used to generate a nice-looking figure by loading
% a pre-worked .txt data file
% 
% The cell named with "markStr_cell" and "colorStr_cell" used 
% in the function figureTemplate can be re-ordered if needed. 
% For example:
% markStr_cell = {'-', ':', '-.'}; % {'b', 'r', 'k', 'm'};
% colorStr_cell = {'b', 'r', 'k', 'm', 'g'}; %{'-', '-', '-'};
% 
% Note that the first field "data" used in figureTemplate function is with the 
% form of [x, y1, x, y2, x, y2, x, y3, ...], where x (yi, i=1, 2, 3, ...) are the 
% horizontal (vertical) parameter of the figure
%
% If ur x data cannot be broadcast/concatenate due to the different size/length
% modify and use the valid_data function to generate the dummy data point
% to meet the same length of rows. 
%
% This file is created and modified by Ryan Chung, Integrated Photonic Lab, 
% room 354 @ EE2 building, National Taiwan University.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear all; close all;
imported_data = loadData('APSO_param.txt', 1, ':');

data = [...
%             imported_data(:, 1), imported_data(:, 2)...   % weighting inertia parameter
            imported_data(:, 1), imported_data(:, 3), ...     % acceleration parameters
            imported_data(:, 1), imported_data(:, 4) ...     % acceleration parameters
            ];
figname = 'test';

xlabel = 'Generation index';
ylabel = 'Acceleration parameters';
ylabel = {'c_1', 'c_2'};
mode = 3;       % 1 for taller figure (v-b curve), 2 for shorter figure (transmission)
legend = {};

% xticksCell = {1.25:0.02:1.35, 'auto'};
xticksCell = get_ticksCell(0:5:50, 2);       % 1st field: xticks(0.25:0.05:1.5); 2nd field: xticklabels('0.25', '', '', '', '', '0.5', ...), only ticks at index of 1, 6, 11, 16, ... are shown with label
% yticksCell = {1.46:0.04:1.82, 'auto'};
yticksCell1 = get_ticksCell(1.7:.05:2.3, 2);      
yticksCell2 = get_ticksCell(1.7:.05:2.3, 2);     
yticksCell{1} = yticksCell1{1}; yticksCell{2} = yticksCell1{2};
yticksCell{3} = yticksCell2{1}; yticksCell{4} = yticksCell2{2};

% figureTemplate(data, xlabel, ylabel, mode, legend, figname); % fields for xticksCell and yticksCell can be empty
% figureTemplate(data, xlabel, ylabel, mode, legend, figname, xticksCell); % field for yticksCell can be empty
figureTemplate(data, xlabel, ylabel, mode, legend, figname, xticksCell, yticksCell);

function result = get_ticksCell(ticksVec, tickstep)
    for i = 1:length(ticksVec)
        if mod(i-1, tickstep) == 0
            tickslabelCell{i} = num2str(ticksVec(i));
        else
            tickslabelCell{i} = '';
        end
    end
    result = {ticksVec, tickslabelCell};
end

function data = copy_xvec(data0)
    data = zeros(size(data0, 1), (size(data0, 2)-1)*2);
    data(:, 1:2:end) = data0(:, 1)*ones(1, size(data0, 2)-1);
    data(:, 2:2:end) = data0(:, 2:end);
end

function data = valid_data(data0)
    w0 = data0(:, 1);
    idx0 = find(w0>=0.25);
    
    w0 = w0(idx0);
    w1 = w0;
    w2 = w0;
    n0 = data0(idx0, 2);

    n1 = data0(idx0, 3);
    idx1 = find(n1<0);
%     w1(idx1) = w1(idx1(end) +1);
%     n1(idx1) = n1(idx1(end)+1);
%     w1(idx1) = w1(idx1(end));
%     n1(idx1) = 0;
    
    n2 = data0(idx0, 4);
    idx2 = find(n2<0);
%     w2(idx2) = w2(idx2(end) +1);
%     n2(idx2) = n2(idx2(end)+1);
%     w2(idx2) = w2(idx2(end));
%     n2(idx2) = 0;

    data = [w0, n0, w1, n1, w2, n2];
end

function data = loadData(filePath_str, headerIgnore_num, columnExtraction_str)
    T = readtable(filePath_str, 'HeaderLines', headerIgnore_num);  % skips the first three rows of data
    eval(strcat("data = T{:, ", columnExtraction_str, "}; clear T;"));
end

function uplotxy(data)
    markStr_cell = {'-', '-', '-'};
    colorStr_cell = {'b', 'r', 'k', 'm'};
    n_color = length(colorStr_cell);
    xyDataStr = strcat("data(:, 1), data(:, 2), strcat(markStr_cell{1}, colorStr_cell{1})");
    if size(data, 2) >= 3
        for n = 3:2:size(data, 2)
            mod_n = mod((n + 1) / 2, n_color);
            if mod_n == 0
                mod_n = n_color;
            end
            xyDataStr = strcat(xyDataStr, ", data(:, ", num2str(n), "), data(:, ", num2str(n + 1), "), strcat(markStr_cell{", num2str(ceil((n + 1) / 2 / n_color)) , "}, colorStr_cell{", num2str(mod_n) , "})");
        end
    end
%     eval(strcat("semilogy(", xyDataStr, ", 'LineWidth', 2);"));
    eval(strcat("plot(", xyDataStr, ", 'LineWidth', 1);"));
end

function hx = set_yyxlabel(xlabelStr)
    hx = xlabel(xlabelStr, 'fontname', 'times new roman', 'fontweight', 'bold', 'FontSize', 12);
    ax = gca;
    ax.XColor = 'black';
end

function hy1 = set_leftyaxis(ylabelStr, yticksCell, YcolorStr)
    hy1 = ylabel(ylabelStr{1}, 'fontname', 'times new roman', 'fontweight', 'bold', 'FontSize', 12);
    yticksVec = yticksCell{1};
    ylim([min(yticksVec), max(yticksVec)]);
    yticks(yticksVec);
    % comment for only tex interpreter
    yticklabels(strcat('\textbf{', strrep(yticksCell{2}, '-', '$-$'), '}'));
    ytl = get(gca, 'YTicklabel');
    set(gca, 'yticklabel', ytl, 'FontName', 'Times New Roman');
    ax = gca;
    ax.YColor = YcolorStr;
end

function hy2 = set_rightaxis(ylabelStr, yticksCell, YcolorStr)
    hy2 = ylabel(ylabelStr{2}, 'fontname', 'times new roman', 'fontweight', 'bold', 'FontSize', 12);
    yticksVec = yticksCell{3};
    ylim([min(yticksVec), max(yticksVec)]);
    yticks(yticksVec);
    % comment for only tex interpreter
    yticklabels(strcat('\textbf{', strrep(yticksCell{4}, '-', '$-$'), '}'));
    ytl = get(gca, 'YTicklabel');
    set(gca, 'yticklabel', ytl, 'FontName', 'Times New Roman');
    ax = gca;
    ax.YColor = YcolorStr;
end

function figureTemplate(data, xlabelStr, ylabelStr, optMode, legendStr_cell, figureName, xticksCell, yticksCell)
    %% plot
    if optMode == 0
        figure('Units', 'centimeters', 'Position', [20, 10, 8, 6.486]);
    end
    %     figure('Units', 'inches', 'Position', [.41, .41, 2, 1.6]);
    if optMode == 1 || optMode == 4
        figure('Units', 'inches', 'Position', [5, 5, 3.4/0.8, 3.4/0.8*0.6]);
    end
    if optMode == 2 || optMode == 3
        figure('Units', 'inches', 'Position', [6, 6, 3.4/0.8, 3.4/0.8*0.31]);
    end

    
    %%
    if optMode == 0 || optMode == 1 || optMode == 2
        uplotxy(data);
        xtickangle(0);
    end
    
    %%
%     set(gca,'TickLabelInterpreter','tex'); % uncomment for only tex interpreter
    set(gca, 'TickLabelInterpreter', 'latex');  % comment for only tex interpreter
    
    %%
    if optMode == 3
        %% plot left y
        yyaxis left; 
        plot(data(:, 1), data(:, 2), '-b', 'LineWidth', 1);

        %% xlabel
        hx = set_yyxlabel(xlabelStr);
        
        %% left ylabel & ticks
        hy1 = set_leftyaxis(ylabelStr, yticksCell, 'blue');
        
        %% plot right y
        yyaxis right;
        plot(data(:, 3), data(:, 4), '-r', 'LineWidth', 1);

        %% right ylabel & ticks
        hy2 = set_rightaxis(ylabelStr, yticksCell, 'red');
        
        %% ensure the label font size
        set(hx, 'fontsize', 12); set(hy1, 'fontsize', 12); set(hy2, 'fontsize', 12);
    end
    
    if optMode == 4
        %% plot left y
        yyaxis left; 
        uplotxy(data(:, 1:24));

        %% xlabel
        hx = set_yyxlabel(xlabelStr);
        xtickangle(0);
        
        %% left ylabel & ticks
        hy1 = set_leftyaxis(ylabelStr, yticksCell, 'black');
        
        %% plot right y
        yyaxis right;
        uplotxy(data(:, 25:end));

        %% right ylabel & ticks
        hy2 = set_rightaxis(ylabelStr, yticksCell, 'black');
        
        %% ensure the label font size
        set(hx, 'fontsize', 12); set(hy1, 'fontsize', 12); set(hy2, 'fontsize', 12);
    end

    if nargin >= 7
        xticksVec = xticksCell{1};
        xlim([min(xticksVec), max(xticksVec)]);
        xticks(xticksVec);
        % comment for only tex interpreter
        xticklabels(strcat('\textbf{', xticksCell{2}, '}'));
        xtl = get(gca, 'XTicklabel');
        set(gca, 'xticklabel', xtl, 'FontName', 'Times New Roman');
    end
    yticklabels(strrep(yticklabels,'-','$-$'));
    if nargin == 8 && optMode ~=3 && optMode ~=4
        yticksVec = yticksCell{1};
        ylim([min(yticksVec), max(yticksVec)]);
        yticks(yticksVec);
        % comment for only tex interpreter
        yticklabels(strcat('\textbf{', strrep(yticksCell{2}, '-', '$-$'), '}'));
        ytl = get(gca, 'YTicklabel');
        set(gca, 'yticklabel', ytl, 'FontName', 'Times New Roman');
    end

    %%
    set(gca, 'FontWeight', 'bold', 'LineWidth', 2);

    %%
    if optMode ~=3 && optMode ~=4
        ylabel(ylabelStr, 'fontweight', 'bold', 'FontSize', 12, 'fontname', 'times new roman');
        xlabel(xlabelStr, 'fontweight', 'bold', 'FontSize', 12, 'fontname', 'times new roman');
    end
    if length(legendStr_cell) > 0
        legend(legendStr_cell, 'FontSize', 9, 'Box', 'off');
    end
%     title('channel_D channel_C channel_B channel_A');
%     set(gca, 'Units', 'centimeters', 'Position', [1.2, 1.2, 6.1, 4.675]);
%     set(gca, 'Units', 'inches', 'Position', [.45, .4, 1.6, 1.3]);
%     set(gca, 'Units', 'inches', 'Position', [.41, .41, 2, 1.6]);
%     set(gca, 'Units', 'inches', 'paperposition', [2.03125,3.489583333333333,4.4375,4.020833333333332]);
    set(gca, 'FontSize', 9); 
    savefig(strcat(figureName,'.fig'));
end