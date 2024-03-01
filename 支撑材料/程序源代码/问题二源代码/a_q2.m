clear;
clc;

% 第二问主程序的第一部分
% 遍历吸收塔的可能位置，给双层规划赋予初始状态
% 吸收塔可能出现的坐标
x_ = linspace(-350, 350, 10);
y_ = linspace(-350, 350, 10);
p_tower = zeros(length(x_), 2);
for i = 1:length(x_)
    for j = 1:length(y_)
        p_tower(i * length(x_) + j, :) = [x_(i) y_(j)];
    end
end
% 删除距离原点超过350的点
distances = sqrt(sum((p_tower - [0, 0]).^2, 2));
p_tower(distances > 350, :) = [];
p_tower = unique(p_tower, 'rows');
% scatter(p_tower(:, 1), p_tower(:, 2))
% axis equal
% p_tower = [116.6667 -194.4444]; % 结果

fprintf('遍历 %d 个点，初始化吸收塔坐标\n', size(p_tower, 1));


% 集热塔位置信息（需要优化x和y）
collector_tower = [0, 0, 80];
% 定日镜安装高度（需要优化）
install_height = 5;
% 定日镜高度（需要优化）
height = 6;
% 定日镜宽度（需要优化）
width = 6;
% 最小同心圆的半径
min_r = 100;
% 相邻两点最小距离
dist = width + 5;


% 遍历的记录
record = zeros(size(p_tower, 1), 3);

for e = 1:size(p_tower, 1)

    init_circle_num = 75; % 初始圆圈数量(设置大一点，以铺满整个场，超出部分会被去除)
    [positions, data_len, circle_r, point_num] = concentric_circles([p_tower(e, :), 80], init_circle_num, min_r, dist);
    assert(isvalid(install_height, height, width, circle_r, point_num));
    % 定日镜法向量（每次都要重新计算）
    norm_directions = zeros(data_len, 3);
    % 定日镜四个角的坐标（每次都要重新计算）
    vertex_data = zeros(4, 3, data_len);  
    [record(e, 1), record(e, 2), record(e, 3)] = val_func(repmat(install_height, data_len, 1), repmat(height, data_len, 1), ...
        repmat(width, data_len, 1), init_circle_num, min_r, dist, [p_tower(e, :), 80]);
    disp(e)
    disp(record(e, :))
    
end




