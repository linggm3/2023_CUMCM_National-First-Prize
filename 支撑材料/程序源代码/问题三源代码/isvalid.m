function [valid, flag] = isvalid(install_height, height, width, circle_r, point_num)
    % 检查状态是否合法
    if width < height || height > 2 * install_height
        valid = false;
        flag = 1;
        return
    end
    if width < 2 || width > 8 || height < 2 || height > 8 || install_height < 2 || install_height > 6
        valid = false;
        flag = 2;
        return
    end
    if ~all(circle_r >= 100)
        valid = false;
        flag = 3;
        return
    end
    for i = 2:length(circle_r)
        if circle_r(i) - circle_r(i-1) < width + 5
            % 如果相邻元素的差值不大于width，将flag设置为假并退出循环
            valid = false;
            flag = 4;
            return;
        end
    end
    for i = 1:length(circle_r)
        if 2 * sin(pi / point_num(i)) * circle_r(i) < width + 5
            valid = false;
            flag = 100 + i;
            return;
        end
    end
    valid = true;
    flag = 0;
end

