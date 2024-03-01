function [normal_direction] = normal_direction(target_heliostat, sun_direction, collector_tower)

    % 计算定日镜的法向方向向量
    % target_heliostat 是目标定日镜数据
    % sun_direction 是太阳主光线的方向
    % collector_tower 是集热塔坐标
    
    % 反射光线方向
    reflect_direction = collector_tower - target_heliostat;
    assert (reflect_direction(3) * sun_direction(3) >= 0)
    % 归一化
    sun_direction = sun_direction ./ norm(sun_direction);
    reflect_direction = reflect_direction ./ norm(reflect_direction);
    % 计算定日镜法线方向
    normal_direction = sun_direction + reflect_direction;
    normal_direction = normal_direction ./ norm(normal_direction);

end

