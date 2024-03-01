clear;
clc;
% 第二问主程序的第二部分（根据第一部分的结果进行双层规划
% 初始化结果
% 集热塔位置信息（需要优化x和y）
collector_tower = [95.4545 -159.0909, 80]; % 采用初始化的结果
% 定日镜安装高度（需要优化）
install_height = 5;
% 定日镜高度（需要优化）
height = 6;
% 定日镜宽度（需要优化）
width = 6;

% % 检查点结果
% % 集热塔位置信息（需要优化x和y）
% collector_tower = [78.836753, -148.319177   80.0000]; % 采用初始化的结果
% % 定日镜安装高度（需要优化）
% install_height = 2.8750;
% % 定日镜高度（需要优化）
% height = 5.75;
% % 定日镜宽度（需要优化）
% width = 5.75;

% 初始圆圈数量(设置大一点，以铺满整个场，超出部分会被去除)
init_circle_num = 75; 
% 最小同心圆的半径
min_r = 100;
% 相邻两点最小距离
dist = width + 5;

[~, data_len, circle_r, point_num] = concentric_circles(collector_tower, init_circle_num, min_r, dist);
assert(isvalid(install_height, height, width, circle_r, point_num));
% [~, data_len] = concentricCircles(collector_tower, circle_r, point_num, circle_angle);

[init_energy, init_unit_energy, init_eta] = val_func(repmat(install_height, data_len, 1), repmat(height, data_len, 1), ...
    repmat(width, data_len, 1), init_circle_num, min_r, dist, collector_tower);

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
            [~, data_len] = concentric_circles([neighbor_points(i, :), 80], init_circle_num, min_r, dist);
            % 计算光学效率
            [energy_up_layer(i), unit_energy_up_layer(i), eta_up_layer(i)] = val_func(repmat(install_height, data_len, 1), repmat(height, data_len, 1), ...
                repmat(width, data_len, 1), init_circle_num, min_r, dist, [neighbor_points(i, :), 80]);
            fprintf('邻居%d的光学效率：%4f\n', i, eta_up_layer(i));
        end
        % 选择最大光学效率的点
        [~, index] = max(eta_up_layer);
        collector_tower = [neighbor_points(index, :), 80];
        fprintf('collector_tower更新为：%4f, %4f\n', collector_tower(1), collector_tower(2));
    end


    init_install_height = install_height;
    init_height = height;
    init_width = width;
    % 下层规划，目标是单位面积输出功率最大，要满足各种约束条件
    step = 0.25;
    for inner_loop = 1:2
        % 调整安装高度
        best_install_h = install_height;
        best_unit_energy = -inf;
        for install_h = max([2, height/2]):step:6
            % 计算定日镜坐标
            [~, data_len] = concentric_circles(collector_tower, init_circle_num, min_r, dist);
            [res_energy, res_unit_energy, ~] = val_func(repmat(install_h, data_len, 1), repmat(height, data_len, 1), ...
                repmat(width, data_len, 1), init_circle_num, min_r, dist, collector_tower);
            if res_energy > 60 && res_unit_energy > best_unit_energy
                best_unit_energy = res_unit_energy;
                best_install_h = install_h;
            end
            fprintf('暂定安装高度为：%4f，总功率：%4f，单位功率：%4f\n', install_h, res_energy, res_unit_energy);
        end
        % 取单位效率最高的参数
        install_height = best_install_h;
        fprintf('install_height更新为：%4f\n', install_height);


        % 调整高度 
        best_h = height;
        best_unit_energy = -inf;
        for h = max(2, 2/3*width):step:min([2*install_height, 8, width])
            % 计算定日镜坐标
            [~, data_len] = concentric_circles(collector_tower, init_circle_num, min_r, dist);
            [res_energy, res_unit_energy, ~] = val_func(repmat(install_height, data_len, 1), repmat(h, data_len, 1), ...
                repmat(width, data_len, 1), init_circle_num, min_r, dist, collector_tower);
            if res_energy > 60 && res_unit_energy > best_unit_energy
                best_unit_energy = res_unit_energy;
                best_h = h;
            end
            fprintf('暂定高度为：%4f，总功率：%4f，单位功率：%4f\n', h, res_energy, res_unit_energy);
        end
        % 取单位效率最高的参数
        height = best_h;
        fprintf('height更新为：%4f\n', height);


        % 调整宽度 
        best_w = width;
        best_unit_energy = -inf;
        for w = max([height, 2]):step:8
            % 更新相邻两定日镜最小距离
            dist = w + 5;
            % 计算定日镜坐标
            [~, data_len] = concentric_circles(collector_tower, init_circle_num, min_r, dist);
            [res_energy, res_unit_energy, ~] = val_func(repmat(install_height, data_len, 1), repmat(height, data_len, 1), ...
                repmat(w, data_len, 1), init_circle_num, min_r, dist, collector_tower);
            if res_energy > 60 && res_unit_energy > best_unit_energy
                best_unit_energy = res_unit_energy;
                best_w = w;
            end
            fprintf('暂定宽度为：%4f，总功率：%4f，单位功率：%4f\n', w, res_energy, res_unit_energy);
        end
        % 取单位效率最高的参数
        width = best_w;
        fprintf('width更新为：%4f\n', width);
        % 更新相邻两定日镜最小距离
        dist = width + 5;
    
        % 调整高度 
        best_h = height;
        best_unit_energy = -inf;
        for h = 2:step:min([2*install_height, 8, width])
            % 计算定日镜坐标
            [~, data_len] = concentric_circles(collector_tower, init_circle_num, min_r, dist);
            [res_energy, res_unit_energy, ~] = val_func(repmat(install_height, data_len, 1), repmat(h, data_len, 1), ...
                repmat(width, data_len, 1), init_circle_num, min_r, dist, collector_tower);
            if res_energy > 60 && res_unit_energy > best_unit_energy
                best_unit_energy = res_unit_energy;
                best_h = h;
            end
            fprintf('暂定高度为：%4f，总功率：%4f，单位功率：%4f\n', h, res_energy, res_unit_energy);
        end
        % 取单位效率最高的参数
        height = best_h;
        fprintf('height更新为：%4f\n', height);
    end

    % 下层规划没有变动，则收敛，退出循环
    if init_install_height == install_height && init_height == height && init_width == width
        flag = false;
    end

    
    [positions, data_len] = concentric_circles(collector_tower, init_circle_num, min_r, dist);
    [res_energy, res_unit_energy, res_eta] = val_func(repmat(install_height, data_len, 1), repmat(height, data_len, 1), ...
        repmat(width, data_len, 1), init_circle_num, min_r, dist, collector_tower);
    
    fprintf("功率：%4f, 单位功率：%4f, 光学效率：%4f\n", init_energy, init_unit_energy, init_eta);

end








