clear;
clc;

% 第一问主程序
excelFileName = 'data1.xlsx'; 

% 定日镜位置信息
positions(:, 1:2) = xlsread(excelFileName);
data_len = size(positions, 1);
% 定日镜安装高度
positions(:, 3) = 5 .* ones(data_len, 1);
% 定日镜高度
heights = 6 .* ones(data_len, 1);
% 定日镜宽度
widths = 6 .* ones(data_len, 1);
% 集热塔位置信息
collector_tower = [0, 0, 80];

% 绘制散点图
scatter3(positions(:, 1), positions(:, 2), positions(:, 3), 10, 'b', 'filled'); 
hold on;
scatter3(0, 0, 80, 50, 'red', 'filled');

dates = {'2023-1-21', '2023-2-21', '2023-3-21', '2023-4-21', '2023-5-21', '2023-6-21', ...
         '2023-7-21', '2023-8-21', '2023-9-21', '2023-10-21', '2023-11-21', '2023-12-21'};
times = {'9:00:00', '10:30:00', '12:00:00', '13:30:00', '15:00:00'};
datetimeMatrix = repmat(datetime('now'), 12, 5);
for i = 1:length(dates)
    for j = 1:length(times)
        % 合并日期和时间，然后转换为datetime对象
        datetimeString = [dates{i} ' ' times{j}];
        datetimeMatrix(i, j) = datetime(datetimeString, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
    end
end

energy = cell(12, 5);
eta = cell(12, 5);
eta_sb = cell(12, 5);
eta_cos = cell(12, 5);
eta_trunc = cell(12, 5);
eta_at = cell(12, 5);
for j = 1:12
    for i = 1:5
        [~, energy{j, i}, eta{j, i}, eta_sb{j, i}, eta_trunc{j, i}, eta_cos{j, i}, eta_at{j, i}] = ...
            caculate(datetimeMatrix(j, i), positions, heights, widths, collector_tower);
        fprintf('%d月21日 第%d个时间点 计算完成\n', j, i);
    end
end

sum_energy = 0;
energy_month = zeros(12, 1);
avg_eta = zeros(12, 1);
avg_eta_at = zeros(12, 1);
avg_eta_cos = zeros(12, 1);
avg_eta_sb = zeros(12, 1);
avg_eta_trunc = zeros(12, 1);
for j = 1:12
    for i = 1:5
        avg_eta(j) = avg_eta(j) + mean(eta{j, i});
        avg_eta_at(j) = avg_eta_at(j) + mean(eta_at{j, i});
        avg_eta_cos(j) = avg_eta_cos(j) + mean(eta_cos{j, i});
        avg_eta_sb(j) = avg_eta_sb(j) + mean(eta_sb{j, i});
        avg_eta_trunc(j) = avg_eta_trunc(j) + mean(eta_trunc{j, i});
        sum_energy = sum_energy + energy{j, i};
        energy_month(j) = energy_month(j) + energy{j, i};
        if ~isreal(energy{j, i})
            fprintf('%d %d\n', j, i);
        end
    end
    avg_eta(j) = avg_eta(j) / 5;
    avg_eta_at(j) = avg_eta_at(j) / 5;
    avg_eta_cos(j) = avg_eta_cos(j) / 5;
    avg_eta_sb(j) = avg_eta_sb(j) / 5;
    avg_eta_trunc(j) = avg_eta_trunc(j) / 5;
    energy_month(j) = energy_month(j) / 5;
end
fprintf("年平均输出功率：%4f\n", sum_energy / 60 / 1000);



