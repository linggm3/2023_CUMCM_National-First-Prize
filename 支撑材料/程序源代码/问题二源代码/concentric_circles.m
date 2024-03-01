function [points, nums, circle_r, point_num, group] = concentric_circles(center, circle_num, min_r, dist)
    % 按最密排列的方法，以center为中心生成同心圆，生成圆上的定日镜坐标
    % 输入参数:
    % center: 圆心坐标 [x, y]
    % n: 同心圆的数量
    % r: 最小的圆半径
    % d: 两点之间的最小距离
    % 输出参数:
    % points: 所有生成的点的坐标
    
    points = [];
    point_num = zeros(1, circle_num);
    circle_r = min_r:dist:min_r+(circle_num-1)*dist;
    prev_num_points = 0; % 记录前一个圆上的点的数量
    group = [];
    
    for i = 1:circle_num
        R = min_r + (i-1)*dist;  % 当前圆的半径
        circumference = 2 * pi * R;  % 当前圆的周长
        num_points = floor(circumference / dist);  % 当前圆上可以放置的点的数量
        delta_theta = 2*pi / num_points;  % 每个点之间的角度间隔
        
        % 基于前一个圆的点数计算偏移
        if i > 1
            offset = pi / (prev_num_points + num_points);
        else
            offset = 0;
        end

        for j = 1:num_points
            theta = (j-1) * delta_theta + offset;  % 加上偏移量
            x = center(1) + R * cos(theta);
            y = center(2) + R * sin(theta);
            points = [points; x y];
            group = [group, i];
        end
    
        prev_num_points = num_points; % 更新前一个圆的点数
    end
    
    % 删除距离原点超过350的点
    distances = sqrt(sum((points - [0, 0]).^2, 2));
    points(distances > 350, :) = [];
    nums = size(points, 1);
    group = group(1:nums);

%     scatter(points(:, 1), points(:, 2), 'k.');
%     hold on;
%     banjing = 350; % 半径
%     a = 0; % 圆心横坐标
%     b = 0; % 圆心纵坐标
%     theta = 0:pi/20:2*pi; %角度[0,2*pi] 
%     x = a+banjing*cos(theta);
%     y = b+banjing*sin(theta);
%     plot(x,y,'-')
%     axis equal
%     fprintf('生成了%d个点\n', size(points, 1));

end
