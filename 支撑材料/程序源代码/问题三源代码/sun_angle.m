function [solar_elevation_deg, sun_azimuth_deg, direction] = sun_angle(lon_deg, lat_deg, date_time)

    % 计算太阳高度角的函数
    % 输入观测地的地理经纬度，地方时（日期时间）
    % 输出太阳高度角的sin值，太阳高度角
    
    % 观测地的地理经度
    % lon_deg = 98.5; 
    lon_rad = deg2rad(lon_deg); % 将度数转换为弧度
    
    % 观测地的地理纬度
    % lat_deg = 39.4;
    lat_rad = deg2rad(lat_deg); % 将度数转换为弧度
    
    % 观测地的日期
    % date_time = datetime('2023-9-21 12:00');
    
    % 计算距离春分的天数（以春分作为第0天起算）
    spring_equinox = datetime(year(date_time), 3, 21, 0, 0, 0); % 假设春分日期为3月21日
    D = days(date_time - spring_equinox);
    
    % 太阳赤纬
    sin_delta = sin(2*pi*D / 365) * sin(2*pi*23.45 / 360);
    delta_rad = asin(sin_delta);
    
    % 地方时（以时为单位）
    local_time_hours = hour(date_time) + minute(date_time) / 60;
    
    % 计算太阳高度角（以弧度为单位）
    w = (local_time_hours - 12) * (pi / 12); % 将地方时转换为弧度
    sin_as = sin(lat_rad) * sin(delta_rad) + cos(lat_rad) * cos(delta_rad) * cos(w);
    solar_elevation_rad = asin(sin_as); % 太阳高度角的弧度值
    
    % 太阳方位角
    cos_sun_azimuth = (sin_delta - sin_as * sin(lat_rad)) / (cos(solar_elevation_rad) * cos(lat_rad));
    sun_azimuth_rad = acos(cos_sun_azimuth);
    
    % 计算太阳光的方向向量
    x = cos(solar_elevation_rad) * sin(sun_azimuth_rad);
    y = cos(solar_elevation_rad) * cos(sun_azimuth_rad);
    z = sin(solar_elevation_rad);
    direction = [x, y, z];
    
    
    % 将太阳高度角转换为度数
    solar_elevation_deg = rad2deg(solar_elevation_rad);
    sun_azimuth_deg = rad2deg(sun_azimuth_rad);
    
    % 展示结果
%     fprintf('太阳高度角（度）：%f\n', solar_elevation_deg);
%     fprintf('太阳方位角（度）：%f\n', sun_azimuth_deg);
%     fprintf('太阳光的方向向量为：[%.4f, %.4f, %.4f]\n', x, y, z);

end

