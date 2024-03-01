function [sum_energy, unit_energy, avg_eta] = val_func(install_heights, heights, widths, circle_num, min_r, dist, collector_tower)

    % 评价函数
    positions = concentric_circles(collector_tower, circle_num, min_r, dist);
    positions = [positions, install_heights];

    dates = {'2023-1-21', '2023-2-21', '2023-3-21', '2023-4-21', '2023-5-21', '2023-6-21', '2023-7-21', '2023-8-21','2023-9-21', '2023-10-21','2023-11-21', '2023-12-21'};
    times = {'9:00:00', '10:30:00', '12:00:00', '13:30:00', '15:00:00'};
    datetimeMatrix = repmat(datetime('now'), 12, 5);
    for i = 1:length(dates)
        for j = 1:length(times)
            % 合并日期和时间，然后转换为datetime对象
            datetimeString = [dates{i} ' ' times{j}];
            datetimeMatrix(i, j) = datetime(datetimeString, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
        end
    end
    
    energy = cell(length(dates), length(times));
    eta = cell(length(dates), length(times));

    % 求年均热功率
    for j = 1:length(dates)
        for i = 1:length(times)
            [~, energy{j, i}, eta{j, i}] = ...
                caculate(datetimeMatrix(j, i), positions, heights, widths, collector_tower);
        end
    end
    
    sum_energy = 0;
    avg_eta = zeros(length(dates), 1);
    for j = 1:length(dates)
        for i = 1:length(times)
            avg_eta(j) = avg_eta(j) + mean(eta{j, i});
            sum_energy = sum_energy + energy{j, i};
        end
        avg_eta(j) = avg_eta(j) / length(times);
    end
    sum_energy = sum_energy / length(dates) / length(times) / 1000;
    avg_eta = mean(avg_eta);
    sum_area = 0;
    for i = 1:size(positions, 1)
        sum_area = sum_area + widths(i) * heights(i);
    end
    unit_energy = sum_energy / sum_area;
end

