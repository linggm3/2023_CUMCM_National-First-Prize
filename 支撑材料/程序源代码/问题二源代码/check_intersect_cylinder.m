function [isIntersected] = check_intersect_cylinder(rayPoint, rayDir, collector_tower, h, r)

    % 检查从rayPoint发出的，朝着rayDir方向的射线，与圆柱体是否相交
    % rayPoint: 射线的起点
    % rayDir: 射线的方向向量
    % collector_tower: 圆柱体中心坐标
    % h 圆柱体高度
    % r 圆柱体半径
    % isIntersect: 是否相交
    % intersectionPoint: 如果相交, 返回交点坐标, 否则返回 []

    isIntersected = false;
    point = [NaN, NaN, NaN];
    
    % 计算射线与圆柱体顶部和底部的交点
    t1 = (collector_tower(3) - rayPoint(3)) / rayDir(3);
    t2 = (collector_tower(3) + h - rayPoint(3)) / rayDir(3);
    
    % 计算交点坐标
    p1 = rayPoint + t1 .* rayDir;
    p2 = rayPoint + t2 .* rayDir;
    
    % 检查交点是否在圆柱体的顶部或底部
    % 这里对底部的设定是为了代码复用，适用于计算阴影遮挡和截断效率
    % 阴影遮挡部分，入射光的反方向都是向上的，不会与吸收塔底部产生交点
    % 截断效率部分，反射光的方向向上，如果计算出反射光与集热器"底部"有交点，则这条光线被吸收塔阻挡，导致最终与集热器没有交点
    if t1 > 0 && (norm(p1(1:2) - collector_tower(1:2)) <= r)
        isIntersected = false;
        point = [];
        return;
    elseif t2 > 0 && (norm(p2(1:2) - collector_tower(1:2)) <= r)
        isIntersected = true;
        point = p2;
        return;
    end
    
    % 计算射线与圆柱体侧面的交点
    d = rayPoint(1:2) - collector_tower(1:2);
    A = rayDir(1)^2 + rayDir(2)^2;
    B = 2 * (rayDir(1)*d(1) + rayDir(2)*d(2));
    C = d(1)^2 + d(2)^2 - r^2;
    
    discriminant = B^2 - 4*A*C;
    
    if discriminant >= 0
        t3 = (-B + sqrt(discriminant)) / (2*A);
        t4 = (-B - sqrt(discriminant)) / (2*A);
        
        p3 = rayPoint + t3 .* rayDir;
        p4 = rayPoint + t4 .* rayDir;
        
        % 检查交点是否在圆柱体的有效高度内
        if t3 > 0 && (collector_tower(3) <= p3(3) && p3(3) <= collector_tower(3) + h)
            isIntersected = true;
            point = p3;
        elseif t4 > 0 && (collector_tower(3) <= p4(3) && p4(3) <= collector_tower(3) + h)
            isIntersected = true;
            point = p4;
        end
    end
end

