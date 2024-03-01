function reflection = reflect(input, norm_mirror)

    % 根据入射光线和镜面法向向量，计算出射光线
    % input: 入射光线的方向向量 (单位向量)
    % norm_mirror: 镜面的法向量 (单位向量)
    
    % 输出: 
    % R: 出射光线的方向向量
    
    reflection = input - 2 * dot(input, norm_mirror) * norm_mirror;
    % 将R归一化
    reflection = reflection / norm(reflection);

end