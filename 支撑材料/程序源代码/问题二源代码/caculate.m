function [unit_energy, energy, eta, eta_sb, eta_trunc, eta_cos, eta_at] = caculate(date, positions, heights, widths, collector_tower)

    data_len = size(positions, 1);
    % 计算太阳高度角，太阳方位角，太阳主光线方向
    [solar_elevation_deg, sun_azimuth_deg, sun_direction] = sun_angle(98.5, 39.4, date);
    sun_direction = real(sun_direction);

    % 定日镜法向量（每次都要重新计算）
    norm_directions = zeros(data_len, 3);
    % 定日镜四个角的坐标（每次都要重新计算）
    vertex_data = zeros(4, 3, data_len);
    
    % 计算每个定日镜的法向向量和四角坐标
    for i = 1:data_len
        norm_directions(i, :) = normal_direction(positions(i, :), sun_direction, collector_tower);
        [vertex_data(1, :, i), vertex_data(2, :, i), vertex_data(3, :, i), vertex_data(4, :, i),] = ...
            vertex(positions(i, :), heights(i), widths(i), norm_directions(i, :));
    end
    
    % 计算每个定日镜的 阴影遮挡效率 和 集热器截断效率 和 余弦效率 和 大气透射率
    eta_sb = zeros(data_len, 1);
    eta_trunc = zeros(data_len, 1);
    eta_cos = zeros(data_len, 1);
    eta_at = zeros(data_len, 1);
    for i = 1:data_len
        [eta_sb(i), eta_trunc(i), eta_cos(i), eta_at(i)] = eta_caculate(positions, i, sun_direction, norm_directions(i, :), collector_tower, vertex_data);
    end
    
    
    % 镜面反射率 
    eta_ref = 0.92;
    
    % 计算DNI
    G0 = 1.366; % 太阳常数
    H = 3; % 海拔高度(km)
    a = 0.4237 - 0.00821 * (6 - H)^2;
    b = 0.5055 + 0.00595 * (6.5 - H)^2;
    c = 0.2711 + 0.01858 * (2.5 - H)^2;
    DNI = G0 * (a + b * exp(-c / sind(solar_elevation_deg)) );
    
    % 计算 光学效率 和 输出热功率
    energy = 0;
    unit_energy = 0;
    eta = zeros(data_len, 1);
    for i = 1:data_len
        eta(i) = eta_sb(i) * eta_trunc(i) * eta_cos(i) * eta_at(i) * eta_ref;
        energy = energy + DNI * heights(i) * widths(i) * eta(i);
    end
    unit_energy = energy / sum(heights .* widths);

end

