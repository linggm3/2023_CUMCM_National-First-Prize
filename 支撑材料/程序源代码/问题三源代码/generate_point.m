function points_inside_rectangle = generate_point(vertices, num_points)

    % 在一个定日镜上生成均匀的点阵
    % 输入四个顶点坐标矩阵和要生成的点的数量
    % 输出在长方形内均匀取点的坐标
    
    % 从输入矩阵中提取四个顶点
    v1 = vertices(1, :);
    v2 = vertices(2, :);
    v3 = vertices(3, :);
    v4 = vertices(4, :);
    
    % 计算长方形的边向量和面积
    edge1 = v2 - v1;
    edge2 = v4 - v1;
    area = norm(cross(edge1, edge2));
    
    % 计算每个点的面积增量
    increment = sqrt(area / num_points);
    
    % 计算长方形的边长
    length1 = norm(edge1);
    length2 = norm(edge2);
    
    % 计算在每个边上的点数
    num_points_edge1 = round(length1 / increment);
    num_points_edge2 = round(length2 / increment);
    
    % 初始化存储点坐标的数组
    points_inside_rectangle = zeros(num_points_edge1 * num_points_edge2, 3);
    
    % 生成均匀分布的点坐标
    k = 1;
    for i = 1:num_points_edge1
        for j = 1:num_points_edge2
            u = (i - 0.5) * increment / length1;
            v = (j - 0.5) * increment / length2;
            point = v1 + u * edge1 + v * edge2;
            points_inside_rectangle(k, :) = point;
            k = k + 1;
        end
    end

end
