function [eta_sb, eta_trunc, eta_cos, eta_at] = eta_caculate(positions, num, sun_direction, normal_direction, collector_tower, vertex_data)

    % 计算单个定日镜的阴影遮挡效率
    % sun_direction 是太阳主光线的方向
    % normal_direction 是目标定日镜的法向向量
    % position 是定日镜位置数据
    % num 是目标定日镜编号
    % collector_tower 是集热塔坐标
    
    % 取点个数（决定程序运行时间）
    num_points = 200;
    % 距离
    dist_nearby = 20;
    % 轮数
    epoch = 1;
    
    % 目标定日镜数据
    target_heliostat = positions(num, 1:3);
    
    % 计算目标点与所有点的距离
    distances = sqrt(sum((target_heliostat - positions).^2, 2));
    
    % 找出距离不超过 n 的点的索引
    nearby_indices = distances <= dist_nearby & distances > 0;
    
    % 根据索引提取符合条件的坐标点
    nearby_heliostat_vertex = vertex_data(:, :, nearby_indices);
%     disp(size(nearby_heliostat_vertex, 3))
    
    points = generate_point(vertex_data(:, :, num), num_points);
    
    % 没被挡住的光线数目
    counter_not_blocked = 0;
    % 到达集热器的光线数目
    counter_reach_collector = 0;
    % 对每一轮
    for e = 1:epoch 
        % 对每个点
        for i = 1:size(points, 1)
            % 标识是否被挡住，初始设置为 false
            blocked = false;
            % 太阳光方向（光锥模型，进行一定偏移）
            new_direction = offset_direction(sun_direction, 4.65e-3);
            % 反射方向
            reflection_direction = reflect(-sun_direction, normal_direction);
%             disp(sun_direction)
%             disp(reflection_direction)
            % 检查入射光是否被集热塔阻挡
            blocked = check_intersect_cylinder(points(i, :), new_direction, [collector_tower(1), collector_tower(2), 0], 84, 3.5);
%             if blocked
%                 disp(num)
%             end
            for j = 1:size(nearby_heliostat_vertex, 3)
                if blocked
                    break
                end
                % 检查入射是否被遮挡
                blocked = blocked | check_intersection(points(i, :), new_direction, nearby_heliostat_vertex(:, :, j));
                % 检查反射是否被遮挡
                blocked = blocked | check_intersection(points(i, :), reflection_direction, nearby_heliostat_vertex(:, :, j));
            end
            if ~blocked
                counter_not_blocked = counter_not_blocked + 1;
                if check_intersect_cylinder(points(i, :), reflection_direction, [collector_tower(1), collector_tower(2), 0], 84, 3.5)
                    counter_reach_collector = counter_reach_collector + 1;
                end
            end
        end
    end
    
    % 阴影遮挡效率
    eta_sb = counter_not_blocked/ (epoch * size(points, 1));
    % 集热器截断效率
    if counter_not_blocked == 0
        eta_trunc = 0;
    else
        eta_trunc = counter_reach_collector / counter_not_blocked;
    end

    % 余弦效率
    eta_cos = cos(0.5 * acos(dot(real(sun_direction), real(reflection_direction))));
%     eta_cos = sqrt((dot(real(sun_direction), real(reflection_direction)) + 1) / 2);
    assert(isreal(eta_cos));
    
    % 镜面中心到集热器中心的距离
    d_HR = norm(collector_tower - target_heliostat);
    % 大气透射率
    eta_at = 0.99321 - 0.0001176 * d_HR + 1.97*10^-8 * d_HR^2;

end

