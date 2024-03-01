clear;
clc;

% 第三问主程序，双层规划优化
% 集热塔位置信息（需要优化x和y）
collector_tower = [48.2369, -126.0147, 80]; % 采用第二问的结果
% 最小同心圆的半径
min_r = 100;
% 安装高度函数的斜率
k_install_h = 0;
% 高度函数的斜率
k_h = 0;
% 宽度函数的斜率
k_w = 0;
% 基准点
a1 = 2.875;
a0 = 5.75;
init_circle_num = 75;
% 第二问的
dist = 5.75 + 5;

[~, ~, circle_r, ~] = concentric_circles(collector_tower, init_circle_num, min_r, dist);
[valid, install_heights, heights, widths, dist, circle_r] = update_(k_install_h, k_h, k_w, circle_r, collector_tower, a0, a1);
assert(valid)
disp('初始解合法')


[init_energy, init_unit_energy, init_eta] = val_func_2(install_heights, heights, widths, init_circle_num, min_r, dist, collector_tower);
fprintf("功率：%4f, 单位功率：%4f, 光学效率：%4f\n", init_energy, init_unit_energy, init_eta);


% 循环直到收敛
flag = true;
epoch = 0;
while flag
    epoch = epoch + 1;
    if epoch ~= 1
        % 上层规划，目标是平均光学效率最高
        % 吸收塔移动步长 
        step = 2.5 + 15 * rand();
        % 步长数组
        step_sizes = [-step, 0, step];
        
        % 初始化存储周围点的数组
        neighbor_points = [];
        % 生成周围的点
        for dx = step_sizes
            for dy = step_sizes
                % 计算新点的坐标
                new_x = collector_tower(1) + dx;
                new_y = collector_tower(2) + dy;
                % 将新点添加到数组中
                neighbor_points = [neighbor_points; [new_x, new_y]];
            end
        end
    
        % 遍历邻居点，选择光学效率最高的点作为吸收塔的坐标
        unit_energy_up_layer = zeros(1, length(step_sizes)^2);
        energy_up_layer = zeros(1, length(step_sizes)^2);
        eta_up_layer = zeros(1, length(step_sizes)^2);
        for i = 1:length(step_sizes)^2
            % 计算定日镜坐标
            [~, install_heights, heights, widths, dist] = update_(new_k_install_h, k_h, k_w, circle_r, [neighbor_points(i, :), 80], a0, a1);
            [~, data_len] = concentric_circles_2([neighbor_points(i, :), 80], init_circle_num, min_r, dist);
            
            % 计算光学效率
            [energy_up_layer(i), unit_energy_up_layer(i), eta_up_layer(i)] = val_func_2(install_heights, heights, ...
                widths, init_circle_num, min_r, dist, [neighbor_points(i, :), 80]);
            fprintf('邻居%d的光学效率：%4f\n', i, eta_up_layer(i));
        end
        % 选择最大光学效率的点
        [~, index] = max(eta_up_layer);
        collector_tower = [neighbor_points(index, :), 80];
        fprintf('collector_tower更新为：%4f, %4f\n', collector_tower(1), collector_tower(2));
    end


    init_k_install_h = k_install_h;
    init_k_h = k_h;
    init_k_w = k_w;
    % 下层规划，目标是单位面积输出功率最大，要满足各种约束条件
    step = 0.00025;
    range = 0.001;
    for inner_loop = 1:2
        % 调整安装高度的函数斜率
        best_k_install_h = k_install_h;
        best_unit_energy = -inf;
        best_circle_r = circle_r;
        for new_k_install_h = k_install_h-range:step:k_install_h+range
            [valid, install_heights, heights, widths, dist, tmp_circle_r] = update_(new_k_install_h, k_h, k_w, circle_r, collector_tower, a0, a1);
            if ~valid
%                 disp('斜率不合法，进行下次计算');
                continue;
            end
            [res_energy, res_unit_energy, ~] = val_func_2(install_heights, heights, widths, init_circle_num, min_r, dist, collector_tower);
            if res_energy > 60 && res_unit_energy > best_unit_energy
                best_unit_energy = res_unit_energy;
                best_k_install_h = new_k_install_h;
                best_circle_r = tmp_circle_r;
            end
            fprintf('暂定安装高度斜率为：%4f，总功率：%4f，单位功率：%4f\n', new_k_install_h, res_energy, res_unit_energy);
        end
        % 取单位效率最高的参数
        k_install_h = best_k_install_h;
        circle_r = best_circle_r;
        fprintf('k_install_h更新为：%4f\n', k_install_h);

        % 调整高度的函数斜率
        best_k_h = k_h;
        best_unit_energy = -inf;
        best_circle_r = circle_r;
        for new_k_h = k_h-range:step:k_h+range
            [valid, install_heights, heights, widths, dist, tmp_circle_r] = update_(k_install_h, new_k_h, k_w, circle_r, collector_tower, a0, a1);
            if ~valid
%                 disp('斜率不合法，进行下次计算');
                continue;
            end
            [res_energy, res_unit_energy, ~] = val_func_2(install_heights, heights, widths, init_circle_num, min_r, dist, collector_tower);
            if res_energy > 60 && res_unit_energy > best_unit_energy
                best_unit_energy = res_unit_energy;
                best_k_h = new_k_h;
                best_circle_r = tmp_circle_r;
            end
            fprintf('暂定高度斜率为：%4f，总功率：%4f，单位功率：%4f\n', new_k_h, res_energy, res_unit_energy);
        end
        % 取单位效率最高的参数
        k_h = best_k_h;
        circle_r = best_circle_r;
        fprintf('k_h更新为：%4f\n', k_h);

        % 调整宽度的函数斜率
        best_k_w = k_w;
        best_unit_energy = -inf;
        best_circle_r = circle_r;
        for new_k_w = k_w-range:step:k_w+range
            [valid, install_heights, heights, widths, dist, tmp_circle_r] = update_(k_install_h, k_h, new_k_w, circle_r, collector_tower, a0, a1);
            if ~valid
%                 disp('斜率不合法，进行下次计算');
                continue;
            end
            [res_energy, res_unit_energy, ~] = val_func_2(install_heights, heights, widths, init_circle_num, min_r, dist, collector_tower);
            if res_energy > 60 && res_unit_energy > best_unit_energy
                best_unit_energy = res_unit_energy;
                best_k_h = new_k_h;
                best_circle_r = tmp_circle_r;
            end
            fprintf('暂定宽度斜率为：%4f，总功率：%4f，单位功率：%4f\n', new_k_h, res_energy, res_unit_energy);
        end
        % 取单位效率最高的参数
        k_w = best_k_w;
        circle_r = best_circle_r;
        fprintf('k_w更新为：%4f\n', k_w);

        % 调整高度的函数斜率
        best_k_h = k_h;
        best_unit_energy = -inf;
        best_circle_r = circle_r;
        for new_k_h = k_h-range:step:k_h+range
            [valid, install_heights, heights, widths, dist, tmp_circle_r] = update_(k_install_h, new_k_h, k_w, circle_r, collector_tower, a0, a1);
            if ~valid
%                 disp('斜率不合法，进行下次计算');
                continue;
            end
            [res_energy, res_unit_energy, ~] = val_func_2(install_heights, heights, widths, init_circle_num, min_r, dist, collector_tower);
            if res_energy > 60 && res_unit_energy > best_unit_energy
                best_unit_energy = res_unit_energy;
                best_k_h = new_k_h;
                best_circle_r = tmp_circle_r;
            end
            fprintf('暂定高度斜率为：%4f，总功率：%4f，单位功率：%4f\n', new_k_h, res_energy, res_unit_energy);
        end
        % 取单位效率最高的参数
        k_h = best_k_h;
        circle_r = best_circle_r;
        fprintf('k_h更新为：%4f\n', k_h);

    end
        

    % 下层规划没有变动，则收敛，退出循环
    if init_k_install_h == k_install_h && init_k_h == k_h && init_k_w == k_w
        flag = false;
    end

    [valid, install_heights, heights, widths, dist, circle_r] = update_(k_install_h, k_h, new_k_w, circle_r, collector_tower, a0, a1);
    [init_energy, init_unit_energy, init_eta] = val_func_2(install_heights, heights, widths, init_circle_num, min_r, dist, collector_tower);
    fprintf("功率：%4f, 单位功率：%4f, 光学效率：%4f\n", init_energy, init_unit_energy, init_eta);


end


function [valid, flag] = validation_test(group_install_heights, group_heights, group_widths, circlr_r, group_num)
    for i = 1:group_num
        if group_widths(i) < group_heights(i) || group_heights(i) > 2 * group_install_heights(i)
            valid = false;
            flag = 1;
            return
        end
        if group_widths(i) < 2 || group_widths(i) > 8 || group_heights(i) < 2 || group_heights(i) > 8 || group_install_heights(i) < 2 || group_install_heights(i) > 6
            valid = false;
            flag = 2;
            return
        end
        if i ~= 1 && circlr_r(i) - circlr_r(i-1) < max([group_widths(i), group_widths(i-1)]) + 5
            valid = false;
            flag = 3;
            return
        end
    end
    valid = true;
    flag = 0;
    return;
end

function [valid, install_heights, heights, widths, dist, circle_r] = update_(k_install_h, k_h, k_w, circle_r, collector_tower, a0, a1)
    
    % 初始圆圈数量(设置大一点，以铺满整个场，超出部分会被去除)
    min_r = 100;
    init_circle_num = 75; 
    group_install_height = zeros(init_circle_num, 1);
    group_height = zeros(init_circle_num, 1);
    group_width = zeros(init_circle_num, 1);
    dist = zeros(init_circle_num, 1);
    % 每组定日镜的信息
    for i = 1:init_circle_num
        group_install_height(i) = k_install_h * (circle_r(i)-min_r) + a1;
        group_height(i) = k_h * (circle_r(i)-min_r) + a0;
        group_width(i) = k_w * (circle_r(i)-min_r) + a0;
        dist(i) = group_width(i) + 5.01;
    end
    
    
    [~, data_len, circle_r, ~, group] = concentric_circles_2(collector_tower, init_circle_num, min_r, dist);
    group_nums = max(group);
    group_install_height = group_install_height(1:group_nums);
    group_width = group_width(1:group_nums);
    group_height = group_height(1:group_nums);
    [valid, flag] = validation_test(group_install_height, group_height, group_width, circle_r, group_nums);
%     if ~valid
%         disp(group_install_height')
%         disp(group_width')
%         disp(group_height')
%         disp(flag);
%     end
    % 每个定日镜的信息
    install_heights = zeros(data_len, 1);
    heights = zeros(data_len, 1);
    widths = zeros(data_len, 1);
    for i = 1:data_len
        install_heights(i) = group_install_height(group(i));
        heights(i) = group_height(group(i));
        widths(i) = group_width(group(i));
    end
end