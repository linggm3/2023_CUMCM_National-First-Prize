function [vertex1, vertex2, vertex3, vertex4] = vertex(target_heliostat, height, width, normal_direction)

    % 计算定日镜四个角的坐标
    % target_heliostat 是目标定日镜数据
    % normal_direction 是定日镜法向方向
    
    % 计算长方形的四个顶点坐标
    % 首先，计算两个与地面平行的单位向量，用于确定矩形的边方向
    up_vector = [0, 0, 1]; % 地面的法向向量
    side_vector1 = cross(normal_direction, up_vector);
    side_vector1 = side_vector1 / norm(side_vector1);
    side_vector2 = cross(normal_direction, side_vector1);
    side_vector2 = side_vector2 / norm(side_vector2);
    
    % 计算四个顶点坐标
    vertex1 = target_heliostat - (width / 2) * side_vector1 - (height / 2) * side_vector2;
    vertex2 = target_heliostat + (width / 2) * side_vector1 - (height / 2) * side_vector2;
    vertex3 = target_heliostat + (width / 2) * side_vector1 + (height / 2) * side_vector2;
    vertex4 = target_heliostat - (width / 2) * side_vector1 + (height / 2) * side_vector2;
    
    % disp('长方形的四个顶点坐标：');
    % disp(['顶点1: ', num2str(vertex1)]);
    % disp(['顶点2: ', num2str(vertex2)]);
    % disp(['顶点3: ', num2str(vertex3)]);
    % disp(['顶点4: ', num2str(vertex4)]);


end

