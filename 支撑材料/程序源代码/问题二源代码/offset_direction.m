function new_direction = offset_direction(original_direction, max_offset_angle)

    % original_direction : 输入射线的方向向量
    % max_offset_angle : 最大偏移角度
    % new_direction : 新射线的方向
    
    % 计算sigma，3*sigma 对应半角展宽
    sigma = 1/3 * atan(max_offset_angle);

    % 确保original_direction是单位向量
    original_direction = original_direction / norm(original_direction);

    % 找到与original_direction不平行的任意向量
    if original_direction(1) ~= 0 || original_direction(2) ~= 0
        temp_vector = [0; 0; 1];
    else
        temp_vector = [1; 0; 0];
    end

    % 通过外积找到第一个基向量
    basis1 = cross(original_direction, temp_vector);
    basis1 = basis1 / norm(basis1);

    % 再次使用外积找到第二个基向量
    basis2 = cross(original_direction, basis1);
    basis2 = basis2 / norm(basis2);

    % 在两个基向量上生成二维正态分布的随机点
    rand_point = sigma * randn(2, 1);

    % 使用基向量将这些随机点转换为平面上的三维点
    point = (basis1 * rand_point(1, :) + basis2 * rand_point(2, :))';
    new_direction = original_direction + point';
    new_direction = new_direction ./ norm(new_direction);
end

