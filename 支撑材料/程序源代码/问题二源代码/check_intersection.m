function [isIntersect, intersectionPoint] = check_intersection(rayPoint, rayDir, rectVertices)

    % 检查从rayPoint发出的，朝着rayDir方向的射线，与rectVertices组成的长方形是否相交
    % rayPoint: 射线的起点
    % rayDir: 射线的方向向量
    % rectVertices: 4x3 矩阵, 每一行是长方形一个顶点的坐标
    % isIntersect: 是否相交
    % intersectionPoint: 如果相交, 返回交点坐标, 否则返回 []
    
    % 计算法线
    edge1 = rectVertices(2, :) - rectVertices(1, :);
    edge2 = rectVertices(3, :) - rectVertices(1, :);
    normal = cross(edge1, edge2); 
    
    denom = dot(normal, rayDir);
    
    % 起点到长方形距离（沿着射线，长方形经过无限延展）
    t = dot(rectVertices(1,:) - rayPoint, normal) / denom;
    
    % 如果t为负, 射线与长方形平面相交在射线起点的反方向上
    if t < 0
        isIntersect = false;
        intersectionPoint = [];
        return;
    end
    
    % 计算交点
    intersectionPoint = rayPoint + t * rayDir;
    
    % 检查交点是否在长方形内部
    AB = rectVertices(2,:) - rectVertices(1,:);
    AM = intersectionPoint - rectVertices(1,:);
    BC = rectVertices(3,:) - rectVertices(2,:);
    BM = intersectionPoint - rectVertices(2,:);
    
    if (dot(AB, AM) >= 0) && (dot(AB, AM) <= dot(AB, AB)) && ...
       (dot(BC, BM) >= 0) && (dot(BC, BM) <= dot(BC, BC))
        isIntersect = true;
    else
        isIntersect = false;
        intersectionPoint = [];
    end
end

